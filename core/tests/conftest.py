"""Shared test fixtures for umui_core tests."""

from __future__ import annotations

from pathlib import Path

import pytest


@pytest.fixture
def fixtures_dir() -> Path:
    """Path to the fixtures directory."""
    return Path(__file__).parent.parent.parent / "fixtures"


@pytest.fixture
def samples_dir(fixtures_dir: Path) -> Path:
    """Path to the sample experiments directory."""
    return fixtures_dir / "samples"


@pytest.fixture
def tmp_db(tmp_path: Path) -> Path:
    """Create a temporary database directory for testing."""
    db = tmp_path / "umui_db"
    db.mkdir()
    return db
