# ============================
# Stage 1 - Maven Build
# ============================

FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

COPY --from=app . .

RUN mvn clean package -DskipTests


# ============================
# Stage 2 - Runtime
# ============================

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
