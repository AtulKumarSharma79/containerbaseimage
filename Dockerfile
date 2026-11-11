# Onboarding Tracker container image.
# Build the jar first on your machine:   gradlew.bat bootJar
# Then build the image:                  docker build -t onboarding-tracker:before .

FROM openjdk:17-jdk-slim

WORKDIR /app
COPY build/libs/onboarding-tracker-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
