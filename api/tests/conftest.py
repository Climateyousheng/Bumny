"""Shared test fixtures for umui_api tests."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from starlette.testclient import TestClient
from umui_api.app import create_app
from umui_core.storage.layout import LocalFileSystem

if TYPE_CHECKING:
    from pathlib import Path


@pytest.fixture
def tmp_db(tmp_path: Path) -> Path:
    """Create a temporary database directory."""
    db = tmp_path / "umui_db"
    db.mkdir()
    return db


@pytest.fixture
def client(tmp_db: Path) -> TestClient:
    """Synchronous test client backed by a temp local DB."""
    app = create_app(fs=LocalFileSystem(), db_path=str(tmp_db))
    return TestClient(app)


@pytest.fixture
def user_headers() -> dict[str, str]:
    """Default headers with a test user."""
    return {"X-UMUI-User": "testuser"}
