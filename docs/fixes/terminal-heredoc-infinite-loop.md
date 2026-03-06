# Terminal Heredoc Infinite Loop Fix

## Problem

The agent gets stuck in an infinite loop when trying to write file contents using heredoc syntax (`cat << 'EOF'`). This was observed with the OpenRouter `z-ai/glm-4.5-air:free` model but can affect any model.

### Reproduction

1. Agent decides to write a multi-line file using `cat > file.ext << 'EOF'`
2. The heredoc command hangs in the PTY — the shell shows a `>` continuation prompt which isn't recognized
3. After 30s timeout, the session is marked `running = True` but never cleared
4. Every subsequent command attempt is blocked by `handle_running_session()` returning the "still running" warning
5. The agent retries the same approach, creating an infinite loop of 25+ iterations

### Root Cause Chain

1. **Broken venv prompt pattern**: `r"\\(venv\\).+[$#] ?$"` matched `\(venv\)` with literal backslashes instead of `(venv)` with parentheses, so many prompts went undetected
2. **No heredoc continuation detection**: The `>` continuation prompt wasn't in `dialog_patterns`, so it wasn't recognized as interactive input
3. **No auto-reset for stuck sessions**: Once `running = True`, the flag could only be cleared by detecting a shell prompt — if that never happened, the session was permanently locked
4. **Insufficient prompt guidance**: The "still running" message didn't tell the agent to use `reset: true` or avoid heredoc syntax

## Solution

### 1. Fixed prompt patterns (`code_execution_tool.py`)

- Fixed venv pattern from `r"\\(venv\\).+[$#] ?$"` to `r"\(venv\).+[$#] ?$"`
- Added generic `r"[$#] ?$"` pattern as fallback for any prompt ending with `$` or `#`
- Added `r"^> ?$"` to `dialog_patterns` to detect heredoc/continuation prompts

### 2. Auto-reset stuck sessions (`code_execution_tool.py`)

- Added `stuck_count` field to `ShellWrap` dataclass
- `handle_running_session()` increments `stuck_count` on each call where the session can't be cleared
- After 3 consecutive stuck detections (`STUCK_SESSION_AUTO_RESET_THRESHOLD`), the session is automatically reset
- `mark_session_idle()` resets `stuck_count` to 0

### 3. Updated prompt templates

- `fw.code.running.md`: Added guidance to use `reset: true` and avoid heredoc syntax
- `fw.code.no_out_time.md`: Added same guidance about heredoc hangs

## Files Changed

| File | Change |
|------|--------|
| `python/tools/code_execution_tool.py` | Fixed prompt patterns, added `stuck_count`, auto-reset logic, heredoc dialog detection |
| `prompts/fw.code.running.md` | Added heredoc avoidance guidance |
| `prompts/fw.code.no_out_time.md` | Added heredoc avoidance guidance |

## Impact

- Sessions stuck on heredoc commands will auto-reset after 3 attempts instead of looping indefinitely
- The agent is instructed to use `python3 -c "..."` or `tee` instead of heredoc for file writes
- More shell prompts are correctly detected, reducing false "still running" states
