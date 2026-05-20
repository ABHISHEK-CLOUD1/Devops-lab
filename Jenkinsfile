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
         stage('Verify Nginx') {
            steps {
                sh 'curl -s http://10.10.10.101 | grep -o "<title>.*</title>"'
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
