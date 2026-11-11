# Exercise: Upgrade a Container Base Image for a Java Application

## 1. Overview
The Onboarding Tracker (the Spring Boot REST API from the earlier exercises) is packaged as a container image. Its `Dockerfile` uses the base image **`openjdk:17-jdk-slim`**. That image is **deprecated and no longer updated**, so it no longer receives security fixes, and it does not meet the approved platform standards.

**Your job is to upgrade the container image** to a supported, approved base image so that it:
1. **remediates vulnerabilities** (the scan result gets better),
2. **keeps vendor support** (the base image still receives updates), and
3. **aligns with the approved platform standards** in `PLATFORM_STANDARDS.md`,

while the application keeps working exactly as before.

| | |
|---|---|
| **Starting point** | `FROM openjdk:17-jdk-slim`, runs as root, full JDK in the final image |
| **Target** | An approved `eclipse-temurin` image, pinned tag, JRE-only runtime, non-root user, multi-stage build |
| **Tools** | Docker (Docker Desktop or equivalent), Trivy or Docker Scout, Bruno |
| **Application** | Spring Boot 3.5 on Java 17 or newer (no code changes needed) |
| **Time budget** | **4 hours in total, spread over 2 days** |

## 2. Learning objectives
By the end you will be able to:
- Explain why an unsupported base image is a security and compliance risk.
- Choose an approved base image and pin its version.
- Build a smaller, safer image with a multi-stage `Dockerfile`.
- Run a container as a non-root user and fix the permission problems that follow.
- Scan an image, read the result, and show a before-and-after improvement.

