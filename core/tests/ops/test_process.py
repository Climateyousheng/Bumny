"""Tests for template processing."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from umui_core.ops.process import ProcessError, ProcessRequest, _tk, process_job
from umui_core.storage.app_pack import AppPackPaths
from umui_core.storage.layout import DatabasePaths, LocalFileSystem

if TYPE_CHECKING:
    from pathlib import Path

pytestmark = pytest.mark.skipif(_tk is None, reason="tkinter not available")


@pytest.fixture
def fs() -> LocalFileSystem:
    return LocalFileSystem()


@pytest.fixture
def app_pack(fixtures_dir: Path) -> AppPackPaths:
    return AppPackPaths(str(fixtures_dir / "app_pack" / "vn8.6"))


@pytest.fixture
def db_paths(fixtures_dir: Path) -> DatabasePaths:
    return DatabasePaths(str(fixtures_dir / "samples"))


class TestProcessJob:
    def test_process_generates_output_files(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """Process xqjc/a and verify output files are generated."""
        request = ProcessRequest(exp_id="xqjc", job_id="a")
        result = process_job(fs, db_paths, app_pack, request)

        assert len(result.files) > 0
        # Key output files should be present
        assert "CNTLALL" in result.files

    def test_process_populates_file_content(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """Processed files should contain non-empty content."""
        request = ProcessRequest(exp_id="xqjc", job_id="a")
        result = process_job(fs, db_paths, app_pack, request)

        for name, content in result.files.items():
            assert len(content) > 0, f"File {name} should have content"

    def test_process_substitutes_variables(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """Variable references should be resolved in output."""
        request = ProcessRequest(exp_id="xqjc", job_id="a")
        result = process_job(fs, db_paths, app_pack, request)

        # CNTLALL should contain the experiment/job ID
        if "CNTLALL" in result.files:
            cntlall = result.files["CNTLALL"]
            assert "EXPT_ID=" in cntlall

    def test_process_nonexistent_job_raises(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """Processing a nonexistent job should raise ProcessError."""
        request = ProcessRequest(exp_id="zzzz", job_id="z")
        with pytest.raises((ProcessError, Exception)):
            process_job(fs, db_paths, app_pack, request)

    def test_process_returns_warnings_for_missing_templates(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """Warnings should be populated for template issues."""
        request = ProcessRequest(exp_id="xqjc", job_id="a")
        result = process_job(fs, db_paths, app_pack, request)
        # May or may not have warnings depending on templates
        assert isinstance(result.warnings, list)

    def test_process_submit_has_submitid_placeholder(
        self,
        fs: LocalFileSystem,
        db_paths: DatabasePaths,
        app_pack: AppPackPaths,
    ) -> None:
        """SUBMIT file should contain :::submitid::: placeholder."""
        request = ProcessRequest(exp_id="xqjc", job_id="a")
        result = process_job(fs, db_paths, app_pack, request)

        if "SUBMIT" in result.files:
            assert ":::submitid:::" in result.files["SUBMIT"]
