# Wrike Native Desktop Client: Agent Handbook

## Project intent

Build a focused native Wrike desktop client in C# and Avalonia for power-user task workflows. The product goal is not full Wrike parity; it is a fast, maintainable client for the daily operations that the public API can support well.

Current phase: `Phase 0`

Phase 0 is documentation-first. The required outcome is a decision-ready foundation for implementation, not a working app yet.

## What Phase 1 is allowed to build

Phase 1 is a technical proof of concept with a read-heavy scope.

Must build first:
- OAuth 2.0 authorization-code flow with refresh-token support for app auth
- Session handling that stores the API host returned by OAuth and uses it for all API calls
- Read-only browse flow for accessible spaces
- Read-only browse flow for one space's folder tree or equivalent task-oriented structure
- Read-only task list for a selected container
- Read-only task details view for a selected task
- Test scaffolding that runs fully offline with fakes and fixtures

May be explored but not promised in Phase 1:
- Manual local development with a permanent token for ad hoc API exploration
- One manual refresh action
- Narrow in-memory caching for read flows

Must wait for Phase 2:
- Create task
- Edit task
- Read, add, or edit comments in the shipped UI
- Status changes from the shipped UI
- Background write queues
- Autosave

Not planned unless research changes:
- Reactions
- Collaborative editing parity with the web app
- Offline mode
- Webhook-driven real-time sync in the first usable versions
- Batch write infrastructure in the initial proof of concept

## Confirmed API constraints

- OAuth 2.0 authorization is documented by Wrike and should be the production auth path. The authorization code is valid for 10 minutes, and token responses include the account-specific `host` that must drive subsequent API requests.
- Wrike documents `429 too_many_requests` as "IP or access token exceeded limit: 400 requests per minute".
- Wrike API IDs must be treated as opaque text. Do not parse, normalize, or validate them beyond documented character and length limits.
- Comments are stored as limited HTML; reads can request `plainText=true`.
- Modification operations against deleted entities or children of deleted entities are explicitly restricted.
- The legacy "Methods" pages are no longer the primary source of truth; Wrike directs developers to the `[New] Schema Reference`.

## Build rules for all future Codex sessions

- Keep changes small, reviewable, and easy to revert.
- Prefer the minimum viable implementation for the active phase.
- Do not add speculative abstractions, plugin points, or multi-provider infrastructure.
- Do not let UI code perform direct HTTP, auth, or serialization work.
- Do not let transport DTOs leak into app-facing state or domain models.
- Tests are required with every meaningful behavior change.
- Automated tests must not require Wrike credentials or live network traffic.
- Hand-written fakes are preferred over deep mocking frameworks.
- Keep API usage deliberate: avoid per-keystroke writes, chatty polling, and broad eager fetches.
- If architecture rules change, update the relevant docs in `docs/phase0/` and this file in the same change.

## Commit and push workflow

- After each completed feature or meaningful milestone, run the relevant tests, then commit and push before starting the next feature.
- Do not batch multiple unrelated features into one commit.
- Do not commit unfinished work unless the user explicitly asks for a checkpoint commit.
- A feature is only ready to commit when the implementation is done, the relevant tests pass, and any required docs are updated.
- Push every committed feature branch state promptly so recovery is easy and progress is visible.
- If a change is too large to describe clearly in one commit message, split it into smaller feature-sized commits.

Commit message rules:
- The subject line must summarize what changed in plain language.
- The body must explain why the change was made.
- The body must explain how the change fits the current phase or overall project plan.
- When relevant, mention the user-facing workflow or architectural rule the change advances.
- Prefer messages that describe intent and outcome, not just file edits.

Suggested commit message template:

```text
<short summary>

Why:
- <problem, risk, or planned milestone addressed>

How this fits the plan:
- <Phase 1/Phase 2/guardrail alignment>

What changed:
- <key implementation points>
```

## Architecture boundaries

Use a small layered structure from the first scaffold.

Layers:
- `App/UI`: Avalonia views, view models, navigation, dependency composition
- `Core`: use cases, app models, state coordination, validation, save policy
- `WrikeApi`: HTTP client, auth/session management, DTOs, request/response mapping, error mapping
- `Tests`: unit tests, fake-backed workflow tests, adapter contract tests

Dependency rules:
- `App/UI` may depend on `Core`, but not on raw Wrike HTTP clients or DTOs.
- `Core` may depend on interfaces only, never on Avalonia or HTTP details.
- `WrikeApi` may depend on HTTP/auth libraries, but not on Avalonia.
- `Tests` may reference any project needed for verification.

