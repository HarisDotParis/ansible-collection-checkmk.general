#!/usr/bin/env bash
#
# Written by: Robin Gierse - robin.gieres@checkmk.com - on 20231027
#
# Purpose:
# Run tests locally.
#
# Usage:
#   Run Sanity Tests:       ./testing.sh -s
#   Run Integration Tests:  ./testing.sh -i -t host
#   Run Linting:            ./testing.sh -s

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
collection_dir="${script_dir%/*}"

mode="sanity"

while getopts 'silt:' OPTION; do
  case "$OPTION" in 
    s) 
      mode="sanity" ;;
    i)
      mode="integration" ;;
    l)
      mode="lint" ;;
    t)
      target="$OPTARG" ;;
    ?) 
      echo "Unknown option!"
      exit 1
      ;;
  esac
done

_run_sanity() {
    echo "## Running Ansible Sanity Tests."
    ansible-test sanity --docker
    echo "## Ansible Sanity Tests done."
}

_run_integration() {
    if [ -n "${target}" ]; then
    echo "## Running Ansible Integration Tests for <${target}> Module."
    ansible-test integration "${target}" --docker
    else
    echo "## Running Ansible Integration Tests for all Modules."
    ansible-test integration --docker
    fi
    echo "## Ansible Integration Tests done."
}

_run_linting() {
    echo "## Running yamllint."
    yamllint -c "${collection_dir}/.yamllint" "${collection_dir}/roles/"
    yamllint -c "${collection_dir}/.yamllint" "${collection_dir}/playbooks/"
    echo "## yamllint done."
    echo "## Running ansible-lint."
    ansible-lint -c "${collection_dir}/.ansible-lint" "${collection_dir}/roles/"
    ansible-lint -c "${collection_dir}/.ansible-lint" "${collection_dir}/playbooks/"
    echo "## ansible-lint done."
}

case "$mode" in 
    sanity) 
        _run_sanity ;;
    integration)
        _run_integration ;;
    lint)
        _run_linting ;;
    ?) 
      echo "Unknown mode!"
      exit 1
      ;;
esac