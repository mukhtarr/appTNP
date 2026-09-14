# appTNP

Flutter prototype for a Training and Placement Cell portal.

## Included modules
- Login and registration for ADMIN, PRINCIPAL, TP Officer, TP Departmental Coordinator, and STUDENT roles
- Department and class/batch master management
- Student CRUD with detailed academic/profile fields
- Bulk CSV student import with sample template and row-level validation feedback
- Opportunity posting, browsing, and student applications
- Dashboard stats with batch-wise, year-wise, package, recruiter, and search views
- Batch-wise export previews for Excel and PDF formats
- Student profile, placement journey, and application history
- Light/dark theme toggle, transitions, and Font Awesome based UI

## Architecture
- `lib/data`: API contract, in-memory backend adapter, repository
- `lib/domain`: application controller and role-based orchestration
- `lib/presentation`: login flow, dashboard, forms, and feature modules
- `lib/app`: app shell and theming

## Sample credentials
- `admin@app.tnp / admin123`
- `principal@app.tnp / principal123`
- `officer@app.tnp / officer123`
- `coordinator@app.tnp / coordinator123`
- `student@app.tnp / student123`

## Notes
This repository currently contains a seeded front-end prototype with a backend-ready API/repository boundary. Replace the in-memory adapter with a real service and database for production use.
