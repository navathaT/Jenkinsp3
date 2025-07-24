pipeline {
    agent any

    environment {
        // Define Azure credentials for Terraform
        // These should be set as Jenkins credentials and then referenced here.
        // Go to Jenkins -> Dashboard -> Manage Jenkins -> Manage Credentials -> (global) -> Add Credentials
        // Create Secret text credentials with these IDs and your actual values.
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ADMIN_PASSWORD_PLACEHOLDER = 'pwdtoimportterraform'

        // Terraform backend configuration from main.tf
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
            // Initialize Terraform with remote backend configuration
            // The 'key' for the state file is set dynamically based on the branch name.
                    sh """terraform init -backend-config="resource_group_name=${TF_BACKEND_RESOURCE_GROUP_NAME}" -backend-config="storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT_NAME}" -backend-config="container_name=${TF_BACKEND_CONTAINER_NAME}" -backend-config="key=${env.BRANCH_NAME}.terraform.tfstate"""
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
                    def tfvarsFile
                    if (env.BRANCH_NAME == 'staging') {
                        tfvarsFile = 'staging.tfvars'
                    } else if (env.BRANCH_NAME == 'production') {
                        tfvarsFile = 'production.tfvars'
                    } else {
                        // For other branches (e.g., main), you might still want to plan with staging vars or a default.
                        // Or, you might decide to skip 'apply' for non-staging/production branches.
                        tfvarsFile = 'staging.tfvars' // Default for main/development branches
                    }
                    sh "terraform plan -var-file=${tfvarsFile} -out=tfplan"
                }
            }
        }

        stage('Apply Terraform Changes') {
            // This stage will only run for 'staging' and 'production' branches.
            when {
                anyOf {
                    branch 'staging'
                    branch 'production'
                }
            }
            steps {
                script {
                    // Manual approval for production deployments
                    if (env.BRANCH_NAME == 'production') {
                        input message: 'Proceed with Production deployment? (Requires manual approval)', ok: 'Deploy Now'
                    }

                    def tfvarsFile
                    if (env.BRANCH_NAME == 'staging') {
                        tfvarsFile = 'staging.tfvars'
                    } else if (env.BRANCH_NAME == 'production') {
                        tfvarsFile = 'production.tfvars'
                    }
                    sh "terraform apply -auto-approve -var-file=${tfvarsFile} tfplan"
                }
            }
        }
    }

    post {
        always {
            // Clean up the workspace after the build.
            // This is important for subsequent builds to start with a clean slate.
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
