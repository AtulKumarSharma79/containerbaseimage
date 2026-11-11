# Onboarding Tracker (container base image upgrade exercise)

Spring Boot 3.5 REST API with embedded H2, packaged by a `Dockerfile` that uses an outdated base image. Read [PROBLEM_STATEMENT.md](PROBLEM_STATEMENT.md) first, and [PLATFORM_STANDARDS.md](PLATFORM_STANDARDS.md) for the approved image rules.

## Run the app without Docker
```
gradlew.bat bootRun        (macOS/Linux: ./gradlew bootRun)
gradlew.bat test
```

## APIs
- `POST /api/employees` with `{ "name": "...", "role": "...", "onboardingDate": "yyyy-MM-dd" }` returns `201`.
- `GET /api/employees` returns `200` with all employees.
- `GET /actuator/health` returns `{"status":"UP"}`.
- Invalid input returns `400`.
