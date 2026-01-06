#!/bin/bash
# reflect-hook.sh
# Hook script that triggers automatic reflection at session end
# Invoked by Claude Code's stop hook when "reflect on" is enabled
#
# Usage: This script is called automatically by the stop hook
# Setup: Add to .claude/settings.json hooks configuration

set -e

# Configuration
STATE_FILE="${HOME}/.claude/.reflect-state"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
LOG_FILE="/tmp/reflect-hook.log"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

notify() {
    echo -e "${BLUE}[reflect]${NC} $1"
}

# Check if automatic reflection is enabled
is_enabled() {
    if [[ -f "$STATE_FILE" ]]; then
        local state
        state=$(cat "$STATE_FILE")
        [[ "$state" == "enabled" ]]
    else
        return 1
    fi
}

# Main execution
main() {
    log "Stop hook triggered"
    
    # Check if reflection is enabled
    if ! is_enabled; then
        log "Automatic reflection is disabled, skipping"
        exit 0
    fi
    
    log "Automatic reflection is enabled, analyzing session..."
    notify "Learned from session - analyzing for skill updates..."
    
    # The actual reflection analysis is done by Claude Code itself
    # This hook signals that reflection should occur
    # Claude will:
    # 1. Analyze the conversation for corrections/preferences
    # 2. Update the appropriate skill file
    # 3. Commit to git if configured
    
    # Create a marker file that Claude can check
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > /tmp/.reflect-requested
    
    log "Reflection request marker created"
    notify "Session learnings will be processed"
}

main "$@"
