#!/bin/bash
# Deploy Green Deployment to Kubernetes
# Deploy new version to Green environment

set -e

echo "=========================================="
echo "Deploying Green Environment"
echo "=========================================="

NAMESPACE="healthcare-devops"
GREEN_DEPLOYMENT="healthcare-api-green"
DOCKER_IMAGE=${1:-"healthcare-api:green"}

echo "Using Docker Image: $DOCKER_IMAGE"
echo ""

echo "Step 1: Deploying Green deployment..."
kubectl apply -f k8s/green-deployment.yaml

echo ""
echo "Step 1b: Applying Green service..."
kubectl apply -f k8s/green-service.yaml

echo ""
echo "Step 2: Updating Green deployment image..."
kubectl set image deployment/$GREEN_DEPLOYMENT \
    healthcare-api=$DOCKER_IMAGE \
    -n $NAMESPACE \
    --record || echo "Warning: Image update may have failed"

echo ""
echo "Step 3: Waiting for Green deployment to be ready..."
kubectl rollout status deployment/$GREEN_DEPLOYMENT -n $NAMESPACE --timeout=5m

echo ""
echo "=========================================="
echo "✓ Green deployment completed"
echo "=========================================="
echo ""
echo "Deployment status:"
kubectl get deployments -n $NAMESPACE
echo ""
echo "Pod status:"
kubectl get pods -n $NAMESPACE
echo ""
echo "Service status:"
kubectl get svc -n $NAMESPACE
echo ""
echo "Testing Green endpoint:"
echo "  kubectl port-forward svc/healthcare-green-service 8081:80 -n $NAMESPACE"
echo "  curl http://localhost:8081/version"
echo ""
