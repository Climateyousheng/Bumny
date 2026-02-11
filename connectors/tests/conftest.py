"""Shared fixtures for connector tests."""

from __future__ import annotations

import pytest
from umui_connectors.config import SshTarget


@pytest.fixture()
def puma2_target() -> SshTarget:
    """A realistic puma2 SSH target for testing."""
    return SshTarget(
        name="puma2",
        final_host="puma2",
        db_path="/home/n02/n02/umui/umui/umui2.0/DBSE",
        jump_hosts=("bp14", "archer2"),
        connect_timeout=30.0,
    )


@pytest.fixture()
def simple_target() -> SshTarget:
    """A minimal single-hop SSH target for testing."""
    return SshTarget(
        name="test-host",
        final_host="test.example.com",
        db_path="/data/db",
    )