## 3. Prerequisites
- **Docker** installed and running (`docker version` works).
- **JDK 17 or newer** to build the jar locally for the baseline step.
- **Trivy** (https://trivy.dev) **or** Docker Scout (built into recent Docker Desktop) for scanning.
- **Bruno** to test the API.
- Internet access (images and libraries are downloaded).

## 4. Getting started
Clone the starter project, then build the jar, build the image and run it:

```bash
gradlew.bat bootJar
docker build -t onboarding-tracker:before .
docker run --rm -p 8080:8080 onboarding-tracker:before
```

On macOS or Linux, use `./gradlew` instead of `gradlew.bat`. If port 8080 is busy, use `-p 8081:8080` and call port 8081.

Check it works: `GET http://localhost:8080/actuator/health` returns `{"status":"UP"}`, and the two employee APIs work in Bruno (`POST` returns `201`, `GET` returns `200`).

## 5. Your task

### 5.1 Core tasks (everyone)
| # | Task | What "done" looks like |
|---|---|---|
| C1 | **Baseline.** Scan the `before` image and record: image size, number of CRITICAL and HIGH findings, and the user the container runs as. | A small table of the "before" numbers. |
| C2 | **Choose the base image.** Read `PLATFORM_STANDARDS.md`. Pick an approved image and tag, and write one sentence on why `openjdk:17-jdk-slim` is not acceptable. | Your choice and reason written down. |
| C3 | **Change the base image and pin the tag.** No `latest`. The runtime stage must use a JRE image. | `Dockerfile` uses an approved, pinned image. |
| C4 | **Make it a multi-stage build.** Build the jar inside the image (JDK stage), then copy only the jar into a JRE stage. Add a `.dockerignore`. | The image builds without running `gradlew bootJar` on your machine first. |
| C5 | **Run as a non-root user.** Create a user in the `Dockerfile` and switch to it with `USER`. Make sure the app can still write its database files. | `docker run ... id` shows a non-root user, and `POST /api/employees` still returns `201`. |
| C6 | **Prove it works.** Build the new image as `onboarding-tracker:after`, run it, and repeat the Bruno checks from section 4. | Same results as before. Screenshot of Bruno. |
| C7 | **Scan again and compare.** | A before-and-after table: size, CRITICAL, HIGH, user. The image passes the gate in section 3 of `PLATFORM_STANDARDS.md`, or you list the remaining findings with a reason. |

### 5.2 Stretch tasks (optional)
- **S1: Pin by digest.** Pin the base image by `@sha256:` digest as well as tag, and explain the trade-off (safer builds, but you must update the digest on purpose).
- **S2: Add a `HEALTHCHECK`.** Use `/actuator/health`. Check first which tools exist in your image (some minimal images have no `curl`).
- **S3: Container-aware JVM settings.** Set memory limits on the container and tune the JVM with `-XX:MaxRAMPercentage`. Show how the heap size follows the container limit.
- **S4: Generate an SBOM** (software bill of materials) for the image with Trivy or Docker Scout, and list the five largest packages.
- **S5: Harden the runtime.** Run with `--read-only`, `--cap-drop ALL` and a writable volume only for the data folder. Does the app still work?
- **S6: Try a smaller base** (for example an `-alpine` variant, if one exists for your Java version) and compare scan results and size. Note any compatibility issues.

## 6. Suggested time plan (4 hours)

| Day | Time | Steps |
|---|---|---|
| **Day 1** | 45 min | Set up Docker and the scanner, build and run the `before` image, baseline (C1) |
| | 30 min | Read the standards, choose the image (C2) |
| | 60 min | Change the base image, then convert to multi-stage with `.dockerignore` (C3, C4) |
| **Day 2** | 45 min | Non-root user and file permissions (C5) |
| | 30 min | Rebuild, test in Bruno (C6) |
| | 30 min | Rescan, compare, and write up (C7) |

Stop at 4 hours and submit what you have, with a note on what is left.

## 7. Background facts
- The official Docker Hub `openjdk` images are **deprecated** and are no longer updated. Maintained alternatives include `eclipse-temurin`.
- A **base image** is the starting point of your container. Its operating system packages and Java runtime are part of your attack surface, even if your own code is perfect.
- A **JDK** contains compilers and build tools. A **JRE** only runs programs. A runtime image needs only the JRE.
- Running as **root** inside a container makes a break-in more damaging. Non-root is the standard practice.
- Vulnerability scanners report **CVEs** (public vulnerability IDs) with a severity such as CRITICAL or HIGH. Some findings have a fixed version available, others do not.

## 8. Evaluation

| Criterion | Weight |
|---|---|
| Image uses an approved, supported, pinned base image with a JRE runtime | 25% |
| Multi-stage build and `.dockerignore` | 15% |
| Runs as non-root and the application still works | 20% |
| Before-and-after scan evidence meets the gate or is explained | 20% |
| Application behaviour unchanged in Bruno | 10% |
| Clarity of your write-up | 10% |

Stretch tasks earn recognition, not extra marks.

## 9. Rules
- Do not change the application code or tests.
- Only use base images allowed by `PLATFORM_STANDARDS.md`.
- Do not hide findings: report the real scan numbers.
- Do not copy another team member's `Dockerfile`. Pairing and discussion are welcome.
- Stay within 4 hours.

## 10. Submission
Submit your `Dockerfile`, `.dockerignore`, the before-and-after table, and Bruno screenshots showing `201`, `200` and the health check. Check with your instructor how to submit.

---

## Appendix A: Guide with examples

The examples use made-up names (`myapp`) so you can see the pattern. Apply it to your own project.

### A.1 How to work
1. Change one thing at a time, then rebuild and run.
2. Commit after each task.
3. Read the **first** error in the Docker build output.
4. If you are stuck for 15 minutes, ask a colleague or the instructor.

### A.2 Choosing and pinning the base image
```dockerfile
# BEFORE: deprecated image, full JDK, moving target
FROM openjdk:17-jdk-slim

# AFTER: approved image, specific version, JRE only (runtime stage)
FROM eclipse-temurin:21-jre
```
Check the available tags on Docker Hub (search for `eclipse-temurin`) and the allowed list in `PLATFORM_STANDARDS.md`. A tag like `21-jre` follows the 21 line, so rebuilds pick up security fixes. A tag like `latest` can change under you without warning, so never use it.

### A.3 The multi-stage pattern
Stage 1 has the tools to build. Stage 2 is small and only runs the result.

```dockerfile
# ---- Stage 1: build ----
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY . .
RUN ./gradlew bootJar --no-daemon

# ---- Stage 2: run ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /src/build/libs/myapp-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```
Things to check in your own project:
- The jar name comes from `rootProject.name` in `settings.gradle` and the version in `build.gradle`.
- On Windows, a `gradlew` file copied into a Linux image needs to be executable. If you see `permission denied`, look into `chmod +x gradlew` or `RUN sh gradlew ...`.
- The jar is built for Java 17, so it runs on 17, 21 or 25 images.

### A.4 `.dockerignore`
It keeps junk out of the build context, which makes builds faster and images cleaner. Typical entries:
```
build/
.gradle/
.git/
data/
*.md
```
Be careful not to ignore files the build needs (such as `gradle/` and `src/`).

### A.5 Running as non-root
```dockerfile
# create a user and group, make a folder it owns, then switch to the user
RUN groupadd --system app && useradd --system --gid app --no-create-home app \
 && mkdir -p /app/data && chown -R app:app /app
USER app
```
Tips:
- The user commands differ by operating system (Debian or Ubuntu use `groupadd` and `useradd`, Alpine uses `addgroup` and `adduser`). Check which your image uses.
- The H2 database writes to `./data`, relative to the working directory. A non-root user needs write permission on that folder, or the app fails at startup with a permission error.
- The database location can also be set with the `DB_URL` environment variable.
- Check the user with: `docker run --rm onboarding-tracker:after id`.

### A.6 Scanning
```bash
trivy image onboarding-tracker:before
trivy image --severity CRITICAL,HIGH onboarding-tracker:after
docker scout quickview onboarding-tracker:after
```
Use only one tool for the whole exercise so the numbers can be compared. Findings change daily as new vulnerabilities are published, so scan **before and after on the same day**. Image size: `docker images onboarding-tracker`.

### A.7 Common problems

| What you see | Usual cause | What to try |
|---|---|---|
| `manifest unknown` or `not found` when pulling | The tag does not exist | Check the exact tag on Docker Hub |
| `COPY failed: file not found` | Wrong jar name or path | Run `gradlew.bat bootJar` and look in `build/libs` |
| `gradlew: permission denied` or `not found` in the build stage | Line endings or file mode copied from Windows | Use `RUN sh gradlew bootJar`, and check line endings |
| App fails at startup with a file or permission error | The non-root user cannot write to the data folder | Create the folder and `chown` it before `USER` |
| Port already in use | Another program uses 8080 | Use `-p 8081:8080` |
| `useradd: not found` | The image is Alpine-based | Use the Alpine commands from A.5 |
| Scan numbers are unchanged | Old image scanned, or cached layers | Rebuild with `--no-cache` and rescan the right tag |

### A.8 Final checklist
- [ ] Base image is approved, supported and pinned (no `latest`).
- [ ] The final image uses a JRE, not a JDK.
- [ ] Multi-stage build works from a clean clone with only `docker build`.
- [ ] `.dockerignore` exists.
- [ ] The container runs as a non-root user.
- [ ] Bruno checks give the same results as before.
- [ ] The before-and-after table uses numbers from the same scanner on the same day.
