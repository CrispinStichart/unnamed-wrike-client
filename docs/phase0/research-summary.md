# Phase 0 Research Summary

## Scope of research

Phase 0 focused on the public Wrike developer documentation needed to validate:
- authentication and host selection
- rate-limit and error handling constraints
- support for spaces, folders/projects, tasks, comments, workflows, and statuses
- API-side limitations that materially affect architecture and UX

## Confirmed facts

### Authentication

- Wrike documents OAuth 2.0 Authorization Code flow for public API access.
- The authorization code is valid for 10 minutes.
- Token responses include a `host` value, and Wrike expects API requests to use the account-specific host returned by auth rather than a hard-coded single base URL.
- Wrike still documents permanent tokens, but those are better suited for manual local exploration than for the production app flow.

Sources:
- https://developers.wrike.com/oauth-20-authorization/

### Rate limits and errors

- Wrike documents `429 too_many_requests` with the detail "IP or access token exceeded limit: 400 requests per minute".
- Wrike also documents a separate `429 rate_limit_exceeded` response with "Rate limit exceeded, try again later".
- Relevant error families for the desktop client include:
  - `401 not_authorized`
  - `403 access_forbidden`
  - `404 resource_not_found`
  - `400 invalid_parameter`
  - `400 parameter_required`

Sources:
- https://developers.wrike.com/errors/

### IDs and durability constraints

- Wrike changed API v4 ID internals in 2025 and explicitly warns integrators not to parse, normalize, substring, or compare IDs except for equality.
- IDs must be treated as opaque strings.
- Current documented max length is 256 text characters using a constrained character set, but the important engineering rule is still "treat as opaque text".

Sources:
- https://developers.wrike.com/changes-in-api-ids-internal-structure-v4/
- https://developers.wrike.com/change-log/

### Spaces and task structure access

- Wrike documents a Spaces API with read and write methods.
- The public docs confirm space reads, space creation/update/delete, and historical support for "Get Folder Tree in space" and "Get tasks in space".
- The 2025 change log adds space-scoped workflow and custom-field reads:
  - `GET /spaces/{spaceId}/workflows`
  - `GET /spaces/{spaceId}/customfields`
- The 2025 change log also confirms additional filtering for `GET /spaces` and folder-related endpoints.

Sources:
- https://developers.wrike.com/api/v4/spaces/
- https://developers.wrike.com/api/v4/folders-projects/
- https://developers.wrike.com/change-log/

### Folders, projects, and hierarchy traversal

- Wrike documents folders/projects as the primary organization model.
- Historical docs and change log entries confirm support for traversing descendants and folder trees.
- `childIds` and descendants-style traversal are part of the documented hierarchy model.
- Folder/project writes exist, but they are not needed for the Phase 1 proof of concept.

Sources:
- https://developers.wrike.com/api/v4/folders-projects/
- https://developers.wrike.com/change-log/

### Tasks

- Wrike documents read, create, modify, and delete task methods.
- Task creation is folder-scoped in the documented methods pages (`POST /folders/{folderId}/tasks`).
- Bulk update support exists for up to 100 task IDs.
- The 2025 change log explicitly states that bulk task updates support custom status.
- Task search/read behavior includes support for additional filters and custom fields in the broader public docs history.

Sources:
- https://developers.wrike.com/api/v4/tasks/
- https://developers.wrike.com/change-log/

### Comments

- Wrike documents comment read, create, update, and delete methods.
- Comment creation is documented for both folders and tasks.
- Comment bodies are HTML with a limited tag set.
- Wrike documents `plainText=true` as a read option for task comments.

Sources:
- https://developers.wrike.com/api/v4/comments/
- https://developers.wrike.com/special-syntax/

### Status and workflow data

- Wrike documents workflow APIs and the change log confirms space-scoped workflow reads.
- The webhook documentation shows `status` and `customStatusId` on task status change events.
- The 2025 change log confirms custom-status support in task bulk updates.

Practical conclusion:
- Status display is clearly supported.
- Status mutation is likely supported, but the exact request contract should be verified in the schema reference before we commit UI behavior around it.

Sources:
- https://developers.wrike.com/api/v4/workflows/
- https://developers.wrike.com/change-log/
- https://developers.wrike.com/webhooks

### Write restrictions that affect UX

- Wrike documents that modification operations on deleted entries, or children of deleted entries, are forbidden.
- Wrike documents text limits for editable fields such as titles, descriptions, and comments in the change log.

Sources:
- https://developers.wrike.com/change-log/

## Confirmed constraints for project design

- Phase 1 should stay read-heavy to minimize risk while auth, host handling, and API shape are proven.
- The app must not hard-code assumptions about Wrike IDs.
- The app must centralize rate-limit handling and 429 recovery.
- The app should not use per-keystroke save semantics.
- All automated tests must run without live Wrike traffic.
- The schema reference is the canonical reference going forward; older methods pages are useful context but not the final authority.

## Open questions

- Reactions: no public reaction endpoint was confirmed in the reviewed developer docs. Treat as unsupported for planning purposes until proven otherwise.
- Pagination details: the reviewed public pages confirm endpoint families but do not fully answer the paging contract we should encode first. Phase 1 should verify current page/token parameters in the schema reference before designing a generic pager.
- Status mutation contract: public docs and changelog strongly suggest support, but the exact request field set for single-task status changes should be confirmed in the schema reference before implementation.
- Best initial browse path: Wrike supports both space-oriented and folder-oriented reads; Phase 1 should pick the narrowest path that yields a clear task list without building a generalized explorer too early.
- Batch API: Wrike introduced async batch operations in late 2025, but that should remain out of scope until the app has proven it needs write batching.

## Recommended defaults from research

- Use OAuth 2.0 Authorization Code flow in app code.
- Preserve the `host` from auth and use it to build every API request.
- Treat all IDs as opaque strings.
- Use explicit save semantics when writes arrive in Phase 2.
- Start with a read-only browse flow built on spaces, folder tree, task list, and task details.
