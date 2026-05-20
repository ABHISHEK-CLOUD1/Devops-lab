pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }
        
        stage('Deploy Docker App via Ansible') {
            steps {
                echo 'Building and Deploying new Docker container...'
                sh 'ansible-playbook -i inventory.ini ansible/deploy-app.yml'
            }
        }
        
        stage('Verify') {
            steps {
                echo 'Deployment Successful! App is running on 10.10.10.108:8080'
            }
        }
    }

    post {
        success {
            echo 'Docker Deployment successful! V2 is live.'
        }
        failure {
            echo 'Docker Deployment failed! Check the Ansible logs.'
        }
    }
}
