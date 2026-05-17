pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Code pulled from GitHub!'
            }
        }

        stage('Run Ansible') {
            steps {
                sh 'ansible --version'
                sh 'ansible-playbook -i inventory.ini install-nginx.yml'
            }
        }

        stage('Verify') {
            steps {
                sh 'curl -s http://192.168.155.131 | grep -o "<title>.*</title>"'
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! Nginx is running.'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
