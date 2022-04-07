pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
              withCredentials([string(credentialsId: 'issuetoken', variable: 'issuetoken')]) {
                sh 'tools/testenv Script'
              }
            }
        }
        stage('Publish') {
            steps {
                sh 'tools/testenv upload'
            }
        }
    }
}
