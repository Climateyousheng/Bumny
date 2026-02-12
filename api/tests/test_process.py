"""Tests for process API endpoint."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.ops.process import _tk

if TYPE_CHECKING:
    from starlette.testclient import TestClient

pytestmark = pytest.mark.skipif(_tk is None, reason="tkinter not available")


class TestProcessEndpoint:
    def test_process_success(self, bridge_client: TestClient) -> None:
        """Process xqjc/a should return files."""
        response = bridge_client.post("/process/xqjc/a")
        assert response.status_code == 200

        data = response.json()
        assert "files" in data
        assert "warnings" in data
        assert isinstance(data["files"], dict)
        assert isinstance(data["warnings"], list)

    def test_process_returns_cntlall(self, bridge_client: TestClient) -> None:
        """Process should generate a CNTLALL file."""
        response = bridge_client.post("/process/xqjc/a")
        assert response.status_code == 200

        data = response.json()
        assert "CNTLALL" in data["files"]

    def test_process_nonexistent_job(self, bridge_client: TestClient) -> None:
        """Process a nonexistent job should return error."""
        response = bridge_client.post("/process/zzzz/z")
        assert response.status_code in (404, 500)

    def test_process_invalid_exp_id(self, bridge_client: TestClient) -> None:
        """Invalid experiment ID should return 422."""
        response = bridge_client.post("/process/INVALID/a")
        assert response.status_code == 422
