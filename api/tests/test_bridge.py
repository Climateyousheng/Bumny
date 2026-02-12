"""Tests for bridge editor API endpoints."""

from __future__ import annotations

import gzip
from typing import TYPE_CHECKING

from starlette.testclient import TestClient

if TYPE_CHECKING:
    from pathlib import Path


class TestGetNavTree:
    def test_returns_tree(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/nav")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        assert data[0]["name"] == "modsel"
        assert data[0]["label"] == "Model Selection"
        assert "children" in data[0]

    def test_tree_has_nested_children(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/nav")
        data = resp.json()
        # modsel > personal > personal_gen
        children = data[0]["children"]
        assert len(children) > 0


class TestGetWindow:
    def test_get_entry_window(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/atmos_Domain_Horiz")
        assert resp.status_code == 200
        data = resp.json()
        assert data["win_id"] == "atmos_Domain_Horiz"
        assert data["win_type"] == "entry"
        assert isinstance(data["components"], list)
        assert len(data["components"]) > 0

    def test_get_dummy_window(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/atmos_STASH_tcl")
        assert resp.status_code == 200
        data = resp.json()
        assert data["win_type"] == "dummy"

    def test_missing_window(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/nonexistent")
        assert resp.status_code == 400

    def test_component_has_kind(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/atmos_Domain_Horiz")
        data = resp.json()
        first = data["components"][0]
        assert "kind" in first


class TestGetWindowHelp:
    def test_existing_help(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/atmos_Domain_Horiz/help")
        assert resp.status_code == 200
        data = resp.json()
        assert data["win_id"] == "atmos_Domain_Horiz"
        assert len(data["text"]) > 0

    def test_missing_help(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/windows/nonexistent/help")
        assert resp.status_code == 200
        data = resp.json()
        assert data["text"] == ""


class TestGetRegister:
    def test_returns_registrations(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/register")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 1000

        first = data[0]
        assert "name" in first
        assert "var_type" in first
        assert "validation_type" in first


class TestGetPartitions:
    def test_returns_partitions(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/partitions")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) >= 10

        keys = {p["key"] for p in data}
        assert "a" in keys


class TestGetVariables:
    def test_read_variables(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/variables/xqgt/a")
        assert resp.status_code == 200
        data = resp.json()
        assert "variables" in data
        assert len(data["variables"]) > 100

    def test_missing_basis(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/variables/xqgt/q")
        assert resp.status_code == 404


class TestGetVariablesForWindow:
    def test_scoped_variables(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get(
            "/bridge/variables/xqgt/a/atmos_Domain_Horiz"
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "variables" in data
        # Should contain OCAAA (defined in this window)
        # Might be empty if var.register doesn't have entries for this window
        assert isinstance(data["variables"], dict)


class TestGetBasisRaw:
    def test_returns_raw_content(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/basis/xqgt/a/raw")
        assert resp.status_code == 200
        data = resp.json()
        assert "content" in data
        assert "line_count" in data
        assert data["line_count"] > 1000
        # Basis files contain namelist groups starting with &
        assert " &" in data["content"]

    def test_missing_basis(self, bridge_client: TestClient) -> None:
        resp = bridge_client.get("/bridge/basis/xqgt/q/raw")
        assert resp.status_code == 404


class TestUpdateVariables:
    def test_update_and_read_back(
        self,
        tmp_path: Path,
        user_headers: dict[str, str],
    ) -> None:
        """Create a temp DB, write variables, and read back."""
        from umui_api.app import create_app
        from umui_core.storage.layout import LocalFileSystem

        db = tmp_path / "db"
        db.mkdir()
        exp_dir = db / "test"
        exp_dir.mkdir()

        # Create basis file
        content = " &g1\n MYVAR=42\n &END\n"
        (exp_dir / "a.gz").write_bytes(gzip.compress(content.encode()))

        fixtures = tmp_path / "pack"
        fixtures.mkdir()
        (fixtures / "windows").mkdir()
        (fixtures / "variables").mkdir()
        (fixtures / "help").mkdir()
        (fixtures / "windows" / "nav.spec").write_text("")
        (fixtures / "variables" / "var.register").write_text("")
        (fixtures / "variables" / "partition.database").write_text("")

        app = create_app(
            fs=LocalFileSystem(),
            db_path=str(db),
            app_pack_path=str(fixtures),
        )
        client = TestClient(app)

        # Read current
        resp = client.get("/bridge/variables/test/a")
        assert resp.status_code == 200
        assert resp.json()["variables"]["MYVAR"] == "42"

        # Update
        resp = client.patch(
            "/bridge/variables/test/a",
            json={"variables": {"MYVAR": "99"}},
            headers=user_headers,
        )
        assert resp.status_code == 200

        # Read back
        resp = client.get("/bridge/variables/test/a")
        assert resp.status_code == 200
        assert resp.json()["variables"]["MYVAR"] == "99"
