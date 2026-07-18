# Fitness Academy Management System

A role-based gym operations platform built with PHP and MySQL. The project brings member administration, class scheduling, QR attendance, payments, coach content, progress tracking, and reporting into one web application.

> Portfolio source project: no public production deployment is currently maintained.

## Highlights

- Role-specific workspaces for administrators, staff, coaches, and members
- Membership plans, enrollment status, renewals, and payment history
- Fitness class scheduling, capacity management, and member enrollment
- Static QR codes with kiosk-style check-in and check-out flows
- Staff point of sale for memberships and in-person transactions
- Coach applications, schedules, client progress, and video content
- Member progress history, analytics, and AI-assisted recommendations
- Administrative dashboards, account status controls, audit trails, and reports
- Discount-document OCR and transactional email support

## Technology

| Area | Tools |
| --- | --- |
| Application | PHP, HTML, CSS, JavaScript |
| Data | MySQL 5.7+ or MariaDB 10.2+, PDO |
| Dependencies | Composer, PHPMailer, TCPDF |
| Integrations | PayMongo, Azure Computer Vision, OpenRouter, SMTP |
| Automation | GitHub Actions, Azure Web Apps workflow |

## User roles

| Role | Primary capabilities |
| --- | --- |
| Administrator | Manage users, memberships, employees, approvals, analytics, reports, and audit records |
| Staff | Register members, operate POS, manage attendance, and assist with day-to-day gym operations |
| Coach | Manage classes, clients, progress records, announcements, and training content |
| Member | Maintain a profile, purchase memberships, enroll in classes, check attendance, and track progress |

## Project structure

```text
.
├── api/          # JSON endpoints for analytics, classes, and recommendations
├── assets/       # Shared styles, scripts, layout fragments, and public images
├── attendance/   # QR generation and kiosk attendance handlers
├── config/       # Safe configuration templates and setup documentation
├── includes/     # Role dashboards and application workflows
├── uploads/      # Runtime media location; contents are intentionally ignored
├── index.php     # Application entry point
└── schema.sql    # Database tables, views, triggers, procedures, and events
```

## Local setup

### Requirements

- PHP 8.2 or newer with PDO MySQL, cURL, OpenSSL, GD, fileinfo, and mbstring
- MySQL 5.7+ or MariaDB 10.2+
- Composer
- A local web server such as Apache, Nginx, or PHP's development server

### 1. Clone and install

```bash
git clone https://github.com/x32u/Fitness-Academy-Management.git
cd Fitness-Academy-Management
composer install
```

### 2. Create the database

```bash
mysql -u root -p < schema.sql
```

The schema creates `gym_management`. Review it before importing if you need a different database name or want to omit MySQL events.

No administrator account is seeded. Create the first administrator through a protected setup process and assign a unique password.

### 3. Configure the application

Copy both templates:

```bash
cp config/database.template.php config/database.php
cp config/api_config.template.php config/api_config.php
```

Update the copied files with local database and integration values. Both destination files are ignored by Git.

The optional integrations are documented in [config/API_SETUP.md](config/API_SETUP.md):

- PayMongo for checkout and payment processing
- Azure Computer Vision for discount-document OCR
- OpenRouter for recommendation generation
- SMTP for account and receipt emails

### 4. Prepare runtime storage

```bash
mkdir -p uploads/profile_images uploads/coach_resumes uploads/discount_ids uploads/coach_videos uploads/video_thumbnails
```

Ensure the web-server user can write to these directories. Runtime uploads are ignored because they may contain profile photos, identity documents, resumes, payment artifacts, or private videos.

### 5. Start locally

```bash
php -S localhost:8000
```

Open `http://localhost:8000`.

## Security notes

- Never commit `config/database.php`, `config/api_config.php`, environment files, deployment profiles, database exports, or runtime uploads.
- Use provider test credentials during development and keep server-side keys outside the public web root when deploying.
- Replace placeholder configuration values before running integration-dependent features.
- Uploaded files require server-side validation, restricted permissions, and private storage appropriate to the deployment environment.
- Review authentication, authorization, CSRF protection, and payment callbacks before treating this portfolio project as production-ready.

## Validation

Run PHP syntax checks before submitting changes:

```bash
find . -path ./vendor -prune -o -name '*.php' -exec php -l {} \;
composer validate --no-check-publish
```

## License

This project is available under the [MIT License](LICENSE).
