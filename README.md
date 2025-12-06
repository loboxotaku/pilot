<p align="center">
  <img src="assets/pilot.svg" alt="NSAI Pilot" width="200">
</p>

<h1 align="center">NSAI Pilot</h1>

<p align="center">
  <a href="https://github.com/North-Shore-AI/pilot/actions"><img src="https://github.com/North-Shore-AI/pilot/workflows/CI/badge.svg" alt="CI Status"></a>
  <a href="https://hex.pm/packages/pilot"><img src="https://img.shields.io/hexpm/v/pilot.svg" alt="Hex.pm"></a>
  <a href="https://hexdocs.pm/pilot"><img src="https://img.shields.io/badge/docs-hexdocs-blue.svg" alt="Documentation"></a>
  <img src="https://img.shields.io/badge/elixir-%3E%3D%201.14-purple.svg" alt="Elixir">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
</p>

<p align="center">
  Interactive CLI and REPL for the NSAI ecosystem
</p>

---

Pilot provides a unified command-line interface for interacting with North Shore AI's ecosystem of services, including job management, experiment running, service monitoring, dataset operations, and metrics querying.

## Features

- **Job Management**: Submit, list, monitor, and cancel jobs
- **Experiment Running**: Run CNS agents (Proposer, Antagonist, Synthesizer) on various datasets
- **Service Monitoring**: Check health and view logs for NSAI services
- **Dataset Operations**: List, inspect, and download datasets
- **Metrics Querying**: Query and visualize metrics from experiments
- **Interactive REPL**: Elixir-like shell for advanced usage
- **Multiple Output Formats**: Table (human-readable), JSON, and YAML
- **Shell Completion**: Bash and Zsh completion scripts

## Installation

### Prerequisites

- Elixir 1.18 or later
- Erlang/OTP 26 or later

### Build from Source

```bash
# Clone the repository
git clone https://github.com/North-Shore-AI/pilot.git
cd pilot

# Get dependencies
mix deps.get

# Build the escript
mix escript.build

# (Optional) Install globally
sudo mv pilot /usr/local/bin/
```

## Configuration

Pilot looks for configuration in `~/.pilot/config.yaml`:

```yaml
default_tenant: "cns"
services:
  work: http://localhost:4000
  registry: http://localhost:4001
output_format: table
http_timeout: 30000
```

You can also use environment variables to override configuration:

```bash
export PILOT_TENANT=my_tenant
export PILOT_WORK_URL=http://work.example.com
export PILOT_FORMAT=json
```

## Usage

### Command Line Interface

#### Job Management

```bash
# List all jobs
pilot jobs list

# Filter by status
pilot jobs list --status running

# Submit a job
pilot jobs submit --type training --config job_config.json

# Check job status
pilot jobs status job_123

# Cancel a job
pilot jobs cancel job_123
```

#### Experiments

```bash
# Run a proposer experiment
pilot experiments run proposer --dataset scifact

# Run an antagonist experiment
pilot experiments run antagonist --dataset fever

# Check experiment status
pilot experiments status exp_456

# Compare two experiments
pilot experiments compare exp_456 exp_789
```

#### Services

```bash
# List all services
pilot services list

# Check service health
pilot services health

# View service logs
pilot services logs work --tail 100

# Follow logs in real-time
pilot services logs work --follow
```

#### Datasets

```bash
# List available datasets
pilot datasets list

# Get dataset information
pilot datasets info scifact

# Download a dataset
pilot datasets download fever
```

#### Metrics

```bash
# Query metrics
pilot metrics query --metric entailment --model llama-3.1

# Open metrics dashboard
pilot metrics dashboard
```

### Interactive REPL

Start the REPL for interactive use:

```bash
pilot --repl
```

In the REPL, you can:

```elixir
# List jobs
pilot> jobs.list

# Check service health
pilot> services.health

# List datasets
pilot> datasets.list

# Execute Elixir code directly
pilot> 1 + 1
2

pilot> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]

# Use the HTTP client
pilot> Client.get(:work, "/api/jobs")
{:ok, [...]}

# View command history
pilot> history

# Show configuration
pilot> config

# Exit
pilot> exit
```

### Output Formats

Control output format with the `--format` flag:

```bash
# Table format (default, human-readable)
pilot jobs list --format table

# JSON format (machine-readable)
pilot jobs list --format json

# YAML format
pilot jobs list --format yaml
```

### Shell Completion

#### Bash

```bash
# Add to ~/.bashrc
source /path/to/pilot/priv/completions/pilot.bash
```

#### Zsh

```bash
# Add to ~/.zshrc
fpath=(/path/to/pilot/priv/completions $fpath)
autoload -U compinit && compinit
```

## Architecture

Pilot is structured as follows:

```
lib/pilot/
├── cli.ex                 # Main CLI entry point
├── application.ex         # OTP application
├── config.ex             # Configuration management
├── output.ex             # Output formatting
├── client.ex             # HTTP client
├── repl.ex               # Interactive REPL
└── commands/             # Command implementations
    ├── jobs.ex
    ├── experiments.ex
    ├── services.ex
    ├── datasets.ex
    └── metrics.ex
```

### Key Components

- **CLI Module**: Parses arguments using Optimus and routes to command handlers
- **Config Module**: Manages configuration from files and environment variables
- **Output Module**: Formats output as tables, JSON, or YAML
- **Client Module**: Provides HTTP client for service communication with retry logic
- **REPL Module**: Interactive shell with command history and Elixir evaluation
- **Command Modules**: Implement specific command logic

## Development

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/pilot/config_test.exs
```

### Code Quality

```bash
# Format code
mix format

# Run static analysis
mix credo --strict

# Run dialyzer (first run will be slow)
mix dialyzer
```

### Building

```bash
# Compile
mix compile

# Build escript
mix escript.build

# Clean build artifacts
mix clean
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Integration with NSAI Ecosystem

Pilot integrates with the following NSAI services:

- **Work Service** (port 4000): Job queue and execution
- **Registry Service** (port 4001): Service discovery and health checks
- **CNS Services**: Proposer, Antagonist, Synthesizer agents
- **Crucible**: Experiment orchestration and metrics

## Examples

### Submit a Training Job

```bash
# Create job configuration
cat > train_job.json <<EOF
{
  "model": "llama-3.1-8b",
  "dataset": "scifact",
  "epochs": 3,
  "learning_rate": 0.0001
}
EOF

# Submit job
pilot jobs submit --type training --config train_job.json

# Monitor job
pilot jobs status job_123
```

### Run Complete CNS Pipeline

```bash
# Run Proposer
pilot experiments run proposer --dataset scifact

# Run Antagonist on results
pilot experiments run antagonist --dataset scifact

# Run Synthesizer
pilot experiments run synthesizer --dataset scifact

# Compare results
pilot experiments compare exp_1 exp_3
```

### Monitor Services

```bash
# Check all services
pilot services health

# Follow logs for debugging
pilot services logs work --follow
```

## Troubleshooting

### Connection Errors

If you see connection errors, verify that services are running:

```bash
pilot services health
```

Check your configuration:

```bash
pilot --repl
pilot> config
```

### Permission Denied

If you get permission errors when installing globally:

```bash
# Install to user directory instead
mkdir -p ~/.local/bin
mv pilot ~/.local/bin/

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

## License

MIT License - see LICENSE file for details

## Authors

North Shore AI Team

## Links

- [GitHub Repository](https://github.com/North-Shore-AI/pilot)
- [NSAI Monorepo](https://github.com/North-Shore-AI/tinkerer)
- [Documentation](https://docs.northshore.ai)

