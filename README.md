# Claude Code Agent Team

A collection of specialized AI agents for Claude Code that enhance your development workflow with task-specific capabilities.

## What is this?

This repository contains configuration files for Claude Code agents - specialized AI assistants that handle specific types of development tasks. These agents work together to provide comprehensive development support, from architecture design to implementation, testing, and optimization.

## Quick Start

### Installation (One Command)

Clone this repository and run the installation script:

```bash
git clone https://github.com/johnpackercoaching/agent_team.git
cd agent_team
./install.sh
```

That's it! The agents are now available in your Claude Code.

### Verify Installation

After installation, verify everything is working:

```bash
./verify.sh
```

This will check that agents are installed in the correct location and accessible to Claude Code.

### Manual Installation

If you prefer manual installation or the script doesn't work:

1. Clone this repository:
   ```bash
   git clone https://github.com/johnpackercoaching/agent_team.git
   ```

2. Copy the agent files to your Claude Code configuration:
   ```bash
   cp agent_team/agents/*.md ~/.claude/agents/
   ```

3. Restart Claude Code to load the new agents

## Available Agents

### Core Orchestration
- **orchestrator** - Main task coordinator that plans and delegates work
- **router-policy** - Routes tasks to the most appropriate specialized agent
- **architect-agent** - System design, architectural decisions, and technical analysis

### Implementation & Development
- **impl-agent** - Implements features and bug fixes within defined scope
- **start-subagent** - Handles large multi-file implementations (>100 LOC)
- **search-agent** - Efficient file, folder, and code searching

### Quality & Performance
- **perf-subagent** - Performance optimization and bottleneck analysis
- **security-subagent** - Security reviews and vulnerability assessment
- **test-subagent** - Test execution and validation
- **run-test** - Coordinates test runs with browser evidence

### Specialized Technical
- **crdt-subagent** - Multi-user editing and conflict resolution
- **ws-subagent** - WebSocket and real-time features implementation
- **question-analyzer** - Decision analysis and trade-off evaluation

### Utility
- **tell-me-a-joke** - Lightens the mood with programming humor
- **willing-tree-navigator** - Project-specific navigation agent

## How to Use Agents

Once installed, agents are automatically available in Claude Code. They can be invoked:

1. **Automatically** - Claude Code will select the right agent based on your task
2. **Explicitly** - Ask Claude Code to use a specific agent:
   ```
   "Use the performance agent to optimize this function"
   "Have the architect agent review this design"
   ```

## Updating Agents

To get the latest agent configurations:

```bash
cd agent_team
git pull
./install.sh
```

## Backup & Restore

Before installing, the script automatically backs up your existing agents:

```bash
# Backup location
~/.claude/agents.backup/

# Restore previous agents
./restore.sh
```

## Contributing

Feel free to customize these agents for your needs! To contribute:

1. Fork this repository
2. Modify or add agent configurations in the `agents/` directory
3. Test your changes locally
4. Submit a pull request

## Agent Configuration Format

Each agent is defined in a markdown file with:
- Agent description and capabilities
- Specific tools the agent can use
- Behavioral guidelines
- Task-specific instructions

## Troubleshooting

### Installation Path Issues

The installer checks multiple possible locations for Claude Code configuration:
- `~/.claude/agents/` (standard location)
- `~/.config/claude/agents/` (Linux XDG)
- `~/Library/Application Support/claude/agents/` (macOS alternative)

**To verify the correct path:**
```bash
./verify.sh
```

This will show you:
- Where Claude is looking for agents
- How many agents are installed
- Which agents might be missing
- Directory permissions

### Agents not appearing in Claude Code
- Restart Claude Code after installation
- Run `./verify.sh` to check installation status
- Check that files are in the correct location (shown by verify.sh)
- Verify file permissions: `ls -la ~/.claude/agents/`

### Installation script shows wrong directory

The installer will show you where it plans to install and ask for confirmation:
```
The agents will be installed to:
  /path/to/your/.claude/agents

Is this correct? (y/n)
```

If the path is wrong:
1. Type 'n' to cancel
2. Manually copy agents: `cp -r agents/*.md ~/.claude/agents/`
3. Or edit the install.sh script to use your custom path

### Claude Code can't find the agents

Ask Claude Code to check the installation:
```
"Check my agent installation at ~/.claude/agents"
```

Claude will verify:
- If the directory exists
- How many agents are found
- If permissions are correct

### Installation script fails
- Use manual installation steps above
- Check that the agents directory exists or can be created
- Ensure you have write permissions
- On Windows, use WSL (Windows Subsystem for Linux)

## Requirements

- Claude Code CLI installed and configured
- macOS or Linux (Windows users: use WSL or adapt paths)
- Basic command line familiarity

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/johnpackercoaching/agent_team/issues)
- Check existing issues for solutions

## License

These agent configurations are shared freely for the Claude Code community. Feel free to use, modify, and share!

---

**Note:** These agents are designed to work with Claude Code's agent system. They won't work with other AI tools or Claude's web interface.
