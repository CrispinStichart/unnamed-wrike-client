# Testing and Mocking Strategy

## Non-negotiable rules

- Automated tests must run without Wrike credentials.
- Automated tests must not depend on live Wrike API traffic.
- New workflow behavior in `Core` requires tests in the same change.
- The read path chosen for Phase 1 must be fully exercisable with a fake gateway.

## Test categories

### 1. Core workflow tests

Purpose:
- verify browse flow orchestration
- verify state transitions
- verify error handling and retry/backoff policy selection
- verify save-policy decisions once writes exist

Mechanism:
- use a hand-written fake for `IWrikeWorkspaceGateway`
- use deterministic in-memory data

Expectation:
- near-100% coverage for non-trivial `Core` classes

### 2. Wrike adapter contract tests

Purpose:
- verify request construction
- verify response-to-model mapping
- verify Wrike error mapping
- verify auth host propagation

Mechanism:
- use fixture JSON payloads and fake HTTP handlers
- assert request path, query parameters, headers, and response parsing

Expectation:
- every endpoint used in Phase 1 has at least one happy-path contract test
- every critical failure mode used in app logic has at least one error-mapping test

### 3. UI/view-model tests

Purpose:
- verify user-visible state logic without needing rendered UI

Mechanism:
- instantiate view models against fake services/gateways
- assert command enablement, loading states, selection changes, and error messages

Expectation:
- cover meaningful interaction logic only
- do not spend early effort on fragile pixel/snapshot tests

## Tooling defaults

- test framework: `xUnit`
- assertions: standard xUnit assertions are sufficient at first; add a helper library only when it materially improves readability
- mocking style: hand-written fakes first, mocking library only if a seam becomes awkward

## Fake strategy

Use one primary fake:

```csharp
public sealed class FakeWrikeWorkspaceGateway : IWrikeWorkspaceGateway
{
    public List<SpaceSummary> Spaces { get; } = new();
    public Dictionary<string, List<FolderNode>> SpaceTrees { get; } = new();
    public Dictionary<string, List<TaskListItem>> TasksByContainer { get; } = new();
    public Dictionary<string, TaskDetails> TasksById { get; } = new();
    public Dictionary<string, List<TaskComment>> CommentsByTaskId { get; } = new();
}
```

Rules for the fake:
- keep behavior obvious and deterministic
- allow targeted failure injection for rate limits, auth failures, and missing resources
- do not simulate the full Wrike API surface

## Fixture strategy for the real adapter

- store small JSON fixtures that resemble real Wrike payloads for:
  - spaces
  - folder tree
  - task list
  - task details
  - comments
  - OAuth token response including `host`
  - `401`, `403`, `404`, and `429` error bodies
- prefer one-purpose fixtures over giant all-fields payloads
- add fixtures only for fields the app currently reads or writes

## Coverage expectations

- `Core`: target effectively complete coverage for meaningful branches
- `WrikeApi`: cover request construction, mapping, and important error cases
- `App` view-model logic: cover meaningful state behavior, not framework plumbing

Acceptable uncovered code in early phases:
- Avalonia-generated bootstrapping
- trivial DI registration glue
- impossible-to-trigger defensive branches with a documented justification

## CI and local-run policy

- default test command must be safe on any machine without secrets
- CI must fail if tests require external auth, network availability, or live account state
- exploratory live API verification, if ever needed, must be manual and outside the automated suite

## Minimum test list for Phase 1

- session provider uses the Wrike `host` returned by auth
- browse spaces success
- browse spaces auth failure
- load folder tree success
- load task list success
- load task details success
- `429` is mapped to a recoverable app error
- `404` is mapped to a not-found app error
- view-model selection changes load the expected next read model
