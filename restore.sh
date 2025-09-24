#!/bin/bash

# Claude Code Agent Team Restore Script
# This script restores previous agent configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
BACKUP_BASE="$HOME/.claude/agents.backup"

echo "======================================"
echo "Claude Code Agent Restore Tool"
echo "======================================"
echo ""

# Find all backups
BACKUPS=($(ls -d ${BACKUP_BASE}.* 2>/dev/null | sort -r))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No backups found.${NC}"
    echo "Backups are created automatically when you run ./install.sh"
    exit 0
fi

echo "Available backups:"
echo ""

# List backups with numbers
for i in "${!BACKUPS[@]}"; do
    backup="${BACKUPS[$i]}"
    timestamp=$(basename "$backup" | cut -d. -f2)

    # Format timestamp for display
    if [[ "$timestamp" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})$ ]]; then
        formatted_date="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}"
    else
        formatted_date="$timestamp"
    fi

    # Check if this is the latest (symlinked) backup
    if [ "$backup" = "$(readlink -f "$BACKUP_BASE" 2>/dev/null)" ]; then
        echo -e "  ${GREEN}[$((i+1))]${NC} $formatted_date ${BLUE}(latest)${NC}"
    else
        echo -e "  [$((i+1))] $formatted_date"
    fi

    # Show agent count in backup
    agent_count=$(ls -1 "$backup"/*.md 2>/dev/null | wc -l)
    echo "      Agents: $agent_count"
    echo ""
done

# Ask user to select
echo -n "Enter backup number to restore (or 'q' to quit): "
read -r selection

# Handle quit
if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#BACKUPS[@]} ]; then
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
fi

# Get selected backup
SELECTED_BACKUP="${BACKUPS[$((selection-1))]}"

echo ""
echo -e "${YELLOW}Restoring from: $(basename "$SELECTED_BACKUP")${NC}"

# Backup current agents before restoring
if [ -n "$(ls -A "$CLAUDE_AGENTS_DIR" 2>/dev/null)" ]; then
    echo "Backing up current agents first..."

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    CURRENT_BACKUP="$BACKUP_BASE.$TIMESTAMP"

    mkdir -p "$CURRENT_BACKUP"
    cp -r "$CLAUDE_AGENTS_DIR"/* "$CURRENT_BACKUP/" 2>/dev/null || true

    echo -e "${GREEN}✓ Current agents backed up to $CURRENT_BACKUP${NC}"
fi

# Clear current agents directory
echo "Clearing current agents..."
rm -f "$CLAUDE_AGENTS_DIR"/*.md

# Restore selected backup
echo "Restoring agents..."
cp "$SELECTED_BACKUP"/*.md "$CLAUDE_AGENTS_DIR/"

# Count restored agents
RESTORED_COUNT=$(ls -1 "$CLAUDE_AGENTS_DIR"/*.md 2>/dev/null | wc -l)

# Update symlink to point to restored backup
rm -f "$BACKUP_BASE"
ln -s "$SELECTED_BACKUP" "$BACKUP_BASE"

echo ""
echo -e "${GREEN}======================================"
echo -e "Restore Complete!"
echo -e "======================================${NC}"
echo ""
echo "Restored $RESTORED_COUNT agents from backup"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code to load the restored agents"
echo "2. Type 'claude' in your terminal to continue"
echo ""
echo -e "${GREEN}Agents successfully restored!${NC}"