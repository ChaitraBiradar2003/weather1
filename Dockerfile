# ------------------------
# Build stage: Maven + JDK 21
# ------------------------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom and source code
COPY springboot/springboot/pom.xml .
COPY springboot/springboot/ .  

# Build the Spring Boot jar
RUN mvn clean package -DskipTests

# ------------------------
# Run stage: JDK 21 runtime
# ------------------------
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
