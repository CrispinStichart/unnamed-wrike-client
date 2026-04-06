# Phase 1 Entry Checklist

Use this checklist before and during the first implementation pass.

## Before creating code

- Read [`agents.md`](../../agents.md).
- Read every document in [`docs/phase0`](README.md).
- Treat the schema reference as canonical when endpoint details are ambiguous:
  - https://developers.wrike.com/apiv4-schema-reference/
- Confirm the first implementation target remains read-only.

## Solution scaffolding

- Create the four-project solution defined in `architecture-rules.md`.
- Add test project references before implementing browse logic.
- Wire dependency injection only at the app composition root.
- Create placeholder `Core` interfaces before writing concrete Wrike adapter code.

## Auth and configuration

- Implement OAuth 2.0 authorization-code flow.
- Persist refresh token and Wrike `host` with the session.
- Ensure every API call uses the stored account-specific host.
- Do not rely on permanent tokens for shipped app behavior.

## First browse path

- Implement spaces read.
- Implement one space tree read.
- Implement one task list read.
- Implement one task details read.
- Keep the browse path to: `Space -> Tree -> Task List -> Task Details`.
- Do not add generic search, dashboards, or alternate navigation in the first pass.

## Testing gates

- Add fake-backed tests before or alongside each new `Core` workflow.
- Add contract tests for the Wrike adapter endpoints Phase 1 uses.
- Verify the test suite runs without secrets or network access.
- Verify `429`, `401`, and `404` handling paths are covered.

## Guardrails during implementation

- No write UI in Phase 1.
- No autosave.
- No durable cache other than auth/session persistence.
- No DTO leakage into `Core` or `App`.
- No speculative abstractions for future entities or providers.

## Phase 1 done criteria

- The app authenticates and stores a reusable session.
- The app can display accessible spaces.
- The app can navigate to a task list for a chosen area.
- The app can display read-only task details.
- Tests are green and offline-safe.
