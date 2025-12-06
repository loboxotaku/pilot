# Pilot - NSAI Ecosystem CLI/REPL

## Project Summary

Pilot is an interactive command-line interface and REPL for the North Shore AI (NSAI) ecosystem, providing unified access to job management, experiment running, service monitoring, dataset operations, and metrics querying.

## Repository Information

- **Location**: `/home/home/p/g/North-Shore-AI/pilot`
- **GitHub**: https://github.com/North-Shore-AI/pilot
- **Language**: Elixir 1.18+
- **Build Type**: Escript (standalone executable)

## Architecture

### Core Components

1. **CLI Module** (`lib/pilot/cli.ex`)
   - Main entry point using Optimus for argument parsing
   - Routes commands to appropriate handlers
   - Supports nested subcommands for different domains

2. **Configuration** (`lib/pilot/config.ex`)
   - Agent-based configuration management
   - Loads from `~/.pilot/config.yaml`
   - Supports environment variable overrides
   - Thread-safe nested key updates

3. **Output Formatting** (`lib/pilot/output.ex`)
   - Multiple output formats: table, JSON, YAML
   - TableRex integration for human-readable tables
   - Colored output for success/error/warning messages
   - Spinner support for long-running operations

4. **HTTP Client** (`lib/pilot/client.ex`)
   - Req-based HTTP client with retry logic
   - Service URL management from configuration
   - Automatic transient error retry
   - Configurable timeouts

5. **Interactive REPL** (`lib/pilot/repl.ex`)
   - Elixir code evaluation
   - Command shortcuts (jobs.list, services.health, etc.)
   - Command history persistence
   - Syntax highlighting

### Command Modules

Each command domain has its own module in `lib/pilot/commands/`:

- **Jobs** - Submit, list, monitor, and cancel jobs
- **Experiments** - Run CNS agents (Proposer, Antagonist, Synthesizer)
- **Services** - List services, check health, view logs
- **Datasets** - List, inspect, and download datasets (SciFact, FEVER, GSM8K, HumanEval)
- **Metrics** - Query metrics and launch dashboards

## Key Features Implemented

### CLI Commands
- ✅ Hierarchical command structure (e.g., `pilot jobs list`)
- ✅ Global flags (`--help`, `--version`, `--repl`, `--format`)
- ✅ Context-aware help for all subcommands
- ✅ Argument validation and required parameter enforcement

### Output Formats
- ✅ Table format for human readability
- ✅ JSON format for scripting/automation
- ✅ YAML format (currently JSON fallback)
- ✅ Colored console output with ANSI codes

### Configuration
- ✅ YAML configuration file support
- ✅ Environment variable overrides
- ✅ Nested configuration with dot notation
- ✅ Service URL management

### Interactive REPL
- ✅ Elixir expression evaluation
- ✅ Built-in command shortcuts
- ✅ Command history with persistence
- ✅ Tab completion via shell scripts

### Shell Completion
- ✅ Bash completion script
- ✅ Zsh completion script
- ✅ Command and option completion

## Build and Installation

### Prerequisites
```bash
# Elixir 1.18+, Erlang/OTP 26+
asdf install elixir 1.18.4
asdf install erlang 26.2.5
```

### Build
```bash
cd /home/home/p/g/North-Shore-AI/pilot
mix deps.get
mix compile
mix test          # 22 tests, all passing
mix escript.build  # Generates ./pilot executable
```

### Installation
```bash
# Local installation
mkdir -p ~/.local/bin
mv pilot ~/.local/bin/
export PATH="$HOME/.local/bin:$PATH"

# System-wide installation (requires sudo)
sudo mv pilot /usr/local/bin/
```

## Testing

### Test Coverage
- **Config Tests**: Agent lifecycle, nested key access, default values
- **Output Tests**: Table/JSON/YAML formatting, message styling
- **Dataset Tests**: List, info, download commands
- **All Tests Passing**: 22/22 tests pass

### Test Execution
```bash
mix test              # Run all tests
mix test --cover      # With coverage report
mix test test/pilot/config_test.exs  # Specific test file
```

## Usage Examples

### Dataset Management
```bash
# List all datasets
pilot datasets list

# Get dataset info
pilot datasets info scifact

# Download dataset
pilot datasets download fever
```

### Job Management
```bash
# List jobs
pilot jobs list

# Submit job
pilot jobs submit --type training --config job.json

# Check status
pilot jobs status job_123
```

### Experiment Running
```bash
# Run proposer on SciFact
pilot experiments run proposer --dataset scifact

# Compare experiments
pilot experiments compare exp_1 exp_2
```

