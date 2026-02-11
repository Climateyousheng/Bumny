"""Shared test fixtures for umui_api tests."""

from __future__ import annotations

from pathlib import Path

import pytest
from starlette.testclient import TestClient
from umui_api.app import create_app
from umui_core.storage.layout import LocalFileSystem


@pytest.fixture
def fixtures_dir() -> Path:
    """Path to the fixtures directory."""
    return Path(__file__).parent.parent.parent / "fixtures"


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
def bridge_client(fixtures_dir: Path) -> TestClient:
    """Test client with real fixtures for bridge endpoint testing."""
    app = create_app(
        fs=LocalFileSystem(),
        db_path=str(fixtures_dir / "samples"),
        app_pack_path=str(fixtures_dir / "app_pack" / "vn8.6"),
    )
    return TestClient(app)


@pytest.fixture
def user_headers() -> dict[str, str]:
    """Default headers with a test user."""
    return {"X-UMUI-User": "testuser"}
