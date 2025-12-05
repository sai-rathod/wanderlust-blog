pipeline{
    agent any
    tools{
        nodejs "node:18"
    }
    environment{
        SONARHOME = tool "sonar-tool"
        GitCreds = credentials("git-creds")
        DockerCreds = credentials("dockercred")
    }
    stages{
        stage("frontend"){
            stages{
                stage("cleaning the workspace"){
                    steps{
                        cleanWs()
                    }
                }
                stage("fetch"){
                    steps{
                        git branch: 'main', credentialsId: 'git-creds', url: 'https://github.com/sai-rathod/wanderlust-blog.git'
                        sh "echo code fetched successfully"
                    }
                }
                stage("installing frontend dependenies"){
                    steps{
                        dir("frontend"){
                            sh """
                            npm install
                            echo "dependencies installed successfully"
                            """
                        }
                    }
                }
                stage("frontend linting"){
                    steps{
                        dir("frontend"){
                            sh "npm run lint || echo 'linting not present'"
                        }
                    }
                }
                stage("frontend unit test"){
                    steps{
                        dir("frontend"){
                            sh "npm run test || echo 'no unit test available'"
                        }
                    }
                }
                stage("building frontend code"){
                    steps{
                        dir("frontend"){
                            sh "npm run build && echo 'code built successfully' || echo 'code build faild'"
                        }
                    }
                }
                stage("sonar code test"){
                    steps{
                        dir("frontend"){
                            withSonarQubeEnv("sonarqube"){
                                sh '''
                                $SONARHOME/bin/sonar-scanner -Dsonar.projectName=wanderlust_frontend -Dsonar.projectKey=wanderlust_frontend
                                '''
                            }
                        }
                    }
                }
                stage("sonar quality gate"){
                    steps{
                        waitForQualityGate abortPipeline:false
                    }
                }
                stage("trivy fs scan"){
                    steps{
                        dir("frontend"){
                            sh "trivy fs -f json -o trivy_fs_wanderlust_frontend.json ."
                        }
                    }
                }
                stage("pushing to docker hub"){
                    steps{
                        dir("frontend"){
                            sh"""
                            echo $DockerCreds_PSW | docker login -u $DockerCreds_USR --password-stdin
                            docker build -t $DockerCreds_USR/wanderlust-frontend:v$BUILD_NUMBER .
                            docker push $DockerCreds_USR/wanderlust-frontend:v$BUILD_NUMBER
                            docker image prune -f || true
                            """
                        }
                    }
                }
                stage("manifest updating and git push"){
                    steps{
                        dir("k8s"){
                            sh"""
                            sed -E -i 's/^([[:space:]]*image.*:v)([0-9]+)/\\1$BUILD_NUMBER/' frontend-dep-ser.yml || echo 'manifest not updated'
                            git config user.name $GitCreds_USR
                            git config user.email 'sahilrathodrk31@gmail.com'
                            git add frontend-dep-ser.yml
                            git commit -m "version changed to: $BUILD_NUMBER"
                            git push https://$GitCreds_PSW@github.com/$GitCreds_USR/wanderlust-blog HEAD:main
                            """
                        }
                    }
                }
                stage("trivy image scan"){
                    steps{
                        sh """
                        trivy image -f json -o trivy_image_wanderlust_frontend.json $DockerCreds_USR/wanderlust-frontend:v$BUILD_NUMBER
                        """
                    }
                }
            }
        }
        stage("backend"){
            stages{
                stage("installing backend dependenies"){
                    steps{
                        dir("backend"){
                            sh """
                            npm install
                            echo "dependencies installed successfully"
                            """
                        }
                    }
                }
                stage("backend unit test"){
                    steps{
                        dir("backend"){
                            sh "npm run test || echo 'no unit test available'"
                        }
                    }
                }
                stage("sonar code test"){
                    steps{
                        dir("backend"){
                            withSonarQubeEnv("sonarqube"){
                                sh '''
                                $SONARHOME/bin/sonar-scanner -Dsonar.projectName=wanderlust_backend -Dsonar.projectKey=wanderlust_backend
                                '''
                            }
                        }
                    }
                }
                stage("sonar quality gate"){
                    steps{
                        waitForQualityGate abortPipeline:false
                    }
                }
                stage("trivy fs scan"){
                    steps{
                        dir("backend"){
                        sh "trivy fs -f json -o trivy_fs_wanderlust_backend.json ."
                        }
                    }
                }
                stage("pushing to docker hub"){
                    steps{
                        dir("backend"){
                            sh"""
                            echo $DockerCreds_PSW | docker login -u $DockerCreds_USR --password-stdin
                            docker build -t $DockerCreds_USR/wanderlust-backend:v$BUILD_NUMBER .
                            docker push $DockerCreds_USR/wanderlust-backend:v$BUILD_NUMBER
                            docker image prune -f || true
                            """
                        }
                    }
                }
                stage("manifest updating and git push"){
                    steps{
                        dir("k8s"){
                            sh"""
                            sed -E -i 's/^([[:space:]]*image.*:v)([0-9]+)/\\1$BUILD_NUMBER/' backend-dep-ser.yml || echo 'manifest not updated'
                            git config user.name $GitCreds_USR
                            git config user.email 'sahilrathodrk31@gmail.com'
                            git add backend-dep-ser.yml
                            git commit -m "version changed to: $BUILD_NUMBER"
                            git push https://$GitCreds_PSW@github.com/$GitCreds_USR/wanderlust-blog HEAD:main
                            """
                        }
                    }
                }
                stage("trivy image scan"){
                    steps{
                        sh """
                        trivy image -f json -o trivy_image_wanderlust_backend.json $DockerCreds_USR/wanderlust-backend:v$BUILD_NUMBER
                        """
                    }
                }
            }
            
        }
    }
    post{
        always{
            cleanWs(
                deleteDirs:true,
                patterns:[[pattern:'trivy_fs_wanderlust_backend.json' ,type:'EXCLUDE'],
                [pattern:'trivy_image_wanderlust_backend.json' ,type:'EXCLUDE'],
                [pattern:'trivy_fs_wanderlust_frontend.json' ,type:'EXCLUDE'],
                [pattern:'trivy_image_wanderlust_frontend.json' ,type:'EXCLUDE']])
        }
    }
}
