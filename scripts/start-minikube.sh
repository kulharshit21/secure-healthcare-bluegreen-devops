#!/bin/bash
# Start Minikube for Healthcare API Demo
# Run this script to initialize Minikube cluster

set -e

echo "=========================================="
echo "Starting Minikube for Healthcare API Demo"
echo "=========================================="

# Configuration
MINIKUBE_DRIVER="docker"
MINIKUBE_CPUS=${MINIKUBE_CPUS:-4}
MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-8192}
MINIKUBE_KUBEVERSION=${MINIKUBE_KUBEVERSION:-"latest"}

echo ""
echo "Configuration:"
echo "  Driver: $MINIKUBE_DRIVER"
echo "  CPUs: $MINIKUBE_CPUS"
echo "  Memory: ${MINIKUBE_MEMORY}MB"
echo ""

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "Error: minikube is not installed"
    echo "Install from: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    echo "Please start Docker Desktop"
    exit 1
fi

echo "Step 1: Starting Minikube..."
minikube start \
    --driver=$MINIKUBE_DRIVER \
    --cpus=$MINIKUBE_CPUS \
    --memory=$MINIKUBE_MEMORY \
    --kubernetes-version=$MINIKUBE_KUBEVERSION

echo ""
echo "Step 2: Enabling required addons..."
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard

echo ""
echo "Step 3: Configuring kubectl..."
kubectl cluster-info

echo ""
echo "Step 4: Verifying cluster status..."
kubectl get nodes
kubectl get pods -A

echo ""
echo "=========================================="
echo "✓ Minikube started successfully"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Deploy Blue: ./scripts/deploy-blue.sh"
echo "  2. Run pipeline or deploy Green manually"
echo "  3. Switch traffic: ./scripts/switch-to-green.sh"
echo "  4. View dashboard: minikube dashboard"
echo ""
echo "Useful commands:"
echo "  kubectl get all -n healthcare-devops"
echo "  kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops"
echo "  curl http://localhost:8080/health"
echo ""
