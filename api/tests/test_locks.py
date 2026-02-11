"""Tests for lock endpoints."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from starlette.testclient import TestClient


def _create_experiment_and_job(
    client: TestClient,
    headers: dict[str, str],
) -> tuple[str, str]:
    """Create an experiment with one job, return (exp_id, job_id)."""
    resp = client.post(
        "/experiments",
        json={"initial": "x", "description": "Lock test"},
        headers=headers,
    )
    exp_id: str = resp.json()["id"]
    client.post(
        f"/experiments/{exp_id}/jobs",
        json={"job_id": "a"},
    )
    return exp_id, "a"


class TestCheckLock:
    def test_unlocked(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        resp = client.get(f"/experiments/{exp_id}/jobs/{job_id}/lock")
        assert resp.status_code == 200
        data = resp.json()
        assert data["locked"] is False
        assert data["owner"] is None

    def test_locked(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        resp = client.get(f"/experiments/{exp_id}/jobs/{job_id}/lock")
        assert resp.status_code == 200
        data = resp.json()
        assert data["locked"] is True
        assert data["owner"] == "testuser"


class TestAcquireLock:
    def test_acquire(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        resp = client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["owner"] == "testuser"

    def test_acquire_missing_user(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        resp = client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
        )
        assert resp.status_code == 400

    def test_acquire_conflict(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        resp = client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers={"X-UMUI-User": "other"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is False
        assert data["owner"] == "testuser"

    def test_force_acquire(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        resp = client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            json={"force": True},
            headers={"X-UMUI-User": "other"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["forced"] is True


class TestReleaseLock:
    def test_release(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        resp = client.delete(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True

        # Verify unlocked
        check = client.get(f"/experiments/{exp_id}/jobs/{job_id}/lock")
        assert check.json()["locked"] is False

    def test_release_not_locked(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        resp = client.delete(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is False

    def test_release_by_other_user(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id, job_id = _create_experiment_and_job(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers=user_headers,
        )
        resp = client.delete(
            f"/experiments/{exp_id}/jobs/{job_id}/lock",
            headers={"X-UMUI-User": "other"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is False
