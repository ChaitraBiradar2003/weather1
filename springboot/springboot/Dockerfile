# Stage 1: Build Spring Boot app
FROM maven:3.9.5-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run Spring Boot app
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/springboot-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
