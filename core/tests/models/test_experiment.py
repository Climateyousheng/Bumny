"""Tests for the Experiment domain model."""

from __future__ import annotations

from umui_core.models import Experiment


def _make_experiment(**overrides: str) -> Experiment:
    defaults = {
        "id": "xqjc",
        "owner": "nd20983",
        "description": "Test experiment",
        "version": "8.6",
        "access_list": "",
        "privacy": "N",
        "atmosphere": "Global",
        "ocean": "Global",
        "slab": "",
        "mesoscale": "",
        "opened": "N",
    }
    defaults.update(overrides)
    return Experiment(**defaults)


class TestExperimentImmutability:
    def test_frozen(self) -> None:
        exp = _make_experiment()
        try:
            exp.owner = "other"  # type: ignore[misc]
            raise AssertionError("Should have raised FrozenInstanceError")
        except AttributeError:
            pass


class TestExperimentPrivacy:
    def test_public_when_privacy_n(self) -> None:
        exp = _make_experiment(privacy="N")
        assert exp.is_public() is True

    def test_public_when_privacy_unset(self) -> None:
        exp = _make_experiment(privacy="Unset")
        assert exp.is_public() is True

    def test_public_when_privacy_empty(self) -> None:
        exp = _make_experiment(privacy="")
        assert exp.is_public() is True

    def test_private_when_privacy_y(self) -> None:
        exp = _make_experiment(privacy="Y")
        assert exp.is_public() is False


class TestExperimentAccess:
    def test_anyone_can_view_public(self) -> None:
        exp = _make_experiment(privacy="N")
        assert exp.has_access("stranger") is True

    def test_owner_can_view_private(self) -> None:
        exp = _make_experiment(privacy="Y", owner="nd20983")
        assert exp.has_access("nd20983") is True

    def test_access_list_user_can_view_private(self) -> None:
        exp = _make_experiment(
            privacy="Y",
            owner="nd20983",
            access_list="colleague1 colleague2",
        )
        assert exp.has_access("colleague1") is True
        assert exp.has_access("colleague2") is True

    def test_stranger_cannot_view_private(self) -> None:
        exp = _make_experiment(privacy="Y", owner="nd20983", access_list="")
        assert exp.has_access("stranger") is False


class TestExperimentWritePermission:
    def test_owner_has_write(self) -> None:
        exp = _make_experiment(owner="nd20983")
        assert exp.has_write_permission("nd20983") is True

    def test_access_list_user_has_write(self) -> None:
        exp = _make_experiment(
            owner="nd20983", access_list="colleague1"
        )
        assert exp.has_write_permission("colleague1") is True

    def test_stranger_no_write(self) -> None:
        exp = _make_experiment(owner="nd20983", access_list="")
        assert exp.has_write_permission("stranger") is False
