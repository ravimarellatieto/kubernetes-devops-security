FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
USER k8s-pipeline
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]