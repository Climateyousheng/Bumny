# Runbook

Operational procedures for the UMUI Next system.

## Deployment

### Local development (fixture data)

```bash
# Start API
uv run python -m umui_api --db-path ./fixtures/samples

# Start UI (separate terminal)
cd ui && npm run dev
```

### Local development (live puma2 data via SSH)

Requires SSH config with access to bp14 -> archer2 -> puma2 chain.

```bash
# Create SSH target config
mkdir -p ~/.config/umui
cat > ~/.config/umui/targets.toml << 'EOF'
[targets.puma2]
final_host = "puma2"
db_path = "/home/n02/n02/umui/umui/umui2.0/DBSE"
jump_hosts = ["bp14", "archer2"]
connect_timeout = 30.0
EOF

# Start API with SSH backend
uv run python -m umui_api --target puma2

# Start UI (separate terminal)
cd ui && npm run dev
```

### Production build (frontend only)

```bash
cd ui
npm run build
# Output in ui/dist/ -- serve with any static file server
```

## API Server

### CLI options

```
usage: umui_api [-h] (--db-path DB_PATH | --target TARGET) [--host HOST] [--port PORT]

Options:
  --db-path PATH    Path to local UMUI database directory
  --target NAME     SSH target name from ~/.config/umui/targets.toml
  --host ADDRESS    Bind address (default: 127.0.0.1)
  --port NUMBER     Port number (default: 8000)
```

### Health check

```bash
# List experiments (should return JSON)
curl http://127.0.0.1:8000/experiments
```

### API endpoints

15 endpoints across experiments, jobs, and locks. See README.md for the full table.

Mutating endpoints require the `X-UMUI-User` header:

```bash
curl -X POST http://127.0.0.1:8000/experiments \
  -H "Content-Type: application/json" \
  -H "X-UMUI-User: nd20983" \
  -d '{"initial": "test", "description": "Test experiment"}'
```

## Common Issues and Fixes

### SSH connection failures

**Symptom**: API with `--target puma2` fails to start or drops connections.

**Causes**:
1. SSH keys not configured for the jump chain (bp14 -> archer2 -> puma2)
2. VPN not connected
3. One of the jump hosts is down

**Fix**: Test the SSH chain manually:
```bash
ssh bp14
ssh archer2   # from bp14
ssh puma2     # from archer2
```

### Lock contention

**Symptom**: User cannot acquire lock, sees "locked by <other-user>".

**Resolution**: Locks are stored in the `.job` file's `opened` field. Options:
1. Ask the lock owner to release it via the UI
2. Use the force-acquire option (POST with `{"force": true}`)
3. As a last resort, manually edit the `.job` file to clear the `opened` field

### Frontend proxy errors

**Symptom**: UI shows network errors, API calls fail.

**Cause**: API server is not running on port 8000.

**Fix**: Ensure the API is running before starting the UI dev server:
```bash
uv run python -m umui_api --db-path ./fixtures/samples
```

### Node.js localStorage warnings

**Symptom**: `Warning: --localstorage-file was provided without a valid path` during tests.

**Cause**: Node.js 22+ has a built-in localStorage that conflicts with jsdom's. This is handled by the test setup (`tests/setup.ts`) and can be safely ignored.

### Stale lock after crash

**Symptom**: Job shows as locked but the user's session crashed.

**Resolution**: Use the release lock endpoint or force-acquire:
```bash
# Release
curl -X DELETE http://127.0.0.1:8000/experiments/{exp_id}/jobs/{job_id}/lock \
  -H "X-UMUI-User: <lock-owner>"

# Force acquire
curl -X POST http://127.0.0.1:8000/experiments/{exp_id}/jobs/{job_id}/lock \
  -H "X-UMUI-User: <your-username>" \
  -H "Content-Type: application/json" \
  -d '{"force": true}'
```

## Monitoring

### Lock status polling

The UI polls lock status every 30 seconds. No server-side monitoring is needed for lock contention — it resolves through the polling mechanism.

### Database integrity

The UMUI database is a flat-file directory structure. Integrity checks:

```bash
# Count experiments
ls fixtures/samples/*.exp | wc -l

# Check for orphaned job directories
for dir in fixtures/samples/*/; do
  exp_id=$(basename "$dir")
  if [ ! -f "fixtures/samples/${exp_id}.exp" ]; then
    echo "Orphaned: $dir"
  fi
done
```

## Rollback Procedures

### Frontend rollback

The frontend is a static build. To rollback:
1. Re-deploy the previous `ui/dist/` build
2. Or revert the git commit and rebuild: `cd ui && npm run build`

### Backend rollback

The API is stateless — it reads/writes directly to the database directory. To rollback:
1. Stop the API server
2. `git checkout <previous-commit>`
3. `uv sync`
4. Restart: `uv run python -m umui_api --db-path ./fixtures/samples`

### Data rollback

The database is a directory of flat files. If data corruption occurs:
1. Stop the API server
2. Restore from backup (the production database on puma2 is the canonical copy)
3. Restart the API server

No database migrations exist — the file format is stable across versions.
