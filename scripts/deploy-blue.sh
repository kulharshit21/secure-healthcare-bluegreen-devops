#!/bin/bash
# Deploy Blue Deployment to Kubernetes
# Initial deployment setup with ConfigMap, Secret, RBAC, Blue deployment and services

set -e

echo "=========================================="
echo "Deploying Blue Environment"
echo "=========================================="

NAMESPACE="healthcare-devops"

echo ""
echo "Step 1: Creating/Verifying namespace..."
kubectl apply -f k8s/namespace.yaml

echo ""
echo "Step 2: Creating ConfigMap..."
kubectl apply -f k8s/configmap.yaml

echo ""
echo "Step 3: Creating Secret..."
kubectl apply -f k8s/secret.yaml
echo "Note: Update secrets in production with real values"

echo ""
echo "Step 4: Setting up RBAC..."
kubectl apply -f k8s/rbac.yaml

echo ""
echo "Step 5: Deploying Blue deployment..."
kubectl apply -f k8s/blue-deployment.yaml

echo ""
echo "Step 6: Creating services..."
kubectl apply -f k8s/service.yaml

echo ""
echo "Step 7: Waiting for Blue deployment to be ready..."
kubectl rollout status deployment/healthcare-api-blue -n $NAMESPACE --timeout=5m

echo ""
echo "=========================================="
echo "✓ Blue deployment completed"
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
echo "Testing Blue endpoint:"
echo "  kubectl port-forward svc/healthcare-service 8080:80 -n $NAMESPACE"
echo "  curl http://localhost:8080/version"
echo ""
