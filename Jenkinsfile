pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
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
        stage('Docker Build and Push'){
          steps{
            sh 'printenv'
            
          }
        }
    }
}