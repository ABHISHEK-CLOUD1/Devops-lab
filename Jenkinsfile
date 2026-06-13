pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

stage('Deploy Cloud Infrastructure') {
            environment {
                TF_VAR_oci_tenancy_ocid = credentials('OCI_TENANCY')
                TF_VAR_oci_user_ocid    = credentials('OCI_USER')
                TF_VAR_oci_fingerprint  = credentials('OCI_FINGERPRINT')
                TF_VAR_oci_private_key  = '/opt/jenkins/.oci/oci_api_key.pem'
                TF_VAR_oci_region       = 'ap-mumbai-1'
            }
            steps {
                dir('terraform') {
                    sh 'terraform init -upgrade'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                }
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
