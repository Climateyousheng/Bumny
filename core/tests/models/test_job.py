"""Tests for the Job domain model."""

from __future__ import annotations

from umui_core.models import Job


def _make_job(**overrides: str) -> Job:
    defaults = {
        "job_id": "a",
        "exp_id": "xqjc",
        "version": "8.6",
        "description": "Test job",
        "opened": "N",
        "atmosphere": "Global",
        "ocean": "Global",
        "slab": "",
        "mesoscale": "",
    }
    defaults.update(overrides)
    return Job(**defaults)


class TestJobImmutability:
    def test_frozen(self) -> None:
        job = _make_job()
        try:
            job.opened = "someone"  # type: ignore[misc]
            raise AssertionError("Should have raised FrozenInstanceError")
        except AttributeError:
            pass


class TestJobLocking:
    def test_not_locked_when_n(self) -> None:
        job = _make_job(opened="N")
        assert job.is_locked() is False
        assert job.locked_by() is None

    def test_not_locked_when_empty(self) -> None:
        job = _make_job(opened="")
        assert job.is_locked() is False
        assert job.locked_by() is None

    def test_locked_when_user(self) -> None:
        job = _make_job(opened="nd20983")
        assert job.is_locked() is True
        assert job.locked_by() == "nd20983"
