# Role Dashboard Report

## Supported Roles

The ConstructPro mobile application now supports 4 distinct project roles with tailored dashboards:

1.  **Project Manager (PM) / Owner**: Full project oversight, team management, and settings access.
2.  **Site Engineer**: Field-focused view with assigned tasks, daily log creation, and sync status.
3.  **Consultant**: Review and approval focus, with read-only access to tasks.
4.  **Office Engineer**: Documentation completeness review and progress monitoring.

## Dashboard Routing

Dashboard routing is handled by the `ProjectDashboardShell`, which resolves the UI based on the `currentProjectRoleProvider`.

- **Route**: `/project-dashboard` (mapped via `RouteNames.projectDashboard`)
- **Shell Implementation**: `lib/features/project/presentation/screens/dashboard/project_dashboard_shell.dart`
- **Role Mapping**: `owner` is automatically mapped to `project_manager` for UI consistency.

## Project Manager Dashboard

- **Status Grid**: Shows overall progress, budget spent, task counts, and team size.
- **Quick Actions**:
    - Add Task
    - Create Daily Log
    - Invite Team Member
    - Manage Contractors
    - Project Settings
- **Recent Activities**: Feed of recent log submissions and task completions.

## Site Engineer Dashboard

- **Status Grid**: Focuses on assigned task progress, total logs submitted, and sync status.
- **Quick Actions**:
    - Create Daily Log
    - My Tasks
    - Sync Queue
- **Assigned Tasks**: List of tasks specifically assigned to the user.

## Consultant Dashboard

- **Status Grid**: Focuses on pending reviews, approved logs, and project progress.
- **Quick Actions**:
    - Review Logs (Daily Log List)
    - View Tasks (Read-only)
    - Project Info
- **Review Queue**: Highlights logs awaiting consultant approval.

## Office Engineer Dashboard

- **Status Grid**: Focuses on documentation volume, pending reviews, and progress percentage.
- **Quick Actions**:
    - View Tasks (Read-only)
    - Daily Logs
    - Sync Queue
- **Completeness Queue**: Highlights logs needing office engineer review.

## Role-Based Navigation

The Bottom Navigation Bar dynamically adjusts based on the role:

| Role | Tabs |
| :--- | :--- |
| **Project Manager** | Home, Projects, Tasks, Logs, More |
| **Site Engineer** | Home, Projects, Tasks, Logs, More |
| **Consultant** | Home, Projects, Logs, More |
| **Office Engineer** | Home, Projects, Logs, More |

The **More** menu also filters actions (e.g., Team Management and Contractors are hidden from non-PM roles).

## Backend Limitations

- **Assigned Task Filtering**: Currently relies on local filtering by `assigned_to` field if supported by the backend response.
- **Review Workflow**: The mobile app supports the review flow (Consultant Approved -> PM Approved), but specific backend endpoints for review actions must be verified for each role.

## Runtime Test Results

Verified on Chrome (Flutter Web):
- [x] **PM Dashboard**: All cards and quick actions render correctly.
- [x] **Site Engineer Dashboard**: Focuses on field work; PM-only actions hidden.
- [x] **Consultant Dashboard**: Review focus; log creation hidden.
- [x] **Office Engineer Dashboard**: Progress focus; read-only behavior for tasks.
- [x] **Role Resolution**: Correctly handles `owner` as PM and shows error page if role is missing.

## Known Limitations

- Activity feed currently uses placeholder data until a dedicated activity backend endpoint is available.
- "Project Info" in the More menu currently shows a placeholder; detailed project metadata view is pending.
