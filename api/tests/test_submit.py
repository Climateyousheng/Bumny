"""Tests for submit API endpoint."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from starlette.testclient import TestClient


class TestSubmitEndpoint:
    def test_submit_rejects_local_fs(self, bridge_client: TestClient) -> None:
        """Submit should return 400 when backend is LocalFileSystem."""
        response = bridge_client.post(
            "/submit/xqjc/a",
            json={
                "target_host": "archer2",
                "target_user": "nd20983",
                "processed_files": {"SUBMIT": "#!/bin/ksh"},
            },
        )
        assert response.status_code == 400
        assert "SSH backend" in response.json()["detail"]
