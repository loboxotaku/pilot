#!/usr/bin/env bash
# Bash completion for pilot CLI

_pilot_completions()
{
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Top-level commands
    local commands="jobs experiments services datasets metrics registry embed --help --version --repl"

    # Subcommands
    local jobs_cmds="list submit status cancel"
    local experiments_cmds="run status compare"
    local services_cmds="list health logs"
    local datasets_cmds="list info download"
    local metrics_cmds="query dashboard"
    local registry_cmds="list health"

    # Agents for experiments run
    local agents="proposer antagonist synthesizer"

    # Datasets
    local datasets="scifact fever gsm8k humaneval"

    # Handle completion based on position
    case "${COMP_CWORD}" in
        1)
            # Complete top-level commands
            COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
            return 0
            ;;
        2)
            # Complete subcommands based on first argument
            case "${COMP_WORDS[1]}" in
                jobs)
                    COMPREPLY=( $(compgen -W "${jobs_cmds}" -- ${cur}) )
                    ;;
                experiments)
                    COMPREPLY=( $(compgen -W "${experiments_cmds}" -- ${cur}) )
                    ;;
                services)
                    COMPREPLY=( $(compgen -W "${services_cmds}" -- ${cur}) )
                    ;;
                datasets)
                    COMPREPLY=( $(compgen -W "${datasets_cmds}" -- ${cur}) )
                    ;;
                metrics)
                    COMPREPLY=( $(compgen -W "${metrics_cmds}" -- ${cur}) )
                    ;;
                registry)
                    COMPREPLY=( $(compgen -W "${registry_cmds}" -- ${cur}) )
                    ;;
            esac
            return 0
            ;;
    esac

    # Option completion
    case "${prev}" in
        --format|-f)
            COMPREPLY=( $(compgen -W "table json yaml" -- ${cur}) )
            return 0
            ;;
        --dataset)
            COMPREPLY=( $(compgen -W "${datasets}" -- ${cur}) )
            return 0
            ;;
    esac

    # If nothing matched, offer common options
    local common_opts="--format --help"
    COMPREPLY=( $(compgen -W "${common_opts}" -- ${cur}) )
}

complete -F _pilot_completions pilot
