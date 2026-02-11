"""Tests for job endpoints."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from starlette.testclient import TestClient


def _create_experiment(
    client: TestClient, headers: dict[str, str],
) -> str:
    """Helper to create an experiment and return its ID."""
    resp = client.post(
        "/experiments",
        json={"initial": "x", "description": "Test"},
        headers=headers,
    )
    return resp.json()["id"]


class TestListJobs:
    def test_empty(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.get(f"/experiments/{exp_id}/jobs")
        assert resp.status_code == 200
        assert resp.json() == {"jobs": []}

    def test_lists_created(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a", "description": "Job A"},
        )
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "b", "description": "Job B"},
        )
        resp = client.get(f"/experiments/{exp_id}/jobs")
        assert resp.status_code == 200
        jobs = resp.json()["jobs"]
        assert len(jobs) == 2
        assert [j["job_id"] for j in jobs] == ["a", "b"]


class TestGetJob:
    def test_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.get(f"/experiments/{exp_id}/jobs/a")
        assert resp.status_code == 404

    def test_get_created(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a", "description": "Job A"},
        )
        resp = client.get(f"/experiments/{exp_id}/jobs/a")
        assert resp.status_code == 200
        data = resp.json()
        assert data["job_id"] == "a"
        assert data["exp_id"] == exp_id
        assert data["description"] == "Job A"


class TestCreateJob:
    def test_create(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a", "description": "New job"},
        )
        assert resp.status_code == 201
        data = resp.json()
        assert data["job_id"] == "a"
        assert data["exp_id"] == exp_id
        assert data["opened"] == "N"

    def test_duplicate(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a"},
        )
        resp = client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a"},
        )
        assert resp.status_code == 409

    def test_invalid_job_id(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "ZZ"},
        )
        assert resp.status_code == 422


class TestUpdateJob:
    def test_update(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a", "description": "Original"},
        )
        resp = client.patch(
            f"/experiments/{exp_id}/jobs/a",
            json={"description": "Updated"},
        )
        assert resp.status_code == 200
        assert resp.json()["description"] == "Updated"

    def test_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.patch(
            f"/experiments/{exp_id}/jobs/a",
            json={"description": "Nope"},
        )
        assert resp.status_code == 404


class TestDeleteJob:
    def test_delete(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a"},
        )
        resp = client.delete(f"/experiments/{exp_id}/jobs/a")
        assert resp.status_code == 204

        resp = client.get(f"/experiments/{exp_id}/jobs/a")
        assert resp.status_code == 404

    def test_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.delete(f"/experiments/{exp_id}/jobs/z")
        assert resp.status_code == 404


class TestCopyJob:
    def test_copy_within_experiment(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a", "description": "Source job"},
        )
        resp = client.post(
            f"/experiments/{exp_id}/jobs/a/copy",
            json={
                "dest_exp_id": exp_id,
                "dest_job_id": "b",
                "description": "Copied",
            },
        )
        assert resp.status_code == 201
        data = resp.json()
        assert data["job_id"] == "b"
        assert data["exp_id"] == exp_id
        assert data["description"] == "Copied"

    def test_copy_source_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        resp = client.post(
            f"/experiments/{exp_id}/jobs/z/copy",
            json={
                "dest_exp_id": exp_id,
                "dest_job_id": "a",
            },
        )
        assert resp.status_code == 404

    def test_copy_dest_exists(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        exp_id = _create_experiment(client, user_headers)
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "a"},
        )
        client.post(
            f"/experiments/{exp_id}/jobs",
            json={"job_id": "b"},
        )
        resp = client.post(
            f"/experiments/{exp_id}/jobs/a/copy",
            json={
                "dest_exp_id": exp_id,
                "dest_job_id": "b",
            },
        )
        assert resp.status_code == 409
