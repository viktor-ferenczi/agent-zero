# DockerfileLocal Build Optimization

## Problem

The original `DockerfileLocal` copied the entire source tree (`COPY ./ /git/agent-zero`) **before** installing dependencies. Any source code change invalidated the pip install layer (~54 packages + Playwright), causing full reinstalls on every build.

## Solution

Reordered layers so dependencies (which change rarely) are installed before the source code (which changes often) is copied:

| Step | Layer | Cached when source changes? |
|------|-------|-----------------------------|
| 1 | `COPY ./docker/run/fs/ /` — install/runtime scripts | Yes |
| 2 | `RUN pre_install.sh` — apt update, SSH setup | Yes |
| 3 | `COPY requirements.txt requirements2.txt` — dependency manifests only | Yes |
| 4 | `RUN uv pip install` — Python dependencies | Yes |
| 5 | `RUN install_playwright.sh` — Chromium browser | Yes |
| 6 | `COPY ./ /git/agent-zero` — full source code | **No** (rebuilds from here) |
| 7 | `RUN preload.py` — preload ML models | No |
| 8 | Cleanup + cache purge | No |

## What was removed

- **`install_A02.sh`** — cache-buster that re-runs `install_A0.sh` for CI/production freshness. Not needed for local dev.
- **`install_additional.sh`** — empty script (all content was moved elsewhere previously).
- **`install_A0.sh` call** — replaced with inlined pip install steps so they can live in separate layers from the source-dependent `preload.py`.

## Verification

```bash
# First build (full)
docker build -f DockerfileLocal -t agent-zero-local .

# Change any .py file, then rebuild — layers 1-5 should show CACHED
docker build -f DockerfileLocal -t agent-zero-local .

# Change requirements.txt — layers 4+ should rebuild
docker build -f DockerfileLocal -t agent-zero-local .
```
