// Secure CI/CD Pipeline for Healthcare API Blue-Green Deployment
// Declarative Jenkinsfile

pipeline {
    agent any
    
    // Environment variables for pipeline
    environment {
        // Application configuration
        APP_NAME = "healthcare-api"
        NAMESPACE = "healthcare-devops"
        SERVICE_NAME = "healthcare-service"
        GREEN_SERVICE = "healthcare-green-service"
        
        // Docker configuration
        DOCKER_REGISTRY = "docker.io"
        DOCKERHUB_USERNAME = "your-dockerhub-username"
        DOCKERHUB_CREDENTIALS_ID = "dockerhub-credentials"
        DOCKER_IMAGE = "${DOCKERHUB_USERNAME}/${APP_NAME}"
        BUILD_TAG = "${BUILD_NUMBER}"
        
        // Kubernetes configuration
        BLUE_DEPLOYMENT = "healthcare-api-blue"
        GREEN_DEPLOYMENT = "healthcare-api-green"
        
        // Security scanning
        TRIVY_SEVERITY = "HIGH,CRITICAL"
        TRIVY_EXIT_CODE = "0"
    }
    
    options {
        // Keep last 30 builds
        buildDiscarder(logRotator(numToKeepStr: '30'))
        // Add timestamps to console output
        timestamps()
        // Timeout after 1 hour
        timeout(time: 1, unit: 'HOURS')
        // Disable concurrent builds
        disableConcurrentBuilds()
    }
    
    stages {
        
        stage('1. Checkout Code') {
            description 'Fetch source code from repository'
            steps {
                script {
                    echo "========== Checkout Stage =========="
                    checkout scm
                    sh 'git log --oneline -5'
                }
            }
        }
        
        stage('2. Environment Info') {
            description 'Display environment and tool versions'
            steps {
                script {
                    echo "========== Environment Information =========="
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Build Tag: ${BUILD_TAG}"
                    echo "Workspace: ${WORKSPACE}"
                    echo "App Name: ${APP_NAME}"
                    echo "Namespace: ${NAMESPACE}"
                    echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_TAG}"
                    
                    // Show tool versions
                    sh '''
                        echo "=== Docker Version ==="
                        docker --version || echo "Docker not available"
                        
                        echo "=== Kubernetes CLI Version ==="
                        kubectl version --client || echo "kubectl not available"
                        
                        echo "=== Python Version ==="
                        python3 --version || echo "Python not available"
                        
                        echo "=== Trivy Version ==="
                        trivy --version || echo "Trivy not available"
                    '''
                }
            }
        }
        
        stage('3. Install Dependencies') {
            description 'Install Python dependencies for testing'
            steps {
                script {
                    echo "========== Installing Dependencies =========="
                    sh '''
                        cd app
                        python3 -m pip install --upgrade pip
                        pip install -r requirements.txt
                        echo "Dependencies installed successfully"
                    '''
                }
            }
        }
        
        stage('4. Unit Tests') {
            description 'Run pytest unit tests'
            steps {
                script {
                    echo "========== Running Unit Tests =========="
                    sh '''
                        cd app
                        python3 -m pytest test_app.py -v --tb=short --junit-xml=test-results.xml
                        echo "Unit tests completed"
                    '''
                }
                // Publish test results
                junit 'app/test-results.xml'
            }
        }
        
        stage('5. Build Docker Image') {
            description 'Build Docker image with multiple tags'
            steps {
                script {
                    echo "========== Building Docker Image =========="
                    sh '''
                        echo "Building image: ${DOCKER_IMAGE}:${BUILD_TAG}"
                        docker build \
                            -t ${DOCKER_IMAGE}:${BUILD_TAG} \
                            -t ${DOCKER_IMAGE}:green \
                            -t ${DOCKER_IMAGE}:latest \
                            -f Dockerfile \
                            .
                        
                        echo "Docker image built successfully"
                        echo "Image tags created:"
                        docker images | grep ${DOCKER_IMAGE} | head -3
                    '''
                }
            }
        }
        
        stage('6. Security Scan with Trivy') {
            description 'Scan Docker image for vulnerabilities'
            steps {
                script {
                    echo "========== Trivy Security Scan =========="
                    sh '''
                        # Install Trivy if not available
                        if ! command -v trivy &> /dev/null; then
                            echo "Installing Trivy..."
                            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                        fi
                        
                        echo "Scanning image: ${DOCKER_IMAGE}:${BUILD_TAG}"
                        trivy image \
                            --exit-code ${TRIVY_EXIT_CODE} \
                            --severity ${TRIVY_SEVERITY} \
                            --format table \
                            ${DOCKER_IMAGE}:${BUILD_TAG} || true
                        
                        # Generate JSON report for archiving
                        trivy image \
                            --format json \
                            --output trivy-scan-${BUILD_NUMBER}.json \
                            ${DOCKER_IMAGE}:${BUILD_TAG} || true
                        
                        echo "Trivy scan completed"
                    '''
                }
                // Archive scan results
                archiveArtifacts artifacts: 'trivy-scan-*.json', allowEmptyArchive: true
            }
        }
        
        stage('7. Docker Login') {
            description 'Authenticate with Docker registry'
            steps {
                script {
                    echo "========== Docker Registry Login =========="
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "${DOCKER_PASS}" | docker login -u ${DOCKER_USER} --password-stdin
                            echo "Docker login successful"
                        '''
                    }
                }
            }
        }
        
        stage('8. Push Docker Image') {
            description 'Push image to Docker registry'
            steps {
                script {
                    echo "========== Pushing Docker Image =========="
                    sh '''
                        echo "Pushing image: ${DOCKER_IMAGE}:${BUILD_TAG}"
                        docker push ${DOCKER_IMAGE}:${BUILD_TAG}
                        
                        echo "Pushing image: ${DOCKER_IMAGE}:green"
                        docker push ${DOCKER_IMAGE}:green
                        
                        echo "Pushing image: ${DOCKER_IMAGE}:latest"
                        docker push ${DOCKER_IMAGE}:latest
                        
                        echo "Docker images pushed successfully"
                    '''
                }
            }
        }
        
        stage('9. Deploy Green to Kubernetes') {
            description 'Deploy new version to Green environment'
            steps {
                script {
                    echo "========== Deploying Green Environment =========="
                    sh '''
                        # Check if namespace exists
                        kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}
                        
                        # Apply configuration, secrets, RBAC
                        echo "Applying namespace..."
                        kubectl apply -f k8s/namespace.yaml
                        
                        echo "Applying ConfigMap..."
                        kubectl apply -f k8s/configmap.yaml
                        
                        echo "Applying Secret..."
                        kubectl apply -f k8s/secret.yaml
                        
                        echo "Applying RBAC..."
                        kubectl apply -f k8s/rbac.yaml
                        
                        # Deploy Blue (if not exists)
                        echo "Applying Blue Deployment..."
                        kubectl apply -f k8s/blue-deployment.yaml
                        
                        # Deploy Green
                        echo "Applying Green Deployment..."
                        kubectl apply -f k8s/green-deployment.yaml
                        
                        # Apply Services
                        echo "Applying Services..."
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/green-service.yaml
                        
                        # Update Green deployment image
                        echo "Updating Green deployment image to build ${BUILD_TAG}..."
                        kubectl set image deployment/${GREEN_DEPLOYMENT} \
                            ${APP_NAME}=${DOCKER_IMAGE}:${BUILD_TAG} \
                            -n ${NAMESPACE} \
                            --record
                        
                        echo "Waiting for Green deployment rollout..."
                        kubectl rollout status deployment/${GREEN_DEPLOYMENT} \
                            -n ${NAMESPACE} \
                            --timeout=5m
                        
                        echo "Green deployment successful"
                    '''
                }
            }
        }
        
        stage('10. Smoke Test Green') {
            description 'Test Green deployment before switching traffic'
            steps {
                script {
                    echo "========== Smoke Testing Green Environment =========="
                    sh '''
                        echo "Getting Green service info..."
                        kubectl get svc ${GREEN_SERVICE} -n ${NAMESPACE}

                        echo "Testing Green endpoints from a temporary curl pod..."
                        kubectl run smoke-test --rm -i --restart=Never --image=curlimages/curl:8.10.1 --command -- sh -lc "curl -fsS http://${GREEN_SERVICE}.${NAMESPACE}.svc.cluster.local/health && curl -fsS http://${GREEN_SERVICE}.${NAMESPACE}.svc.cluster.local/version && curl -fsS http://${GREEN_SERVICE}.${NAMESPACE}.svc.cluster.local/patients"

                        echo "Smoke tests completed"
                    ''' 
                }
            }
        }
        
        stage('11. Switch Traffic to Green') {
            description 'Patch service selector from Blue to Green'
            input {
                message "Ready to switch production traffic to Green?"
                ok "Switch to Green"
                submitter "admin"
            }
            steps {
                script {
                    echo "========== Switching Traffic to Green =========="
                    sh '''
                        echo "Patching ${SERVICE_NAME} selector to Green..."
                        kubectl patch service ${SERVICE_NAME} \
                            -n ${NAMESPACE} \
                            -p '{"spec":{"selector":{"app":"healthcare-api","version":"green"}}}'
                        
                        echo "Waiting for endpoints to update..."
                        sleep 3
                        
                        echo "Service patched successfully"
                    '''
                }
            }
        }
        
        stage('12. Verify Production') {
            description 'Verify production service points to Green'
            steps {
                script {
                    echo "========== Verifying Production Environment =========="
                    sh '''
                        echo "Service selector after switch:"
                        kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'
                        echo ""
                        
                        echo "Verifying endpoints..."
                        kubectl get endpoints ${SERVICE_NAME} -n ${NAMESPACE}

                        echo "Testing production service from a temporary curl pod..."
                        kubectl run production-test --rm -i --restart=Never --image=curlimages/curl:8.10.1 --command -- sh -lc "curl -fsS http://${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local/health && curl -fsS http://${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local/version"
                        
                        echo "Production verification completed"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "========== Pipeline Execution Summary =========="
            sh '''
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Build Status: $?"
                echo "Kubernetes Deployments:"
                kubectl get deployments -n ${NAMESPACE} || echo "Namespace not ready"
                echo ""
                echo "Kubernetes Pods:"
                kubectl get pods -n ${NAMESPACE} || echo "Namespace not ready"
            '''
        }
        
        success {
            echo "========== Deployment Successful =========="
            sh '''
                echo "✓ Build ${BUILD_NUMBER} completed successfully"
                echo "✓ Docker image pushed: ${DOCKER_IMAGE}:${BUILD_TAG}"
                echo "✓ Green deployment updated"
                echo "✓ Production traffic switched to Green"
                echo ""
                echo "Production Service Status:"
                kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE} -o wide
            '''
        }
        
        failure {
            echo "========== Deployment Failed =========="
            sh '''
                echo "✗ Build ${BUILD_NUMBER} failed"
                echo "Rollback command:"
                echo "kubectl patch service ${SERVICE_NAME} -n ${NAMESPACE} -p '{\"spec\":{\"selector\":{\"app\":\"healthcare-api\",\"version\":\"blue\"}}}'"
                echo ""
                echo "Pod logs for debugging:"
                kubectl logs -l app=healthcare-api -n ${NAMESPACE} --tail=50 || echo "Pods not ready"
            '''
        }
        
        unstable {
            echo "========== Pipeline Unstable =========="
            sh '''
                echo "⚠ Build ${BUILD_NUMBER} is unstable"
                echo "Check test results and logs"
            '''
        }
        
        cleanup {
            echo "========== Cleanup =========="
            // Log cleanup info
            sh 'echo "Pipeline execution completed"'
        }
    }
}
