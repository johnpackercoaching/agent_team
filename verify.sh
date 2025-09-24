#!/bin/bash

# Claude Code Agent Team Verification Script
# This script helps verify that agents are correctly installed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "======================================"
echo "Claude Code Agent Verification"
echo "======================================"
echo ""

# Function to find Claude config directory
find_claude_config_dir() {
    local possible_dirs=(
        "$HOME/.claude"
        "$HOME/.config/claude"
        "$HOME/Library/Application Support/claude"
        "${XDG_CONFIG_HOME:-$HOME/.config}/claude"
    )

    for dir in "${possible_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done

    echo ""
    return 1
}

# Check Claude configuration
echo -e "${CYAN}Checking Claude Code configuration...${NC}"
echo ""

CLAUDE_CONFIG_DIR="$(find_claude_config_dir)"

if [ -z "$CLAUDE_CONFIG_DIR" ]; then
    echo -e "${RED}✗ Claude configuration directory not found${NC}"
    echo ""
    echo "Expected locations checked:"
    echo "  • $HOME/.claude"
    echo "  • $HOME/.config/claude"
    echo "  • $HOME/Library/Application Support/claude"
    echo ""
    echo -e "${YELLOW}Please ensure Claude Code is installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found Claude config:${NC} $CLAUDE_CONFIG_DIR"

# Check agents directory
CLAUDE_AGENTS_DIR="$CLAUDE_CONFIG_DIR/agents"

if [ ! -d "$CLAUDE_AGENTS_DIR" ]; then
    echo -e "${RED}✗ Agents directory does not exist${NC}"
    echo "  Expected at: $CLAUDE_AGENTS_DIR"
    echo ""
    echo "To fix: Run ./install.sh to create and populate the agents directory"
    exit 1
fi

echo -e "${GREEN}✓ Agents directory exists:${NC} $CLAUDE_AGENTS_DIR"

# Count installed agents
AGENT_COUNT=$(ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$AGENT_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ No agents found${NC}"
    echo ""
    echo "To fix: Run ./install.sh to install the agents"
    exit 1
fi

echo -e "${GREEN}✓ Found $AGENT_COUNT agents installed${NC}"
echo ""

# List all agents
echo -e "${CYAN}Installed agents:${NC}"
ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | while read agent_file; do
    agent_name=$(basename "$agent_file" .md)
    agent_size=$(wc -l < "$agent_file" | tr -d ' ')

    # Check if file is readable and has content
    if [ -r "$agent_file" ] && [ "$agent_size" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} $agent_name ($agent_size lines)"
    else
        echo -e "  ${YELLOW}⚠${NC} $agent_name (empty or unreadable)"
    fi
done

echo ""

# Check permissions
echo -e "${CYAN}Directory permissions:${NC}"
if [ -r "$CLAUDE_AGENTS_DIR" ]; then
    echo -e "  ${GREEN}✓${NC} Directory is readable"
else
    echo -e "  ${RED}✗${NC} Directory is not readable"
fi

if [ -w "$CLAUDE_AGENTS_DIR" ]; then
    echo -e "  ${GREEN}✓${NC} Directory is writable"
else
    echo -e "  ${YELLOW}⚠${NC} Directory is not writable (updates may fail)"
fi

echo ""

# Expected agents check
EXPECTED_AGENTS=(
    "orchestrator"
    "architect-agent"
    "impl-agent"
    "search-agent"
    "router-policy"
)

echo -e "${CYAN}Core agents check:${NC}"
MISSING_AGENTS=()
for agent in "${EXPECTED_AGENTS[@]}"; do
    if [ -f "$CLAUDE_AGENTS_DIR/$agent.md" ]; then
        echo -e "  ${GREEN}✓${NC} $agent"
    else
        echo -e "  ${RED}✗${NC} $agent (missing)"
        MISSING_AGENTS+=("$agent")
    fi
done

echo ""

# Overall status
echo "======================================"
if [ ${#MISSING_AGENTS[@]} -eq 0 ] && [ "$AGENT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ All systems operational!${NC}"
    echo ""
    echo "Your Claude Code agents are properly installed and ready to use."
    echo ""
    echo "To use the agents:"
    echo "1. Restart Claude Code if you haven't already"
    echo "2. Ask Claude: 'What agents are available?'"
else
    echo -e "${YELLOW}⚠ Installation needs attention${NC}"
    echo ""
    if [ ${#MISSING_AGENTS[@]} -gt 0 ]; then
        echo "Missing core agents: ${MISSING_AGENTS[*]}"
        echo "Run ./install.sh to reinstall"
    fi
fi
echo "======================================"

# Output for Claude Code to parse
echo ""
echo -e "${CYAN}For Claude Code:${NC}"
echo "CLAUDE_AGENTS_DIR=$CLAUDE_AGENTS_DIR"
echo "AGENT_COUNT=$AGENT_COUNT"
echo "STATUS=$([ ${#MISSING_AGENTS[@]} -eq 0 ] && echo "OK" || echo "INCOMPLETE")"