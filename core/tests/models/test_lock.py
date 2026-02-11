"""Tests for the Lock domain model."""

from __future__ import annotations

from umui_core.models import Lock, LockResult


class TestLock:
    def test_key_format(self) -> None:
        lock = Lock(exp_id="xqjc", job_id="a", owner="nd20983")
        assert lock.key == "xqjc/a"

    def test_frozen(self) -> None:
        lock = Lock(exp_id="xqjc", job_id="a", owner="nd20983")
        try:
            lock.owner = "other"  # type: ignore[misc]
            raise AssertionError("Should have raised FrozenInstanceError")
        except AttributeError:
            pass

    def test_timestamp_auto_set(self) -> None:
        lock = Lock(exp_id="xqjc", job_id="a", owner="nd20983")
        assert lock.timestamp > 0


class TestLockResult:
    def test_success(self) -> None:
        result = LockResult(
            success=True, owner="nd20983", message=""
        )
        assert result.success is True
        assert result.forced is False

    def test_failure(self) -> None:
        result = LockResult(
            success=False, owner="other", message="Locked by other"
        )
        assert result.success is False

    def test_forced(self) -> None:
        result = LockResult(
            success=True, owner="nd20983", message="Forced", forced=True
        )
        assert result.forced is True
