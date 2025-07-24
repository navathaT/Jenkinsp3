pipeline {
    agent any

    environment {
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ADMIN_PASSWORD_PLACEHOLDER = 'pwdtoimportterraform'

        TF_BACKEND_RESOURCE_GROUP_NAME = "rg-dev"
        TF_BACKEND_STORAGE_ACCOUNT_NAME = "storacctdev123"
        TF_BACKEND_CONTAINER_NAME = "tfstate"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/navathaT/Terraform-Iac.git', branch: "${env.BRANCH_NAME}"
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

        // ... rest of your stages unchanged
    }
    
    post {
        always { cleanWs() }
        success { echo 'Terraform pipeline completed successfully!' }
        failure { echo 'Terraform pipeline failed. Check the build logs for errors.' }
    }
}
