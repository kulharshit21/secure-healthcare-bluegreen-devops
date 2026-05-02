#!/bin/bash
# Verify and Display Current Deployment Status

set -e

echo "=========================================="
echo "Healthcare API - Deployment Status"
echo "=========================================="

NAMESPACE="healthcare-devops"

echo ""
echo "========== Namespace =========="
kubectl get namespace $NAMESPACE

echo ""
echo "========== Deployments =========="
kubectl get deployments -n $NAMESPACE -o wide

echo ""
echo "========== Pods =========="
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "========== Replica Sets =========="
kubectl get rs -n $NAMESPACE

echo ""
echo "========== Services =========="
kubectl get svc -n $NAMESPACE -o wide

echo ""
echo "========== Service Selectors =========="
echo "Main Service (healthcare-service) selector:"
kubectl get svc healthcare-service -n $NAMESPACE -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

echo ""
echo "Green Service selector:"
kubectl get svc healthcare-green-service -n $NAMESPACE -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

echo ""
echo "========== Endpoints =========="
kubectl get endpoints -n $NAMESPACE

echo ""
echo "========== ConfigMap =========="
kubectl get configmap -n $NAMESPACE

echo ""
echo "========== Secrets =========="
kubectl get secrets -n $NAMESPACE

echo ""
echo "========== RBAC =========="
echo "Service Accounts:"
kubectl get serviceaccount -n $NAMESPACE
echo ""
echo "Roles:"
kubectl get roles -n $NAMESPACE
echo ""
echo "Role Bindings:"
kubectl get rolebindings -n $NAMESPACE

echo ""
echo "========== Recent Pod Events =========="
kubectl describe pods -n $NAMESPACE | grep -A 5 Events || echo "No events found"

echo ""
echo "========== Testing Endpoints =========="
echo ""
echo "To test production service (currently routing to):"
echo "  kubectl port-forward svc/healthcare-service 8080:80 -n $NAMESPACE &"
echo "  curl http://localhost:8080/version"
echo "  curl http://localhost:8080/health"
echo "  curl http://localhost:8080/patients"
echo ""

echo "To test Green service specifically:"
echo "  kubectl port-forward svc/healthcare-green-service 8081:80 -n $NAMESPACE &"
echo "  curl http://localhost:8081/version"
echo ""

echo "To test Blue service specifically:"
echo "  kubectl port-forward svc/healthcare-blue-service 8082:80 -n $NAMESPACE &"
echo "  curl http://localhost:8082/version"
echo ""

echo "=========================================="
