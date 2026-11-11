# Container Platform Standards (approved)

> This is a sample standard for the exercise. Replace the values with your organisation's real approved list.

## 1. Approved Java base images
Images must come from this list. Anything else needs an exception.

| Image | Allowed tags | Notes |
|---|---|---|
| `eclipse-temurin` | `21-jre`, `21-jdk`, `25-jre`, `25-jdk` (LTS versions only) | Runtime images use `-jre`. Build stages may use `-jdk`. |

Not approved: `openjdk` (deprecated on Docker Hub and no longer updated), any image tagged `latest`, any end-of-life Java or operating system release.

## 2. Image rules
1. **Pin the version.** Use a specific tag such as `21-jre`. Never `latest`.
2. **Smallest image that works.** The final image must contain a JRE only, not a full JDK or build tools.
3. **Do not run as root.** The container process must run as a non-root user.
4. **Keep build files out of the image.** Source code, Gradle caches and `.git` must not be in the final image.
5. **Use a `.dockerignore` file** so the build context stays small and clean.
6. **Expose only what is needed.** This app uses port 8080 only.

## 3. Vulnerability gate
Scan the final image before it is released. The image **passes** if:
- it has **0 CRITICAL** vulnerabilities, and
- it has **0 HIGH** vulnerabilities that already have a fix available.

Remaining findings must be listed with a reason.

## 4. Supported-version rule
The base image's Java version and operating system release must both still receive security updates from their vendor.
