# RobotFramework — Test Suite

Project containing Robot Framework test suites, resources, and helper scripts for Salesforce-related automation.

## Quick overview

- **Virtual environment:** `pkvenv/` (pre-created in this workspace)
- **Requirements:** see [resources/requirements.txt](resources/requirements.txt)
- **Main test file:** [tests/std_integrated.robot](tests/std_integrated.robot)

## Prerequisites

- Python 3.14 (or compatible)
- Robot Framework and dependencies from `resources/requirements.txt`

## Setup

Activate the included virtual environment and install requirements if needed:

```bash
source pkvenv/bin/activate
pip install -r resources/requirements.txt
```

If you prefer to create a fresh venv:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r resources/requirements.txt
```

## Running tests

Run the whole suite (outputs to `reports/`):

```bash
robot -d reports tests/
```

Run a single test file:

```bash
robot -d reports/6 -P resource/ -v SKIP_CLEANUP:true -v BROWSER:Chrome -v CLOSEBROWSER:Fale -v ENV:STAGE -i TM-2347 tests\
```

Run a Tag test file:

```bash
robot -d reports/6 -P resource/ -v SKIP_CLEANUP:true -v BROWSER:Chrome -v CLOSEBROWSER:Fale -v ENV:STAGE -i qa-regression tests\
```

## Useful files

- [resources/common_imports.robot](resources/common_imports.robot) — shared resource imports
- [resources/scripts](resources/scripts) — helper Python modules (e.g., `sfContactApi.py`, `sfAccountApi.py`)
- [resources/requirements.txt](resources/requirements.txt) — Python dependencies
- [testdata/user_credentials.yaml](testdata/user_credentials.yaml) — test credentials/data
- [tests/std_integrated.robot](tests/std_integrated.robot) — integrated test suite

## Scripts and utilities

Helper scripts live in `resources/scripts/`. Run them with the venv active:

```bash
python resources/scripts/sfContactApi.py
```

Adjust the command if the script expects to be used as a module or with arguments.

## Notes

- Keep secrets out of the repo; use `testdata/user_credentials.yaml` as an example of externalized test data.
- If Robot or other CLI tools are not found, ensure `pkvenv/bin` is on your `PATH` by activating the venv.

## Contact

For questions about these tests or to contribute, contact the repository owner.
