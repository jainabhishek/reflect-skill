#!/bin/bash
# reflect-toggle.sh
# Manages the reflect on/off/status toggle for automatic reflection
#
# Usage:
#   reflect-toggle.sh on      # Enable automatic reflection
#   reflect-toggle.sh off     # Disable automatic reflection
#   reflect-toggle.sh status  # Show current state

set -e

# Configuration
STATE_DIR="${HOME}/.claude"
STATE_FILE="${STATE_DIR}/.reflect-state"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure state directory exists
mkdir -p "$STATE_DIR"

show_status() {
    if [[ -f "$STATE_FILE" ]]; then
        local state
        state=$(cat "$STATE_FILE")
        if [[ "$state" == "enabled" ]]; then
            echo -e "${GREEN}✓${NC} Automatic reflection is ${GREEN}ON${NC}"
            echo "  Sessions will auto-reflect on stop"
        else
            echo -e "${YELLOW}○${NC} Automatic reflection is ${YELLOW}OFF${NC}"
            echo "  Use 'reflect on' to enable"
        fi
    else
        echo -e "${YELLOW}○${NC} Automatic reflection is ${YELLOW}OFF${NC} (not configured)"
        echo "  Use 'reflect on' to enable"
    fi
}

enable_reflect() {
    echo "enabled" > "$STATE_FILE"
    echo -e "${GREEN}✓${NC} Automatic reflection ${GREEN}enabled${NC}"
    echo ""
    echo "Claude will now analyze sessions for learnings when they end."
    echo "Learnings will be extracted and saved to skill files automatically."
    echo ""
    echo -e "${BLUE}Tip:${NC} Make sure the stop hook is configured in .claude/settings.json"
}

disable_reflect() {
    echo "disabled" > "$STATE_FILE"
    echo -e "${YELLOW}○${NC} Automatic reflection ${YELLOW}disabled${NC}"
    echo ""
    echo "Use '/reflect' manually to extract learnings from sessions."
}

show_help() {
    echo "Usage: reflect-toggle.sh [on|off|status]"
    echo ""
    echo "Commands:"
    echo "  on      Enable automatic reflection on session end"
    echo "  off     Disable automatic reflection"
    echo "  status  Show current reflection mode"
    echo ""
    echo "When enabled, Claude will automatically analyze sessions"
    echo "for corrections and preferences, then update skill files."
}

case "${1:-status}" in
    on|enable)
        enable_reflect
        ;;
    off|disable)
        disable_reflect
        ;;
    status)
        show_status
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
