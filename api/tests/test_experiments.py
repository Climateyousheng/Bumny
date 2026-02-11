"""Tests for experiment endpoints."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from starlette.testclient import TestClient


class TestListExperiments:
    def test_empty_db(self, client: TestClient) -> None:
        resp = client.get("/experiments")
        assert resp.status_code == 200
        assert resp.json() == {"experiments": []}

    def test_lists_created(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "First"},
            headers=user_headers,
        )
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Second"},
            headers=user_headers,
        )
        resp = client.get("/experiments")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["experiments"]) == 2
        ids = [e["id"] for e in data["experiments"]]
        assert ids == ["xaaa", "xaab"]


class TestGetExperiment:
    def test_not_found(self, client: TestClient) -> None:
        resp = client.get("/experiments/xaaa")
        assert resp.status_code == 404

    def test_get_created(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "My exp"},
            headers=user_headers,
        )
        resp = client.get("/experiments/xaaa")
        assert resp.status_code == 200
        data = resp.json()
        assert data["id"] == "xaaa"
        assert data["owner"] == "testuser"
        assert data["description"] == "My exp"

    def test_invalid_id(self, client: TestClient) -> None:
        resp = client.get("/experiments/INVALID")
        assert resp.status_code == 422


class TestCreateExperiment:
    def test_create(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        resp = client.post(
            "/experiments",
            json={"initial": "t", "description": "Test"},
            headers=user_headers,
        )
        assert resp.status_code == 201
        data = resp.json()
        assert data["id"] == "taaa"
        assert data["owner"] == "testuser"
        assert data["privacy"] == "N"

    def test_missing_user_header(self, client: TestClient) -> None:
        resp = client.post(
            "/experiments",
            json={"initial": "t", "description": "Test"},
        )
        assert resp.status_code == 400

    def test_sequential_ids(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        r1 = client.post(
            "/experiments",
            json={"initial": "x", "description": "First"},
            headers=user_headers,
        )
        r2 = client.post(
            "/experiments",
            json={"initial": "x", "description": "Second"},
            headers=user_headers,
        )
        assert r1.json()["id"] == "xaaa"
        assert r2.json()["id"] == "xaab"


class TestUpdateExperiment:
    def test_update_description(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Original"},
            headers=user_headers,
        )
        resp = client.patch(
            "/experiments/xaaa",
            json={"description": "Updated"},
            headers=user_headers,
        )
        assert resp.status_code == 200
        assert resp.json()["description"] == "Updated"

    def test_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        resp = client.patch(
            "/experiments/xaaa",
            json={"description": "Nope"},
            headers=user_headers,
        )
        assert resp.status_code == 404

    def test_permission_denied(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Owned"},
            headers=user_headers,
        )
        resp = client.patch(
            "/experiments/xaaa",
            json={"description": "Hacked"},
            headers={"X-UMUI-User": "intruder"},
        )
        assert resp.status_code == 403


class TestDeleteExperiment:
    def test_delete(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "ToDelete"},
            headers=user_headers,
        )
        resp = client.delete("/experiments/xaaa", headers=user_headers)
        assert resp.status_code == 204

        resp = client.get("/experiments/xaaa")
        assert resp.status_code == 404

    def test_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        resp = client.delete("/experiments/xaaa", headers=user_headers)
        assert resp.status_code == 404

    def test_permission_denied(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Owned"},
            headers=user_headers,
        )
        resp = client.delete(
            "/experiments/xaaa",
            headers={"X-UMUI-User": "intruder"},
        )
        assert resp.status_code == 403


class TestCopyExperiment:
    def test_copy(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Source"},
            headers=user_headers,
        )
        resp = client.post(
            "/experiments/xaaa/copy",
            json={"initial": "y", "description": "Copied"},
            headers=user_headers,
        )
        assert resp.status_code == 201
        data = resp.json()
        assert data["id"] == "yaaa"
        assert data["owner"] == "testuser"
        assert data["description"] == "Copied"

    def test_copy_not_found(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        resp = client.post(
            "/experiments/xaaa/copy",
            json={"initial": "y", "description": "Nope"},
            headers=user_headers,
        )
        assert resp.status_code == 404

    def test_no_opened_in_response(
        self, client: TestClient, user_headers: dict[str, str],
    ) -> None:
        """The 'opened' field should not appear in experiment responses."""
        client.post(
            "/experiments",
            json={"initial": "x", "description": "Test"},
            headers=user_headers,
        )
        resp = client.get("/experiments/xaaa")
        assert "opened" not in resp.json()