### Service Monitoring
```bash
# Check all services
pilot services health

# View logs
pilot services logs work --tail 100

# Follow logs
pilot services logs work --follow
```

### Interactive REPL
```bash
# Start REPL
pilot --repl

# In REPL:
pilot> jobs.list
pilot> services.health
pilot> 1 + 1
pilot> Enum.map([1, 2, 3], &(&1 * 2))
pilot> exit
```

## Configuration

### Example Configuration (`~/.pilot/config.yaml`)
```yaml
default_tenant: "cns"
services:
  work: "http://localhost:4000"
  registry: "http://localhost:4001"
output_format: table
http_timeout: 30000
repl_history_size: 100
```

### Environment Variables
```bash
export PILOT_TENANT=my_tenant
export PILOT_WORK_URL=http://work.example.com
export PILOT_REGISTRY_URL=http://registry.example.com
export PILOT_FORMAT=json
```

## Dependencies

### Production Dependencies
- `optimus ~> 0.3` - CLI argument parsing
- `owl ~> 0.8` - Interactive prompts
- `table_rex ~> 3.1` - Table formatting
- `req ~> 0.4` - HTTP client
- `yaml_elixir ~> 2.9` - YAML parsing
- `jason ~> 1.4` - JSON encoding/decoding

### Development Dependencies
- `ex_doc ~> 0.31` - Documentation generation
- `credo ~> 1.7` - Static code analysis

## Integration Points

Pilot integrates with the NSAI ecosystem through HTTP APIs:

1. **Work Service** (port 4000)
   - Job submission and management
   - Experiment orchestration
   - Metrics collection

2. **Registry Service** (port 4001)
   - Service discovery
   - Health monitoring

3. **CNS Services**
   - Proposer agent execution
   - Antagonist validation
   - Synthesizer merging

## Future Enhancements

### Planned Features
- [ ] WebSocket support for real-time log streaming
- [ ] Job result downloading and caching
- [ ] Experiment comparison visualization
- [ ] Metrics dashboard in terminal (using Owl charts)
- [ ] Auto-completion for job IDs and experiment IDs
- [ ] Configuration wizard for first-time setup
- [ ] Plugin system for custom commands

### Known Limitations
- YAML output currently falls back to JSON (YamlElixir is read-only)
- TableRex deprecation warning (cosmetic, no functional impact)
- Service logs use polling instead of streaming
- No offline mode for cached data

## File Structure

```
pilot/
├── lib/
│   └── pilot/
│       ├── cli.ex              # Main CLI entry point
│       ├── application.ex      # OTP application
│       ├── config.ex           # Configuration agent
│       ├── output.ex           # Output formatting
│       ├── client.ex           # HTTP client
│       ├── repl.ex             # Interactive REPL
│       └── commands/           # Command implementations
│           ├── jobs.ex
│           ├── experiments.ex
│           ├── services.ex
│           ├── datasets.ex
│           └── metrics.ex
├── priv/
│   └── completions/            # Shell completion scripts
│       ├── pilot.bash
│       └── pilot.zsh
├── test/                       # Test suites
│   └── pilot/
│       ├── config_test.exs
│       ├── output_test.exs
│       └── commands/
│           └── datasets_test.exs
├── mix.exs                     # Project configuration
├── README.md                   # User documentation
├── SUMMARY.md                  # This file
└── config.example.yaml         # Example configuration
```

## Performance Characteristics

- **Startup Time**: ~200ms (Erlang VM + application boot)
- **Memory Usage**: ~30MB baseline
- **HTTP Timeout**: 30s default, configurable
- **Retry Logic**: 3 attempts with exponential backoff
- **Table Rendering**: O(n) where n = number of rows

## Security Considerations

- Configuration files in home directory (user-only access)
- No credential storage (credentials managed by services)
- HTTP-only (HTTPS upgrade planned)
- No input sanitization needed (Optimus handles parsing)

## Maintenance

### Code Quality
```bash
mix format           # Auto-format code
mix credo --strict   # Linting and style checks
mix dialyzer         # Type checking
```

### Documentation
```bash
mix docs             # Generate HTML documentation
```

## Contributing

See README.md for contribution guidelines.

## License

MIT License - see LICENSE file for details

## Authors

North Shore AI Team

## Links

- [GitHub Repository](https://github.com/North-Shore-AI/pilot)
- [NSAI Monorepo](https://github.com/North-Shore-AI/tinkerer)
- [Documentation](https://docs.northshore.ai)
