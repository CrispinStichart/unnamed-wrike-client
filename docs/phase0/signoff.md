# Phase 0 Sign-off Note

## Resolved questions

- The app should use OAuth 2.0 authorization-code flow for production auth.
- The app must store and reuse the Wrike API `host` returned by auth.
- A read-only Phase 1 is both realistic and well supported by the public API docs.
- Spaces plus folder/tree traversal are sufficient to define the first browse path.
- Comments are supported by the API, but comment UI is deferred to Phase 2.
- Wrike IDs must be treated as opaque strings.
- Explicit save is the correct default write policy.

## Remaining open questions

- Whether reactions have any public API support usable by this client.
- The exact schema-reference contract for single-task status mutation.
- The exact paging parameters and response shape we should encode first for list endpoints.

These open questions do not block Phase 1 because Phase 1 is read-only.

## Exact Phase 1 starting target

Build a read-only Avalonia proof of concept that:
- authenticates with Wrike using OAuth 2.0
- stores the returned `host` and refresh token
- lists spaces
- loads one selected space's tree
- loads a task list for a selected container
- shows one selected task's details
- proves the workflow with offline-safe tests

## Review checklist status

- MVP scope matches confirmed API support: yes
- Phase 1 avoids unsupported or weakly supported writes: yes
- Testing rules forbid live API dependency in automated runs: yes
- Architecture boundaries are simple and enforceable: yes
- `agents.md` matches the README intent: yes
