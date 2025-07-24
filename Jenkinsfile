pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'staging', 'production'],
            description: 'Select the environment to deploy to'
        )
    }

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
<<<<<<< HEAD
                git branch: env.BRANCH_NAME, url: 'https://github.com/navathaT/Jenkinsp3.git'
=======
                git url: 'https://github.com/navathaT/Jenkinsp3.git', branch: 'main'
            }
        }

        stage('Debug Workspace') {
            steps {
                sh 'ls -l'
                sh "cat ${params.ENV}.tfvars || echo '${params.ENV}.tfvars file not found'"
>>>>>>> 7fc5816 (Initial commit for Jenkins project)
            }
        }

        stage('Initialize Terraform') {
            steps {
<<<<<<< HEAD
                script {
                    sh """
                    terraform init \\
                    -backend-config='resource_group_name=${TF_BACKEND_RESOURCE_GROUP_NAME}' \\
                    -backend-config='storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT_NAME}' \\
                    -backend-config='container_name=${TF_BACKEND_CONTAINER_NAME}' \\
                    -backend-config='key=${env.BRANCH_NAME}.terraform.tfstate'
                    """
                }
=======
                sh """
                    terraform init \
                      -backend-config="resource_group_name=${TF_BACKEND_RESOURCE_GROUP_NAME}" \
                      -backend-config="storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT_NAME}" \
                      -backend-config="container_name=${TF_BACKEND_CONTAINER_NAME}" \
                      -backend-config="key=${params.ENV}.terraform.tfstate"
                """
>>>>>>> 7fc5816 (Initial commit for Jenkins project)
            }
        }

        stage('Validate Terraform Configuration') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan Terraform Changes') {
            steps {
<<<<<<< HEAD
                script {
                    def tfvarsFile = (env.BRANCH_NAME == 'production') ? 'production.tfvars' :
                                     (env.BRANCH_NAME == 'staging') ? 'staging.tfvars' : 'staging.tfvars'
                    sh "terraform plan -var-file=${tfvarsFile} -out=tfplan"
                }
=======
                sh "terraform plan -var-file=${params.ENV}.tfvars -out=tfplan"
            }
        }

        stage('Manual Approval for Prod Only') {
            when {
                expression { return params.ENV == 'production' }
            }
            steps {
                input message: 'Proceed with Production deployment?', ok: 'Deploy Now'
>>>>>>> 7fc5816 (Initial commit for Jenkins project)
            }
        }

        stage('Apply Terraform Changes') {
<<<<<<< HEAD
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
=======
            steps {
                sh "terraform apply -auto-approve -var-file=${params.ENV}.tfvars tfplan"
>>>>>>> 7fc5816 (Initial commit for Jenkins project)
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
