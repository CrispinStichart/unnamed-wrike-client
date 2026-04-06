# MVP Scope Decision

## Decision summary

The smallest realistic MVP path is a read-first proof of concept in Phase 1 followed by the first narrow write workflows in Phase 2.

This keeps the first implementation focused on the hardest integration risks that the docs already confirm:
- OAuth and host handling
- structure browsing
- task retrieval
- offline-safe testing

## Phase 1: must build first

Phase 1 should deliver a thin but complete read flow:

1. App startup and composition root for Avalonia.
2. OAuth 2.0 authorization-code login path.
3. Session persistence for:
   - access token
   - refresh token
   - Wrike `host`
4. Read accessible spaces.
5. Select one space and load its task-oriented hierarchy.
6. Select one container and load a task list.
7. Select one task and show a read-only details view.
8. Manual refresh for the active read screen.
9. Offline-safe automated tests with fakes and fixtures.

User-facing success criteria for Phase 1:
- A user can authenticate once and reopen the app without redoing the full login flow.
- A user can see their spaces.
- A user can navigate to a task list from a chosen space.
- A user can open one task and inspect its core details.
- No automated test requires live Wrike credentials.

## Phase 2: defer until after the read proof of concept

Phase 2 is the first place write workflows should appear:
- create task
- edit task title/description and other verified fields
- read comments in the shipped UI
- add comments
- edit comments
- status changes after schema verification

Phase 2 interaction policy:
- explicit save only
- one deliberate write command per user action
- visible success or failure states
- no background autosave

## Not planned unless research changes

- reactions
- collaborative editing behavior that mimics the web client
- real-time sync via webhooks
- offline editing and sync reconciliation
- generic batch write subsystem
- broad feature parity with Wrike web

## Why this scope is the right cut

- It validates the platform and API integration without committing to risky write UX too early.
- It forces the app to solve auth, host selection, hierarchy reads, and state management first.
- It keeps the first application seam read-only, which makes fakes and tests much easier to design well.
- It avoids promising reaction or collaboration behavior that the reviewed docs do not clearly support.

## Default product decisions locked by this document

- Phase 1 is read-only from the user's perspective.
- Phase 2 is the first phase allowed to ship write actions.
- Explicit save is the default write model.
- Spaces should be the top-level navigation entry point.
- Folder/tree navigation should be preferred over a fully generic search-first explorer in the first implementation.
