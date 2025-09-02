#!/bin/bash

set -e

set_sudo() {
    if [[ $EUID == 0 ]]; then
        echo ""
    else
        echo "sudo"
    fi
}

get_latest_version() {
    echo "Fetching latest version from GitHub API..."
    local latest_tag

    # First try to get the latest stable release
    latest_tag=$(curl -s https://api.github.com/repos/testfiesta/tacotruck/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' 2>/dev/null)

    # If no stable release (404), get the latest pre-release
    if [[ -z "$latest_tag" ]]; then
        echo "No stable release found, checking for latest pre-release..."
        latest_tag=$(curl -s https://api.github.com/repos/testfiesta/tacotruck/releases | grep '"tag_name":' | head -1 | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' 2>/dev/null)
    fi

    if [[ -z "$latest_tag" ]]; then
        echo "Failed to fetch version from GitHub API, falling back to npm latest"
        echo "latest"
    else
        echo "Found latest version: ${latest_tag}"
        # Remove 'v' prefix if present (v1.0.0-beta.13 -> 1.0.0-beta.13)
        echo "${latest_tag#v}"
    fi
}

show_environment_info() {
    echo "Installing TacoTruck CLI..."
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
}

get_package_spec() {
    local version="$1"

    if [[ "${version}" == "latest" ]]; then
        local latest_version
        latest_version=$(get_latest_version)

        if [[ "${latest_version}" == "latest" ]]; then
            echo "@testfiesta/tacotruck"
            echo "Installing @testfiesta/tacotruck CLI (latest from npm)..."
        else
            echo "@testfiesta/tacotruck@${latest_version}"
            echo "Installing @testfiesta/tacotruck CLI version ${latest_version} (latest from GitHub)..."
        fi
    else
        echo "@testfiesta/tacotruck@${version}"
        echo "Installing @testfiesta/tacotruck CLI version ${version}..."
    fi
}

install_cli() {
    local package_spec="$1"
    $(set_sudo) npm install -g "${package_spec}"
}

verify_installation() {
    echo "TacoTruck CLI installed successfully!"
    echo "TacoTruck CLI version:"
    npx @testfiesta/tacotruck --version || echo "Version information not available via --version flag"
}

main() {
    show_environment_info

    local version
    version=$(circleci env subst "${PARAM_VERSION}")

    local package_spec
    package_spec=$(get_package_spec "${version}")

    install_cli "${package_spec}"
    verify_installation

    echo "TacoTruck CLI installation complete!"
}

main
