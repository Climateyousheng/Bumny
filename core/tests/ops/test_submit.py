"""Tests for submit handler."""

from __future__ import annotations

import re
from unittest.mock import MagicMock

import pytest
from umui_core.ops.submit import (
    SubmitError,
    SubmitRequest,
    _generate_submit_id,
    submit_job,
)


@pytest.fixture
def mock_ssh_fs() -> MagicMock:
    """Mock SshFileSystem with run_command and write_text."""
    fs = MagicMock()
    fs.run_command = MagicMock(return_value=("", "", 0))
    fs.write_text = MagicMock()
    return fs


class TestGenerateSubmitId:
    def test_format_is_nine_digits(self) -> None:
        submit_id = _generate_submit_id()
        assert len(submit_id) == 9
        assert submit_id.isdigit()

    def test_day_portion_is_valid(self) -> None:
        submit_id = _generate_submit_id()
        day = int(submit_id[:3])
        assert 1 <= day <= 366


class TestSubmitJob:
    def test_successful_submit(self, mock_ssh_fs: MagicMock) -> None:
        mock_ssh_fs.run_command = MagicMock(
            return_value=("Submitted job 12345", "", 0)
        )

        request = SubmitRequest(
            exp_id="xqjc",
            job_id="a",
            target_host="archer2",
            target_user="nd20983",
            processed_files={
                "SUBMIT": "#!/bin/ksh\nSUBMITID=:::submitid:::\necho done",
                "CNTLALL": "control file",
            },
        )

        result = submit_job(mock_ssh_fs, request)

        assert result.success is True
        assert result.exit_status == 0
        assert "Submitted job 12345" in result.submit_stdout
        assert len(result.submit_id) == 9
        assert "xqjca-" in result.remote_dir

    def test_substitutes_submitid_placeholder(
        self, mock_ssh_fs: MagicMock,
    ) -> None:
        request = SubmitRequest(
            exp_id="xqjc",
            job_id="a",
            target_host="archer2",
            target_user="nd20983",
            processed_files={
                "SUBMIT": "SUBMITID=:::submitid:::",
            },
        )

        submit_job(mock_ssh_fs, request)

        # Check that write_text was called with resolved submitid
        calls = mock_ssh_fs.write_text.call_args_list
        submit_call = next(c for c in calls if "SUBMIT" in c[0][0])
        written_content = submit_call[0][1]
        assert ":::submitid:::" not in written_content
        assert re.match(r"SUBMITID=\d{9}", written_content)

    def test_failed_submit_returns_error_status(
        self, mock_ssh_fs: MagicMock,
    ) -> None:
        # mkdir succeeds, chmod succeeds, SUBMIT fails
        mock_ssh_fs.run_command = MagicMock(
            side_effect=[
                ("", "", 0),  # mkdir
                ("", "", 0),  # chmod
                ("", "Permission denied", 1),  # SUBMIT
            ],
        )

        request = SubmitRequest(
            exp_id="xqjc",
            job_id="a",
            target_host="archer2",
            target_user="nd20983",
            processed_files={"SUBMIT": "#!/bin/ksh\nexit 1"},
        )

        result = submit_job(mock_ssh_fs, request)

        assert result.success is False
        assert result.exit_status == 1
        assert "Permission denied" in result.submit_stderr

    def test_mkdir_failure_raises_submit_error(
        self, mock_ssh_fs: MagicMock,
    ) -> None:
        mock_ssh_fs.run_command = MagicMock(
            side_effect=RuntimeError("mkdir failed"),
        )

        request = SubmitRequest(
            exp_id="xqjc",
            job_id="a",
            target_host="archer2",
            target_user="nd20983",
            processed_files={"SUBMIT": "#!/bin/ksh"},
        )

        with pytest.raises(SubmitError, match="remote directory"):
            submit_job(mock_ssh_fs, request)

    def test_no_submit_script(self, mock_ssh_fs: MagicMock) -> None:
        request = SubmitRequest(
            exp_id="xqjc",
            job_id="a",
            target_host="archer2",
            target_user="nd20983",
            processed_files={"CNTLALL": "control file only"},
        )

        result = submit_job(mock_ssh_fs, request)

        assert result.success is False
        assert "No SUBMIT" in result.submit_stderr
