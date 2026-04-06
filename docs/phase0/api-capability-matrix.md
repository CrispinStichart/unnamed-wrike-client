# Wrike API Capability Matrix

Status values:
- `supported`: confirmed directly in public docs and fit for planned product usage
- `partially supported`: documented enough to explore, but needs schema verification or has caveats that block immediate commitment
- `unsupported`: public docs indicate the workflow is not available
- `unknown`: not confirmed in the reviewed public docs

| Workflow | Status | Primary endpoints | Required inputs / important fields | Round-trip profile | Caveats / notes | Sources |
| --- | --- | --- | --- | --- | --- | --- |
| Browse spaces | supported | `GET /spaces`, `GET /spaces/{spaceId}` | auth token, returned space IDs, titles, access type | Read-only | 2025 change log confirms `GET /spaces` filters for `title` and `accessTypes`; enough for a Phase 1 top-level browser | [Spaces API](https://developers.wrike.com/api/v4/spaces/), [Change Log](https://developers.wrike.com/change-log/) |
| Browse task structures | supported | `GET /spaces/{spaceId}/folders`, `GET /folders/{folderId}/folders`, space folder tree reads | `spaceId` or `folderId`, hierarchy IDs, `childIds`/descendants-style traversal | Read-only | Good fit for a tree-first Phase 1 browse model; exact paging/filter params should be verified in schema reference before building reusable paging helpers | [Spaces API](https://developers.wrike.com/api/v4/spaces/), [Folders & Projects API](https://developers.wrike.com/api/v4/folders-projects/), [Change Log](https://developers.wrike.com/change-log/) |
| View task details | supported | task read methods on `/tasks/...` | `taskId`, task title, description, status, assignees, dates, parent/folder references | Read-only | Safe for Phase 1; the read shape is broad enough to anchor the first real screen | [Tasks API](https://developers.wrike.com/api/v4/tasks/) |
| Create task | supported | `POST /folders/{folderId}/tasks` | parent `folderId`, title, optional description/status/custom fields depending on schema | Write with follow-up read | Documented, but deferred to Phase 2 so Phase 1 can stay read-heavy and keep the first seam simple | [Tasks API](https://developers.wrike.com/api/v4/tasks/) |
| Edit task | supported | `PUT /tasks/{taskId}` and bulk `PUT /tasks/{taskId},{taskId},...` | `taskId`, changed fields, likely status/custom status fields per schema | Write with follow-up read | Supported in principle; exact editable-field contract should be checked in schema reference before UI decisions | [Tasks API](https://developers.wrike.com/api/v4/tasks/), [Change Log](https://developers.wrike.com/change-log/) |
| Read comments | supported | `GET` comment reads for tasks/comments resource | `taskId`, comment IDs, author/date/body, optional `plainText=true` | Read-only | Comments are stored as limited HTML. Use `plainText=true` for simple read presentation first if HTML rendering is not ready | [Comments API](https://developers.wrike.com/api/v4/comments/), [Special Syntax](https://developers.wrike.com/special-syntax/) |
| Add comments | supported | `POST /tasks/{taskId}/comments` | `taskId`, comment body | Write with follow-up read | Supported, but HTML body rules and rate-limit considerations make it a Phase 2 write flow | [Comments API](https://developers.wrike.com/api/v4/comments/), [Special Syntax](https://developers.wrike.com/special-syntax/) |
| Edit comments | supported | `PUT /comments/{commentId}` | `commentId`, updated body | Round-trip safe with body-format caveat | Public docs confirm update support. Need to preserve Wrike's limited HTML rules if rich text is later supported | [Comments API](https://developers.wrike.com/api/v4/comments/), [Special Syntax](https://developers.wrike.com/special-syntax/) |
| Reactions | unknown | no confirmed public endpoint in reviewed docs | unknown | Unknown | README treats reactions as aspirational. Do not plan them into early phases without a confirmed endpoint in current schema reference | [Schema Reference](https://developers.wrike.com/apiv4-schema-reference/), [Change Log](https://developers.wrike.com/change-log/) |
| Status changes | partially supported | task modify methods, workflow reads, status-related webhook payloads | `taskId`, likely `status` and/or `customStatusId`, workflow/status metadata | Write with schema verification | Status display is clearly supported; write support is strongly implied by task update docs and 2025 changelog, but exact request contract needs schema-reference verification before implementation | [Tasks API](https://developers.wrike.com/api/v4/tasks/), [Workflows API](https://developers.wrike.com/api/v4/workflows/), [Change Log](https://developers.wrike.com/change-log/), [Webhooks](https://developers.wrike.com/webhooks) |

## Planning conclusions from the matrix

- Every workflow named in the project README is now classified.
- Phase 1 can safely depend on:
  - browse spaces
  - browse task structures
  - view task details
- Phase 2 can safely explore:
  - create task
  - edit task
  - read/add/edit comments
- Reactions stay out of scope until the public developer docs confirm them.
- Status changes should remain deferred until the current schema reference confirms the exact mutation parameters we want to support.
