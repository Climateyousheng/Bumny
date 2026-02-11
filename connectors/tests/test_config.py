"""Tests for SSH target configuration and TOML loading."""

from __future__ import annotations

import pytest
from umui_connectors.config import ConfigError, SshTarget, load_targets


class TestSshTarget:
    """Tests for the SshTarget frozen dataclass."""

    def test_create_minimal(self) -> None:
        target = SshTarget(
            name="test", final_host="host.example.com", db_path="/data"
        )
        assert target.name == "test"
        assert target.final_host == "host.example.com"
        assert target.db_path == "/data"
        assert target.jump_hosts == ()
        assert target.username is None
        assert target.connect_timeout == 30.0

    def test_create_full(self) -> None:
        target = SshTarget(
            name="puma2",
            final_host="puma2",
            db_path="/home/n02/n02/umui/umui/umui2.0/DBSE",
            jump_hosts=("bp14", "archer2"),
            username="nd20983",
            connect_timeout=60.0,
        )
        assert target.jump_hosts == ("bp14", "archer2")
        assert target.username == "nd20983"
        assert target.connect_timeout == 60.0

    def test_frozen(self) -> None:
        target = SshTarget(name="t", final_host="h", db_path="/d")
        with pytest.raises(AttributeError):
            target.name = "changed"  # type: ignore[misc]

    def test_empty_name_raises(self) -> None:
        with pytest.raises(ConfigError, match="name must not be empty"):
            SshTarget(name="", final_host="h", db_path="/d")

    def test_empty_final_host_raises(self) -> None:
        with pytest.raises(ConfigError, match="final_host must not be empty"):
            SshTarget(name="t", final_host="", db_path="/d")

    def test_empty_db_path_raises(self) -> None:
        with pytest.raises(ConfigError, match="db_path must not be empty"):
            SshTarget(name="t", final_host="h", db_path="")

    def test_negative_timeout_raises(self) -> None:
        with pytest.raises(ConfigError, match="connect_timeout must be positive"):
            SshTarget(
                name="t", final_host="h", db_path="/d", connect_timeout=-1.0
            )

    def test_zero_timeout_raises(self) -> None:
        with pytest.raises(ConfigError, match="connect_timeout must be positive"):
            SshTarget(
                name="t", final_host="h", db_path="/d", connect_timeout=0.0
            )


class TestLoadTargets:
    """Tests for the TOML configuration loader."""

    def test_load_single_target(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.puma2]\n'
            'final_host = "puma2"\n'
            'db_path = "/data/DBSE"\n'
            'jump_hosts = ["bp14", "archer2"]\n'
        )
        targets = load_targets(str(p))
        assert "puma2" in targets
        t = targets["puma2"]
        assert t.name == "puma2"
        assert t.final_host == "puma2"
        assert t.db_path == "/data/DBSE"
        assert t.jump_hosts == ("bp14", "archer2")

    def test_load_multiple_targets(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.puma2]\n'
            'final_host = "puma2"\n'
            'db_path = "/data/DBSE"\n'
            '\n'
            '[targets.local]\n'
            'final_host = "localhost"\n'
            'db_path = "/tmp/db"\n'
        )
        targets = load_targets(str(p))
        assert len(targets) == 2
        assert "puma2" in targets
        assert "local" in targets

    def test_load_with_username(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.dev]\n'
            'final_host = "dev.example.com"\n'
            'db_path = "/data"\n'
            'username = "testuser"\n'
        )
        targets = load_targets(str(p))
        assert targets["dev"].username == "testuser"

    def test_load_with_custom_timeout(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.slow]\n'
            'final_host = "slow.example.com"\n'
            'db_path = "/data"\n'
            'connect_timeout = 120.0\n'
        )
        targets = load_targets(str(p))
        assert targets["slow"].connect_timeout == 120.0

    def test_load_no_jump_hosts_default(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.direct]\n'
            'final_host = "host.example.com"\n'
            'db_path = "/data"\n'
        )
        targets = load_targets(str(p))
        assert targets["direct"].jump_hosts == ()

    def test_file_not_found(self) -> None:
        with pytest.raises(ConfigError, match="Config file not found"):
            load_targets("/nonexistent/path/targets.toml")

    def test_invalid_toml(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text("this is not valid toml [[[")
        with pytest.raises(ConfigError, match="Failed to parse"):
            load_targets(str(p))

    def test_missing_targets_section(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text('[other]\nkey = "value"\n')
        with pytest.raises(ConfigError, match=r"Missing or invalid.*targets"):
            load_targets(str(p))

    def test_missing_required_field(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text(
            '[targets.bad]\n'
            'final_host = "host"\n'
            # missing db_path
        )
        with pytest.raises(ConfigError, match="missing required field"):
            load_targets(str(p))

    def test_target_not_a_table(self, tmp_path: object) -> None:
        import pathlib

        p = pathlib.Path(str(tmp_path)) / "targets.toml"
        p.write_text('[targets]\nbad = "not a table"\n')
        with pytest.raises(ConfigError, match="must be a table"):
            load_targets(str(p))
