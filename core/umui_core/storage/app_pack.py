"""Path helpers for the UMUI application pack.

The app pack contains static window definitions, variable registrations,
partition info, navigation tree, skeletons, and help files for a given
UM version.

Layout::

    <app_pack_root>/
        windows/
            nav.spec              - Navigation tree
            *.pan                 - Window definitions
        variables/
            var.register          - Variable definitions
            partition.database    - Partition definitions
        help/
            *.help                - Per-window help text
        skeletons/
            *.skeleton            - Job templates
"""

from __future__ import annotations


class AppPackPaths:
    """Helper for constructing paths within a UMUI app pack."""

    def __init__(self, root: str) -> None:
        self._root = root

    @property
    def root(self) -> str:
        return self._root

    @property
    def windows_dir(self) -> str:
        return f"{self._root}/windows"

    @property
    def variables_dir(self) -> str:
        return f"{self._root}/variables"

    @property
    def help_dir(self) -> str:
        return f"{self._root}/help"

    @property
    def processing_dir(self) -> str:
        return f"{self._root}/processing"

    @property
    def nav_spec(self) -> str:
        return f"{self._root}/windows/nav.spec"

    @property
    def var_register(self) -> str:
        return f"{self._root}/variables/var.register"

    @property
    def partition_database(self) -> str:
        return f"{self._root}/variables/partition.database"

    def window_file(self, win_id: str) -> str:
        """Path to a .pan window definition file."""
        return f"{self._root}/windows/{win_id}.pan"

    def help_file(self, win_id: str) -> str:
        """Path to a .help file for a window."""
        return f"{self._root}/help/{win_id}.help"
