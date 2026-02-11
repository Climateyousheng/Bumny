"""SSH target configuration and TOML loader."""

from __future__ import annotations

import tomllib
from dataclasses import dataclass
from pathlib import Path


class ConfigError(Exception):
    """Raised when configuration is invalid or cannot be loaded."""


@dataclass(frozen=True)
class SshTarget:
    """Immutable SSH connection target.

    Attributes:
        name: Human-readable target name (e.g. 'puma2').
        final_host: Hostname of the final SSH destination.
        db_path: Absolute path to the UMUI database on the target.
        jump_hosts: Intermediate hosts for multi-hop tunneling, in order.
        username: SSH username. None means use current system user.
        connect_timeout: Timeout in seconds for each SSH connection.
    """

    name: str
    final_host: str
    db_path: str
    jump_hosts: tuple[str, ...] = ()
    username: str | None = None
    connect_timeout: float = 30.0

    def __post_init__(self) -> None:
        if not self.name:
            raise ConfigError("Target name must not be empty")
        if not self.final_host:
            raise ConfigError("final_host must not be empty")
        if not self.db_path:
            raise ConfigError("db_path must not be empty")
        if self.connect_timeout <= 0:
            raise ConfigError("connect_timeout must be positive")


def _default_config_path() -> Path:
    """Return the default targets config path."""
    return Path.home() / ".config" / "umui" / "targets.toml"


def load_targets(path: str | None = None) -> dict[str, SshTarget]:
    """Load SSH targets from a TOML configuration file.

    Args:
        path: Path to the TOML file. Defaults to ~/.config/umui/targets.toml.

    Returns:
        Mapping of target name to SshTarget.

    Raises:
        ConfigError: If the file is missing, unparseable, or has invalid data.
    """
    config_path = Path(path) if path else _default_config_path()

    if not config_path.exists():
        raise ConfigError(f"Config file not found: {config_path}")

    try:
        raw = config_path.read_bytes()
        data = tomllib.loads(raw.decode("utf-8"))
    except (tomllib.TOMLDecodeError, UnicodeDecodeError) as exc:
        raise ConfigError(f"Failed to parse {config_path}: {exc}") from exc

    targets_section = data.get("targets")
    if not isinstance(targets_section, dict):
        raise ConfigError(
            f"Missing or invalid [targets] section in {config_path}"
        )

    result: dict[str, SshTarget] = {}
    for name, values in targets_section.items():
        if not isinstance(values, dict):
            raise ConfigError(f"Target '{name}' must be a table")
        try:
            jump = values.get("jump_hosts", [])
            result[name] = SshTarget(
                name=name,
                final_host=values["final_host"],
                db_path=values["db_path"],
                jump_hosts=tuple(jump) if isinstance(jump, list) else (jump,),
                username=values.get("username"),
                connect_timeout=float(
                    values.get("connect_timeout", 30.0)
                ),
            )
        except KeyError as exc:
            raise ConfigError(
                f"Target '{name}' missing required field: {exc}"
            ) from exc

    return result
