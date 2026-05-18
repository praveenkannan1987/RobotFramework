# Playwright + TypeScript Prompt Templates — Migration from Robot Framework

## Purpose
- Provide reproducible LLM prompts and mapping rules to convert Robot Framework test suites, resources, and helpers into a Playwright + TypeScript project with a similar structure.

## High-level conversion steps (to include in prompts)
1. Map Robot suites -> Playwright test files (one `.spec.ts` per Robot test file or logical suite).
2. Convert Robot keywords -> Page Objects (`pages/`) or reusable helper modules (`lib/`).
3. Convert resource files and `common_imports.robot` to shared fixtures and helper functions.
4. Convert test data (`testdata/*.yaml`) to JSON or TypeScript fixtures in `fixtures/`.
5. Replace Robot's CLI variables and tags with Playwright test fixtures, environment variables, and `test.describe`/`test.only`/`test.skip`.
6. Provide `package.json`, `playwright.config.ts`, and basic CI (GitHub Actions) job snippet.

## Best-practice mapping rules (include these in prompts)
- Robot Test Case -> `test()` with `test.step()` and clear assertions using `expect()`.
- Robot Keyword that interacts with UI -> Page Object method in `pages/<feature>Page.ts`.
- Robot Keyword that calls API -> `lib/apiClient.ts` using `fetch` or `axios` (or Playwright's `APIRequestContext`).
- Setup/Teardown -> `test.beforeEach`, `test.afterEach`, or custom fixtures.
- Tags -> Translate to `test.describe` groups or `test.skip/only` and CI filters.
- Variables -> Use `process.env`, `--project` fixtures, or `test.use()` in `playwright.config.ts`.
- Screenshots -> Use `page.screenshot()` and attach/store to `test.info().outputDir` on failure.

## Prompt templates

### 1) Convert one Robot test file to a Playwright spec

Prompt:
```
Convert the Robot Framework test file at `<path>` to a Playwright + TypeScript test file.
Rules:
- Output only the new TypeScript file content.
- Use Playwright Test runner and `@playwright/test` imports.
- Create or reference page objects for repeated UI interactions.
- Preserve test names, steps, and assertions. Map Robot `Should Be Equal` -> `expect(...).toBe(...)`.
- Map variables from Robot `-v` to `process.env` or a top-level `const` in the test file.
Input files available: `resources/common_imports.robot`, `tests/<file>.robot`, `resources/scripts/*.py`.
Return: One `.spec.ts` file content and a list of suggested Page Object files.
```

### 2) Generate Page Object(s) from Robot keywords

Prompt:
```
Create a TypeScript Page Object for `<feature>` using Playwright `Page` API.
Include methods for each Robot keyword that interacts with the UI.
Requirements:
- Class `FeaturePage` with constructor `(page: Page)`.
- Methods return other PageObjects or void/boolean as appropriate.
- Export the class as default.
```

### 3) Convert a Robot keyword that calls an API (Python helper) to TS

Prompt:
```
Convert the Python helper `<resources/scripts/sfContactApi.py>` into a TypeScript module `lib/sfContactApi.ts`.
Use Playwright's `request.newContext()` or `axios` to implement the same endpoints.
Keep function names and parameters consistent and add typed returns (interfaces) where sensible.
```

### 4) Create `package.json` and `playwright.config.ts`

Prompt:
```
Create a `package.json` with Playwright Test and TypeScript dependencies and a `playwright.config.ts` configured for parallel runs, screenshots on failure, and a `projects` entry for Chrome and Firefox.
Also output `tsconfig.json` minimal settings for tests.
Return the three files only.
```

### 5) CI snippet (GitHub Actions)

Prompt:
```
Produce a GitHub Actions job that checks out code, sets up Node 18, installs dependencies, runs `npx playwright install --with-deps`, and runs tests with `npx playwright test --reporter=html`. Upload `playwright-report` artifact.
Return the YAML snippet only.
```

### 6) Migration checklist prompt (high-level plan)

Prompt:
```
Produce a migration plan converting this Robot Framework project to Playwright+TypeScript. Include file-by-file suggestions: which `.robot` files become `.spec.ts`, which resources become page objects, what Python helpers to port, what testdata to convert, and CI changes. Provide estimated effort and a sequence of tasks.
```

## Examples and tips to include in prompts
- Attach sample `output.xml` or `log.html` excerpts when asking for flaky-test debugging.
- When converting locators, prefer specific selectors (data-test-id, aria labels) over brittle XPath; ask the LLM to propose improved selectors if a locator looks flaky.
- Ask the LLM to produce TypeScript types for API responses when converting API helpers.
- For large conversions, ask for a single-suite proof-of-concept conversion first (one feature folder).

## Output conventions to request from the LLM
- Return code only (no commentary) when asking for files.
- Provide file path headers if returning multiple files, e.g. `-- FILE: tests/login.spec.ts --` followed by content.
- For tasks that create many files, return a ZIP manifest or a list of paths with content sections.

## Running and validation commands (include in prompts or README)
```bash
npm install
npx playwright install --with-deps
npm test        # configured script that runs `npx playwright test`
```

## Closing notes
- Start by converting shared keywords to Page Objects and API helpers; that reduces duplication.
- Keep test data externalized and avoid embedding secrets; use environment variables and `.env` files with `.gitignore`.




### Example install commands (Playwright + Allure):
```bash
npm install -D @playwright/test typescript ts-node playwright
npm install -D allure-playwright @shelex/allure-commandline
npx playwright install --with-deps
```

## How to request reporters in prompts:
- Ask the LLM to output `playwright.config.ts` with `reporter: [['html'], ['junit', { outputFile: 'results.xml' }], ['allure-playwright']]` or similar.
- For CI prompts, ask to include commands to generate and upload the chosen report artifacts.

## Mapping from Python `requirements.txt` to recommended Playwright TypeScript packages

When migrating, these are recommended JS/TS equivalents for the Python packages found in `resources/requirements.txt`.

Python package | Recommended JS/TS package(s) | Notes / usage
:--|:--|:--
holidays | date-holidays | Local holiday calendars and utilities
python-docx | docx | Read/write DOCX in Nodes
robotframework | @playwright/test | Replace Robot Framework tests with Playwright Test runner
robotframework-crypto | Node `crypto`  | Use built-in `crypto`  for portable crypto helpers
robotframework-pabot | (not needed) | Playwright Test supports parallel runs natively
robotframework-requests | Playwright `APIRequestContext` | Prefer Playwright's built-in APIRequestContext for E2E API calls
robotframework-seleniumlibrary | @playwright/test | Playwright replaces Selenium interactions
simple-salesforce | jsforce | Salesforce REST/JS client for Node
regex | built-in `RegExp`  | JS `RegExp` handles most needs; `xregexp` for extended features
pymupdf | pdf-lib | PDF read/write and parsing libraries

Example npm install (core migration dependencies):
```bash
npm install -D @playwright/test typescript ts-node playwright
npm install js-yaml date-fns clipboardy jsforce pdf-lib docx
npm install -D allure-playwright @shelex/allure-commandline
npx playwright install --with-deps
```

## Reporter configuration for XML, HTML and Allure

Suggest including the following reporter configuration in `playwright.config.ts` when asking the LLM to generate files:

```
reporter: [
	['html'],
	['junit', { outputFile: 'results/results.xml' }],
	['allure-playwright']
]
```

Notes for CI prompts:
- Generate HTML (`playwright-report`) after the run and upload as artifact.
- Produce JUnit XML (`results/results.xml`) for CI test summaries.
- Run Allure CLI to generate the final Allure report from test results and upload the generated HTML artifact.