Forbidden shortcuts:
- No direct UI-to-HTTP calls
- No exposing raw JSON or DTO types outside the Wrike adapter layer
- No global static mutable state for auth/session or cache
- No persistence or caching layer until a concrete Phase 1 need exists

## Written contracts to preserve

These seams should exist in Phase 1 code, even if implementations stay small:

```csharp
public interface IWrikeSessionProvider
{
    ValueTask<WrikeSession> GetSessionAsync(CancellationToken cancellationToken);
}

public interface IWrikeWorkspaceGateway
{
    Task<IReadOnlyList<SpaceSummary>> GetSpacesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<FolderNode>> GetSpaceTreeAsync(string spaceId, CancellationToken cancellationToken);
    Task<IReadOnlyList<TaskListItem>> GetTasksAsync(TaskQuery query, CancellationToken cancellationToken);
    Task<TaskDetails> GetTaskAsync(string taskId, CancellationToken cancellationToken);
    Task<IReadOnlyList<TaskComment>> GetCommentsAsync(string taskId, CancellationToken cancellationToken);
}
```

Rules for the contracts:
- `WrikeSession` carries token metadata plus the Wrike API host returned by OAuth.
- `SpaceSummary`, `FolderNode`, `TaskListItem`, `TaskDetails`, and `TaskComment` are app-facing models, not transport DTOs.
- Phase 1 ships only read operations through `IWrikeWorkspaceGateway`.
- Write methods should be added only in Phase 2 once schema details are verified in the current Wrike schema reference.

## Save and rate-limit policy

- Default write model: explicit save, not autosave.
- Phase 1 should avoid user-facing write flows entirely.
- When Phase 2 adds writes, each action should map to one deliberate command with visible success or failure.
- Handle `429` as a recoverable condition with backoff and a user-visible message.
- Do not silently retry non-idempotent writes.
- Manual refresh is acceptable; background polling is not a Phase 1 requirement.

## Testing policy

- Aim for near-total coverage of non-trivial `Core` logic.
- Every workflow in `Core` must be testable with a fake `IWrikeWorkspaceGateway`.
- Wrike adapter tests should use recorded JSON fixtures and request assertions, not live calls.
- UI tests should focus on meaningful state transitions and command behavior, not pixel-level rendering.
- Automated test runs in CI and default local workflows must succeed without Wrike credentials.
- The only acceptable uncovered code in early phases is trivial bootstrapping, framework glue, or defensive branches that are infeasible to trigger cleanly.

## Working assumptions

- The current repo is documentation-only, so Phase 0 artifacts are the primary output.
- Reactions are not planned because no public reaction endpoint was confirmed in the official developer docs reviewed for Phase 0.
- Status changes are deferred from the first shipped UI even though Wrike documents status-related task and workflow data; the exact mutation contract should be verified in the current schema reference before implementation.
- Wrike's schema reference should be treated as canonical when it disagrees with older methods pages.

## Local environment and API-validation rules

- A local `.env` file exists with `CLEINT_ID`, `SECRET_KEY`, and `WRIKE_API_ACCESS_TOKEN`.
- The application itself is still intended to use OAuth 2.0 flow for real product behavior.
- Automated tests must remain fully offline and must not rely on the live Wrike API or the token in `.env`.
- `WRIKE_API_ACCESS_TOKEN` is available only for the agent's own manual validation of API assumptions during development.
- The token must be used for read-only API access only.
- Never use the token to create, edit, delete, or otherwise write data in Wrike.
- If live API validation is needed, prefer the narrowest possible read request and keep it outside automated test runs.
- Never print secrets or copy `.env` values into logs, commits, tests, fixtures, or documentation.

## Source links

- OAuth 2.0 Authorization: https://developers.wrike.com/oauth-20-authorization/
- Errors and rate limits: https://developers.wrike.com/errors/
- Spaces API: https://developers.wrike.com/api/v4/spaces/
- Folders & Projects API: https://developers.wrike.com/api/v4/folders-projects/
- Tasks API: https://developers.wrike.com/api/v4/tasks/
- Comments API: https://developers.wrike.com/api/v4/comments/
- Special syntax: https://developers.wrike.com/special-syntax/
- Change log: https://developers.wrike.com/change-log/
- ID format changes: https://developers.wrike.com/changes-in-api-ids-internal-structure-v4/
- Schema Reference landing page: https://developers.wrike.com/apiv4-schema-reference/
