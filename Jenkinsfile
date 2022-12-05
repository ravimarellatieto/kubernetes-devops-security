pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }
/*
        stage('SAST - Sonar Qube'){
          steps{
        sh    "mvn sonar:sonar \
  -Dsonar.projectKey=numeric-application \
  -Dsonar.host.url=http://devsecops.brazilsouth.cloudapp.azure.com:9000 \
  -Dsonar.login=af3ce9c09c97caec95e51e3574e4dd9104dadaf8"
          }
        }
     */   
     stage('SAST - Sonar Qube'){
          steps{
            withSonarQubeEnv('SonarQube'){
               sh    "mvn sonar:sonar \
  -Dsonar.projectKey=numeric-application \
  -Dsonar.host.url=http://devsecops.brazilsouth.cloudapp.azure.com:9000 "
            }
            timeout(time:2, unit: 'MINUTES'){
                script{
                  waitForQualityGate abortPipeline: true
                }
            }
          }
          }
          
      stage('Unit Tests - Jacoco') {
            steps {
              sh "mvn test"
              
            }
            post{
              always{
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }   
        stage('Mutation Tests - PIT'){
          steps{
            sh "mvn org.pitest:pitest-maven:mutationCoverage"

          }
           post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
        }
        stage('Vulnerability Scan - Dependency Check'){
            steps{
              sh "mvn dependency-check:check"
            }
            post{
              always{
                dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              }
            }
          }
        stage('Docker Build and Push'){
          steps{
            withDockerRegistry([credentialsId: "docker-hub",url:""]){
            sh 'printenv'
            sh 'docker build -t ravimarella/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push ravimarella/numeric-app:""$GIT_COMMIT""'}
          } 
        }
        stage('Kubernetes Deployment - DEV'){
          steps{
            withKubeConfig([credentialsId: 'kubeconfig']){
              sh "sed -i 's#replace#ravimarella/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          }
        }
    }
}