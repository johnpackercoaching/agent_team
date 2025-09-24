#!/bin/bash

# Claude Code Agent Team Installation Script
# This script installs agent configurations to your Claude Code setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
BACKUP_DIR="$HOME/.claude/agents.backup"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"

echo "======================================"
echo "Claude Code Agent Team Installer"
echo "======================================"
echo ""

# Check if agents source directory exists
if [ ! -d "$AGENTS_SOURCE_DIR" ]; then
    echo -e "${RED}Error: Agent files not found in $AGENTS_SOURCE_DIR${NC}"
    echo "Please ensure you're running this script from the agent_team repository."
    exit 1
fi

# Create Claude agents directory if it doesn't exist
if [ ! -d "$CLAUDE_AGENTS_DIR" ]; then
    echo -e "${YELLOW}Creating Claude agents directory...${NC}"
    mkdir -p "$CLAUDE_AGENTS_DIR"
    echo -e "${GREEN}✓ Created $CLAUDE_AGENTS_DIR${NC}"
fi

# Backup existing agents if any exist
if [ -n "$(ls -A "$CLAUDE_AGENTS_DIR" 2>/dev/null)" ]; then
    echo -e "${YELLOW}Backing up existing agents...${NC}"

    # Create backup with timestamp
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    CURRENT_BACKUP="$BACKUP_DIR.$TIMESTAMP"

    mkdir -p "$CURRENT_BACKUP"
    cp -r "$CLAUDE_AGENTS_DIR"/* "$CURRENT_BACKUP/" 2>/dev/null || true

    # Keep symlink to latest backup
    rm -f "$BACKUP_DIR"
    ln -s "$CURRENT_BACKUP" "$BACKUP_DIR"

    echo -e "${GREEN}✓ Backed up to $CURRENT_BACKUP${NC}"
fi

# Count agent files
AGENT_COUNT=$(ls -1 "$AGENTS_SOURCE_DIR"/*.md 2>/dev/null | wc -l)

if [ "$AGENT_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: No agent configuration files found in $AGENTS_SOURCE_DIR${NC}"
    exit 1
fi

# Install agents
echo -e "${YELLOW}Installing $AGENT_COUNT agents...${NC}"
echo ""

# Copy each agent and show progress
for agent_file in "$AGENTS_SOURCE_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    cp "$agent_file" "$CLAUDE_AGENTS_DIR/"
    echo -e "  ${GREEN}✓${NC} Installed: $agent_name"
done

echo ""
echo -e "${GREEN}======================================"
echo -e "Installation Complete!"
echo -e "======================================${NC}"
echo ""
echo "Installed $AGENT_COUNT agents to: $CLAUDE_AGENTS_DIR"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code to load the new agents"
echo "2. Type 'claude' in your terminal to start using the agents"
echo ""
echo "To see available agents, ask Claude Code:"
echo "  'What agents are available?'"
echo ""

# Check if backup was created
if [ -L "$BACKUP_DIR" ]; then
    echo "Previous agents backed up to: $BACKUP_DIR"
    echo "To restore: ./restore.sh"
fi

echo ""
echo -e "${GREEN}Happy coding with your new agent team!${NC}"