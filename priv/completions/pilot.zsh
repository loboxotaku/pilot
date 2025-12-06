#compdef pilot

_pilot() {
    local -a commands
    commands=(
        'jobs:Manage jobs'
        'experiments:Run and manage experiments'
        'services:Manage services'
        'datasets:Manage datasets'
        'metrics:Query metrics'
        '--help:Show help'
        '--version:Show version'
        '--repl:Start interactive REPL'
    )

    local -a jobs_cmds
    jobs_cmds=(
        'list:List jobs'
        'submit:Submit a job'
        'status:Get job status'
        'cancel:Cancel a job'
    )

    local -a experiments_cmds
    experiments_cmds=(
        'run:Run an experiment'
        'status:Get experiment status'
        'compare:Compare two experiments'
    )

    local -a services_cmds
    services_cmds=(
        'list:List services'
        'health:Check service health'
        'logs:View service logs'
    )

    local -a datasets_cmds
    datasets_cmds=(
        'list:List available datasets'
        'info:Get dataset info'
        'download:Download a dataset'
    )

    local -a metrics_cmds
    metrics_cmds=(
        'query:Query metrics'
        'dashboard:Launch metrics dashboard'
    )

    local -a agents
    agents=(
        'proposer:Run Proposer agent'
        'antagonist:Run Antagonist agent'
        'synthesizer:Run Synthesizer agent'
    )

    local -a datasets
    datasets=(
        'scifact:SciFact dataset'
        'fever:FEVER dataset'
        'gsm8k:GSM8K dataset'
        'humaneval:HumanEval dataset'
    )

    case $CURRENT in
        2)
            _describe 'command' commands
            ;;
        3)
            case $words[2] in
                jobs)
                    _describe 'jobs command' jobs_cmds
                    ;;
                experiments)
                    _describe 'experiments command' experiments_cmds
                    ;;
                services)
                    _describe 'services command' services_cmds
                    ;;
                datasets)
                    _describe 'datasets command' datasets_cmds
                    ;;
                metrics)
                    _describe 'metrics command' metrics_cmds
                    ;;
            esac
            ;;
        4)
            case $words[2] in
                experiments)
                    if [[ $words[3] == "run" ]]; then
                        _describe 'agent' agents
                    fi
                    ;;
                datasets)
                    if [[ $words[3] == "info" ]] || [[ $words[3] == "download" ]]; then
                        _describe 'dataset' datasets
                    fi
                    ;;
            esac
            ;;
    esac
}

_pilot "$@"
