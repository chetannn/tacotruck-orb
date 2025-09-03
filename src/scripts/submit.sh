#!/bin/bash

set -e

validate_environment() {
    echo "Validating TacoTruck submission environment..."

    if ! command -v npx &> /dev/null; then
        echo "Error: npx is not available. Please ensure Node.js is installed."
        exit 1
    fi

    if ! npx @testfiesta/tacotruck --version &> /dev/null; then
        echo "Error: TacoTruck CLI is not installed. Please run the install command first."
        exit 1
    fi

    echo "TacoTruck CLI version: $(npx @testfiesta/tacotruck --version 2>/dev/null || echo 'Version not available')"
}

validate_parameters() {
    local results_path="$1"
    local api_key_var="$2"

    if [[ ! -e "${results_path}" ]]; then
        echo "Error: Results path '${results_path}' does not exist."
        exit 1
    fi

    if [[ -z "${!api_key_var}" ]]; then
        echo "Error: API key environment variable '${api_key_var}' is not set or empty."
        echo "Please set your TacoTruck API key in the environment variable."
        exit 1
    fi

    echo "Results path: ${results_path}"
    echo "API key variable: ${api_key_var} (configured)"
}

build_submit_command() {
    local provider="$1"
    local results_path="$2"
    local project_key="$3"
    local api_key_var="$4"
    local handle="$5"
    local run_name="$6"
    local base_url="$7"

    local cmd="npx @testfiesta/tacotruck ${provider} run:submit"

    cmd="${cmd} --token \"${!api_key_var}\" --data \"${results_path}\" --organization \"${handle}\" --name \"${run_name}\""

    if [[ -n "${project_key}" ]]; then
        cmd="${cmd} --project-key \"${project_key}\""
    fi

    if [[ -n "${base_url}" ]]; then
        echo "Base URL: ${base_url}"
        # This option is not yet supported.
        # cmd="${cmd} --base-url \"${base_url}\""
    fi

    echo "${cmd}"
}

submit_results() {
    local submit_cmd="$1"

    echo "Submitting test results to TacoTruck..."

    if bash -c "${submit_cmd}"; then
        return 0
    else
        local exit_code=$?
        return ${exit_code}
    fi
}

show_submission_info() {
    local provider="$1"
    local results_path="$2"
    local project_key="$3"
    local base_url="$4"

    echo "=== TacoTruck Submission Details ==="
    echo "Provider: ${provider}"
    echo "Results Path: ${results_path}"
    [[ -n "${project_key}" ]] && echo "Project Key: ${project_key}"
    [[ -n "${base_url}" ]] && echo "Base URL: ${base_url}"
    echo "=================================="
}

main() {
    local provider
    local results_path
    local project_key
    local api_key_var
    local handle
    local run_name
    local base_url

    provider=$(circleci env subst "${PARAM_PROVIDER}")
    results_path=$(circleci env subst "${PARAM_RESULTS_PATH}")
    project_key=$(circleci env subst "${PARAM_PROJECT_KEY}")
    api_key_var=$(circleci env subst "${PARAM_API_KEY}")
    handle=$(circleci env subst "${PARAM_HANDLE}")
    run_name=$(circleci env subst "${PARAM_RUN_NAME}")
    base_url=$(circleci env subst "${PARAM_BASE_URL}")

    validate_environment
    validate_parameters "${results_path}" "${api_key_var}"

    show_submission_info "${provider}" "${results_path}" "${project_key}" "${base_url}"

    local submit_cmd
    submit_cmd=$(build_submit_command "${provider}" "${results_path}" "${project_key}" "${api_key_var}" "${handle}" "${run_name}" "${base_url}")

    submit_results "${submit_cmd}"

    echo "TacoTruck submission complete!"
}

main
