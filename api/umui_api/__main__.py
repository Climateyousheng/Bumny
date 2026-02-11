"""CLI entry point: ``python -m umui_api``."""

from __future__ import annotations

import argparse


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        prog="umui_api",
        description="Run the UMUI REST API server.",
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--db-path",
        help="Path to local UMUI database directory.",
    )
    group.add_argument(
        "--target",
        help="SSH target name from targets.toml.",
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Bind address (default: 127.0.0.1).",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="Port number (default: 8000).",
    )

    args = parser.parse_args(argv)

    import uvicorn

    if args.db_path:
        from umui_api.app import create_app

        app = create_app(db_path=args.db_path)
    else:
        from umui_connectors import SshFileSystem, load_targets

        from umui_api.app import create_app

        targets = load_targets()
        target = targets[args.target]
        fs = SshFileSystem(target)
        app = create_app(fs=fs, db_path=target.db_path)

    uvicorn.run(app, host=args.host, port=args.port)


if __name__ == "__main__":
    main()
