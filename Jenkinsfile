pipeline {
    agent any

    environment {
        // Azure Service Principal credentials (set in Jenkins credentials store)
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ADMIN_PASSWORD_PLACEHOLDER = 'pwdtoimportterraform'

        // Terraform backend config
        TF_BACKEND_RESOURCE_GROUP_NAME = "rg-dev"
        TF_BACKEND_STORAGE_ACCOUNT_NAME = "storacctdev123"
        TF_BACKEND_CONTAINER_NAME = "tfstate"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: env.BRANCH_NAME, url: 'https://github.com/navathaT/Jenkinsp3.git'
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    sh """
                    terraform init \\
                    -backend-config='resource_group_name=${TF_BACKEND_RESOURCE_GROUP_NAME}' \\
                    -backend-config='storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT_NAME}' \\
                    -backend-config='container_name=${TF_BACKEND_CONTAINER_NAME}' \\
                    -backend-config='key=${env.BRANCH_NAME}.terraform.tfstate'
                    """
                }
            }
        }

        stage('Validate Terraform Configuration') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan Terraform Changes') {
            steps {
                script {
                    def tfvarsFile = (env.BRANCH_NAME == 'production') ? 'production.tfvars' :
                                     (env.BRANCH_NAME == 'staging') ? 'staging.tfvars' : 'staging.tfvars'
                    sh "terraform plan -var-file=${tfvarsFile} -out=tfplan"
                }
            }
        }

        stage('Apply Terraform Changes') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'production'
                }
            }
            steps {
                script {
                    if (env.BRANCH_NAME == 'production') {
                        input message: 'Proceed with Production deployment? (Requires manual approval)', ok: 'Deploy Now'
                    }
                    def tfvarsFile = (env.BRANCH_NAME == 'production') ? 'production.tfvars' : 'staging.tfvars'
                    sh "terraform apply -auto-approve -var-file=${tfvarsFile} tfplan"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Terraform pipeline completed successfully!'
        }
        failure {
            echo 'Terraform pipeline failed. Check the build logs for errors.'
        }
    }
}
