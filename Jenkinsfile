pipeline {
    agent any
    tools {
      maven 'maven3'
    }
    stages {
        stage('build') {
            steps {
                sh script: 'mvn clean package'
            }
        }
        stage('Upload War To Nexus'){
          steps{
            nexusArtifactUploader artifacts: [
              [
                artifactId: 'modresorts10war', 
                classifier: '', 
                file: 'target/modresorts10war-1.0.0.war', 
                type: 'war'
              ]
            ], 
            credentialsId: 'nexus3', 
            groupId: 'com.ibm.ta', 
            nexusUrl: '172.21.88.91:8081', 
            nexusVersion: 'nexus3', 
            protocol: 'http', 
            repository: 'webapp-release/', 
            version: '1.0.0'
          }
        }
    }
}
