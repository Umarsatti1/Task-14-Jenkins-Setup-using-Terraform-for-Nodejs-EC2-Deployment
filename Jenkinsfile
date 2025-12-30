pipeline {
    agent any

    tools {
        nodejs 'nodejs'
    }

    environment {
        APP_EC2      = "ubuntu@10.0.1.xxx" // Add Application EC2 private IP
        BASE_DIR     = "/var/www"
        APP_NAME     = "nodeapp"
        APP_PORT     = "3000"

        APP_NEW      = "${BASE_DIR}/${APP_NAME}_new"
        APP_CURRENT  = "${BASE_DIR}/${APP_NAME}_current"
        APP_PREVIOUS = "${BASE_DIR}/${APP_NAME}_previous"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Umarsatti1/Task-14-Jenkins-Setup-using-Terraform-for-Nodejs-EC2-Deployment.git'
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    script {
                        try {

                            // Prepare new release
                            sh """
                                ssh -o StrictHostKeyChecking=no ${APP_EC2} '
                                    rm -rf ${APP_NEW}
                                    mkdir -p ${APP_NEW}
                                '
                            """

                            // Copy artifacts
                            sh """
                                scp -o StrictHostKeyChecking=no -r \
                                app.js package.json package-lock.json public \
                                ${APP_EC2}:${APP_NEW}
                            """

                            // Activate release
                            sh """
                                ssh -o StrictHostKeyChecking=no ${APP_EC2} '
                                    set -e

                                    rm -rf ${APP_PREVIOUS} || true
                                    mv ${APP_CURRENT} ${APP_PREVIOUS} || true
                                    mv ${APP_NEW} ${APP_CURRENT}

                                    cd ${APP_CURRENT}
                                    npm install --omit=dev

                                    pm2 restart ${APP_NAME} || pm2 start app.js --name ${APP_NAME}
                                    pm2 save
                                '
                            """

                            // Perform simple health check
                            sh """
                                curl --fail \
                                http://${APP_EC2.split('@')[1]}:${APP_PORT}/health
                            """

                        } catch (e) {

                            // Rollback
                            sh """
                                ssh -o StrictHostKeyChecking=no ${APP_EC2} '
                                    rm -rf ${APP_CURRENT} || true
                                    mv ${APP_PREVIOUS} ${APP_CURRENT} || true

                                    cd ${APP_CURRENT}
                                    npm install --omit=dev

                                    pm2 restart ${APP_NAME}
                                    pm2 save
                                '
                            """

                            error "Deployment failed. Rollback completed"
                        }
                    }
                }
            }
        }
    }
}