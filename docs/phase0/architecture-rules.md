# Architecture Rules

## Goals

The initial architecture must be:
- small
- explicit
- easy to fake in tests
- resistant to accidental UI/transport coupling

The first implementation should optimize for clarity, not framework cleverness.

## Initial solution shape

Phase 1 should create a four-project solution:
- `WrikeNativeDesktop.App`
  - Avalonia app, views, view models, navigation, composition root
- `WrikeNativeDesktop.Core`
  - app-facing models, workflow services, state coordination, validation, error abstractions
- `WrikeNativeDesktop.WrikeApi`
  - Wrike auth/session provider, HTTP calls, DTOs, request builders, response mapping
- `WrikeNativeDesktop.Tests`
  - unit tests, fake-backed workflow tests, adapter contract tests

Do not add more projects in Phase 1 unless the first proof of concept clearly needs them.

## Dependency boundaries

- `App` may depend on `Core`.
- `App` may depend on dependency-injection setup code that wires `Core` and `WrikeApi`.
- `Core` may depend only on BCL packages and its own interfaces/models.
- `Core` must not depend on Avalonia, HTTP clients, JSON serializers, or Wrike DTOs.
- `WrikeApi` may depend on HTTP, auth, and serialization packages.
- `WrikeApi` may implement interfaces declared in `Core`.
- `Tests` may reference any project needed for verification.

## Layer responsibilities

### App

Owns:
- window startup
- navigation
- view models
- command wiring
- presentation-only mapping

Must not own:
- HTTP requests
- token refresh logic
- JSON parsing
- Wrike-specific DTO knowledge

### Core

Owns:
- browse workflows
- task-details workflow
- write-policy decisions
- app-facing error categories
- app-facing models

Must not own:
- raw request URIs
- bearer token plumbing
- serialization details
- Avalonia controls or view types

### WrikeApi

Owns:
- OAuth token exchange and refresh
- storing and using Wrike `host`
- endpoint calls
- DTO definitions
- request/response mapping
- Wrike error translation to app-facing errors

Must not own:
- navigation rules
- screen state
- UI formatting decisions

## Required seams

Phase 1 should introduce these interfaces in `Core`:

```csharp
public sealed record WrikeSession(
    string AccessToken,
    string RefreshToken,
    Uri ApiHost);

public interface IWrikeSessionProvider
{
    ValueTask<WrikeSession> GetSessionAsync(CancellationToken cancellationToken);
}

public sealed record TaskQuery(
    string? SpaceId,
    string? FolderId);

public interface IWrikeWorkspaceGateway
{
    Task<IReadOnlyList<SpaceSummary>> GetSpacesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<FolderNode>> GetSpaceTreeAsync(string spaceId, CancellationToken cancellationToken);
    Task<IReadOnlyList<TaskListItem>> GetTasksAsync(TaskQuery query, CancellationToken cancellationToken);
    Task<TaskDetails> GetTaskAsync(string taskId, CancellationToken cancellationToken);
    Task<IReadOnlyList<TaskComment>> GetCommentsAsync(string taskId, CancellationToken cancellationToken);
}
```

Rules:
- `WrikeSession.ApiHost` must come from Wrike auth responses.
- `TaskQuery` should stay deliberately small in Phase 1.
- `IWrikeWorkspaceGateway` is read-only in Phase 1.
- Write methods belong in a later extension of the gateway only after Phase 2 decisions are locked.

## DTO and model policy

- DTOs live only in `WrikeApi`.
- DTOs are never returned directly to `App`.
- `Core` models should represent only fields needed for the current phase.
- Add fields to app-facing models only when the UI or workflow actually needs them.
- Avoid one-to-one mirroring of the entire Wrike JSON schema.

## Dependency injection policy

- Use `Microsoft.Extensions.DependencyInjection` only at the app composition root.
- Register one concrete Wrike gateway implementation and one fake implementation for tests.
- Do not introduce mediator/event-bus frameworks in Phase 1.
- Do not introduce global service locators.

## Caching, persistence, and sync policy

- Phase 1 may use narrow in-memory caching only if it removes obvious duplicate reads.
- Do not add durable caching, offline storage, or sync reconciliation in Phase 1.
- Token/session persistence is allowed because auth continuity is a direct Phase 1 requirement.
- Write queues are out of scope until Phase 2.

## Explicitly forbidden in early implementation

- UI code calling `HttpClient` directly
- shared DTOs reused as view-model state
- speculative repository-per-entity abstractions
- generic command buses
- plugin architecture
- background autosave
- hidden retries for non-idempotent writes

## Default path for the first proof of concept

- Top-level screen: list of spaces
- Secondary screen/pane: folder tree for the selected space
- Task list for the selected space/folder
- Task details panel/screen for the selected task

This is the only browse path the initial implementation needs to support.
