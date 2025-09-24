#!/bin/bash

# Claude Code Agent Team Installation Script
# This script installs agent configurations to your Claude Code setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE=Linux;;
    Darwin*)    OS_TYPE=Mac;;
    CYGWIN*)    OS_TYPE=Windows;;
    MINGW*)     OS_TYPE=Windows;;
    *)          OS_TYPE="UNKNOWN:${OS}"
esac

# Configuration - Check multiple possible locations
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"

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

    # Default to standard location
    echo "$HOME/.claude"
    return 0
}

# Find the Claude configuration directory
CLAUDE_CONFIG_DIR="$(find_claude_config_dir)"
CLAUDE_AGENTS_DIR="$CLAUDE_CONFIG_DIR/agents"
BACKUP_DIR="$CLAUDE_CONFIG_DIR/agents.backup"

echo "======================================"
echo "Claude Code Agent Team Installer"
echo "======================================"
echo ""
echo -e "${CYAN}System Information:${NC}"
echo "  OS: $OS_TYPE"
echo "  User: $USER"
echo "  Home: $HOME"
echo "  Claude Config: $CLAUDE_CONFIG_DIR"
echo "  Target Directory: $CLAUDE_AGENTS_DIR"
echo ""

# Verify we're in the right place
echo -e "${CYAN}Installation Source:${NC}"
echo "  Script Location: $SCRIPT_DIR"
echo "  Agents Source: $AGENTS_SOURCE_DIR"
echo ""

# Ask for confirmation
echo -e "${YELLOW}The agents will be installed to:${NC}"
echo -e "  ${BLUE}$CLAUDE_AGENTS_DIR${NC}"
echo ""
read -p "Is this correct? (y/n) [y]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo ""
    echo -e "${YELLOW}Installation cancelled.${NC}"
    echo ""
    echo "If the path is incorrect, you can manually specify it by editing this script"
    echo "or by copying the agents folder to your Claude agents directory:"
    echo ""
    echo "  cp -r $AGENTS_SOURCE_DIR/* ~/.claude/agents/"
    echo ""
    exit 0
fi
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
echo "Installed $AGENT_COUNT agents to:"
echo -e "  ${BLUE}$CLAUDE_AGENTS_DIR${NC}"
echo ""

# Verify installation
echo -e "${CYAN}Verifying installation:${NC}"
INSTALLED_COUNT=$(ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$INSTALLED_COUNT" -ge "$AGENT_COUNT" ]; then
    echo -e "  ${GREEN}✓${NC} All $AGENT_COUNT agents are properly installed"
else
    echo -e "  ${YELLOW}⚠${NC} Found $INSTALLED_COUNT agents (expected $AGENT_COUNT)"
fi

# Check permissions
if [ -r "$CLAUDE_AGENTS_DIR" ] && [ -w "$CLAUDE_AGENTS_DIR" ]; then
    echo -e "  ${GREEN}✓${NC} Directory permissions are correct"
else
    echo -e "  ${YELLOW}⚠${NC} Check directory permissions"
fi

# List first few agents as confirmation
echo ""
echo -e "${CYAN}Sample of installed agents:${NC}"
ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | head -5 | while read agent; do
    echo "  • $(basename "$agent" .md)"
done
if [ "$INSTALLED_COUNT" -gt 5 ]; then
    echo "  ... and $((INSTALLED_COUNT - 5)) more"
fi

echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "1. Restart Claude Code to load the new agents"
echo "2. Type 'claude' in your terminal to start using the agents"
echo ""
echo "To verify agents are loaded, ask Claude Code:"
echo -e "  ${YELLOW}'What agents are available?'${NC}"
echo ""

# Check if backup was created
if [ -L "$BACKUP_DIR" ] || [ -d "$BACKUP_DIR" ]; then
    echo -e "${CYAN}Backup information:${NC}"
    echo "  Previous agents backed up to:"
    echo "  $BACKUP_DIR"
    echo "  To restore: ./restore.sh"
    echo ""
fi

# Provide diagnostic command for Claude Code
echo -e "${CYAN}For Claude Code to verify installation:${NC}"
echo "  Ask: 'Check my agent installation at $CLAUDE_AGENTS_DIR'"
echo ""

echo -e "${GREEN}Happy coding with your new agent team!${NC}"