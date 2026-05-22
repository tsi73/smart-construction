# Project and Team API Contract

## Project endpoints

| Method | Path | Description | Payload |
| :--- | :--- | :--- | :--- |
| `POST` | `/projects` | Create a new project | `ProjectCreate` (name, total_budget, client_name, client_email, etc.) |
| `GET` | `/projects` | List projects (paginated) | - |
| `GET` | `/projects/{project_id}` | Get project details | - |
| `PUT` | `/projects/{project_id}` | Update project | `ProjectUpdate` |
| `DELETE` | `/projects/{project_id}` | Delete project | - |
| `GET` | `/projects/{project_id}/dashboard` | Get summary dashboard | - |

## Project member endpoints

| Method | Path | Description | Payload |
| :--- | :--- | :--- | :--- |
| `GET` | `/projects/{project_id}/members` | List members with user details | - |
| `POST` | `/projects/{project_id}/members` | Add member directly (Admin only) | `ProjectMemberCreate` (user_id, role) |
| `PATCH` | `/projects/{project_id}/members/{user_id}` | Update member role | `ProjectMemberUpdate` (role) |
| `DELETE` | `/projects/{project_id}/members/{user_id}` | Remove member | - |

## Invitation endpoints

| Method | Path | Description | Payload |
| :--- | :--- | :--- | :--- |
| `POST` | `/projects/{project_id}/invitations` | Invite by email | `ProjectInvitationCreate` (email, role) |
| `GET` | `/projects/{project_id}/invitations` | List pending invitations | - |
| `POST` | `/projects/invitations/accept` | Accept via token | `ProjectInvitationAccept` (token) |

## Role update endpoints
Handled via `PATCH /projects/{project_id}/members/{user_id}`.

## Backend behavior notes
- **Creator Role**: The project creator automatically becomes `project_manager` (Owner).
- **Direct Addition**: If an invited email already exists in the system, they are added directly as a member and the invitation status is marked as `accepted`.
- **Pending Status**: If the email is new, a `pending` invitation is created.
- **Member Removal Race Condition**: Backend prevents removing the last Project Manager.

## Mobile implementation notes
- Use `ProjectCreate` for the `/projects/new` flow.
- Maps `project_manager` role to "Project Manager" (localized).
- Site Engineers have restricted access to Team Management.
