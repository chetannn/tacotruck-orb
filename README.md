# TacoTruck orb for CircleCI

TacoTruck submits test results to various testing platforms and services from within your CircleCI CI/CD pipeline. TacoTruck streamlines test reporting with a unified interface for multiple test result destinations.

## Quick Start

Add the TacoTruck orb to your CircleCI configuration:

```yaml
version: 2.1
orbs:
  tacotruck: chetan/tacotruck@1.0.0

jobs:
  test-and-report:
    executor: tacotruck/default
    steps:
      - checkout
      # Install TacoTruck CLI
      - tacotruck/install:
          version: "latest"
      # Run your tests here
      - run: npm test
      # Submit results to testing platforms
      - run: npx tacotruck testfiesta run:submit --data ./results.xml --organization <YOUR_ORG> --token <YOUR_TOKEN> --project <YOUR_PROJECT>

workflows:
  test:
    jobs:
      - test-and-report
```

## Commands

### `install`

Installs the TacoTruck CLI globally and verifies the installation.

**Parameters:**
- `version` (string, default: "latest") - Version of @testfiesta/tacotruck to install
- `check_version` (boolean, default: true) - Whether to verify installation by printing version

**Examples:**

```yaml
# Install latest version
- tacotruck/install:
    version: "latest"

# Install specific version
- tacotruck/install:
    version: "1.0.0-beta.13"
    check_version: true
```

### Resources
- [TacoTruck Documentation](https://docs.testfiesta.com) - Complete documentation for TacoTruck features and supported platforms.
- [Tacotruck Examples](https://github.com/testfiesta/tacotruck-orb/tree/main/examples) - The examples directory contains a variety of sample CircleCI configurations that demonstrate how to use the TacoTruck orb.
 - [TacoTruck CircleCI Guide](https://docs.testfiesta.com/automation/ci-cd-integration/circleci)

### How to Contribute

We welcome [issues](https://github.com/testfiesta/tacotruck-orb/issues) to and [pull requests](https://github.com/testfiesta/tacotruck-orb/pulls) against this repository!

Here is the [Development Environment Setup Guide](./.github/development-guide.md)

For questions about TacoTruck functionality or supported platforms, please visit our [documentation](https://docs.testfiesta.com) or open an [issue on GitHub](https://github.com/testfiesta/tacotruck-orb/issues).
