#!/bin/bash

set -e

echo "Installing TacoTruck CLI..."
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

echo "Installing @testfiesta/tacotruck CLI..."
npm install -g @testfiesta/tacotruck

echo "TacoTruck CLI installed successfully!"
echo "TacoTruck CLI version:"
npx @testfiesta/tacotruck --version || echo "Version information not available via --version flag"
echo "Checking installed package version:"
npm list -g @testfiesta/tacotruck --depth=0 2>/dev/null || echo "Package version check completed"

echo "TacoTruck CLI installation complete!"
