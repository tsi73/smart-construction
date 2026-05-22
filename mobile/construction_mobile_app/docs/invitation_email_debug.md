# Invitation Email Debug

## Local Backend Behavior
In the local development environment, the backend is configured to send invitation emails via SMTP. However, if SMTP settings are not provided in the `.env` file, the backend will skip the actual email delivery and log a warning.

## Email Configuration Required
To enable real email delivery, the following environment variables must be set in the backend:
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_EMAIL`
- `SMTP_PASSWORD`

## Does Local Dev Send Real Email?
By default, **no**. Most local setups do not have a configured SMTP server. The backend logs the invitation token to the console/logs, which can be used for manual verification if needed.

## Invitation Record Creation
When an invitation is "sent" from the mobile app:
1.  A record is created in the `project_invitations` table with a `pending` status.
2.  A unique `token` is generated.
3.  The backend attempts to call the email service.
4.  If the user already exists in the system, they are added directly as a project member, and the invitation is marked as `accepted` immediately.

## Pending Invitation Display
Pending invitations are displayed in the **Team Management** section of the mobile app. This allows Project Managers to see who has been invited but has not yet joined the project.

## Invited User Acceptance Flow
Since real emails might not be delivered locally, the system supports **Auto-Acceptance**:
1.  The Project Manager invites a user by email.
2.  The invited user registers a new account using the **exact same email address**.
3.  Upon successful registration, the backend checks for any pending invitations for that email.
4.  The user is automatically added to the respective projects with the assigned role.

## Known Limitations
- **No Deep Links**: Without a real email, users cannot click a link to accept. They must manually sign up/log in.
- **Email Uniqueness**: The system relies on email string matching for auto-acceptance.

## How to Test
1.  Log in as a Project Manager.
2.  Navigate to a project -> Team -> Invite Member.
3.  Enter an email that does not exist in the system (e.g., `test.site@example.com`).
4.  Confirm the success dialog explaining the local limitation.
5.  Log out.
6.  Register a new user with `test.site@example.com`.
7.  Log in and verify the project appears in the project list.
