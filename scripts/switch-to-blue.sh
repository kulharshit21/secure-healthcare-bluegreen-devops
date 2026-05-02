#!/bin/bash
# Switch traffic from Green back to Blue
# Patch main service selector to route traffic to Blue deployment

set -e

echo "=========================================="
echo "Switching Traffic: Green -> Blue"
echo "=========================================="

NAMESPACE="healthcare-devops"
SERVICE="healthcare-service"

echo ""
echo "Current service selector:"
CURRENT_APP=$(kubectl get svc $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.app}')
CURRENT_VERSION=$(kubectl get svc $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.version}')
echo "  app=$CURRENT_APP"
echo "  version=$CURRENT_VERSION"
echo ""

echo "Patching $SERVICE selector to Blue..."
kubectl patch service $SERVICE \
    -n $NAMESPACE \
    -p '{"spec":{"selector":{"app":"healthcare-api","version":"blue"}}}'

echo ""
echo "Waiting for endpoints to update..."
sleep 3

echo ""
echo "=========================================="
echo "✓ Traffic switched back to Blue"
echo "=========================================="
echo ""
echo "New service selector:"
NEW_APP=$(kubectl get svc $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.app}')
NEW_VERSION=$(kubectl get svc $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.version}')
echo "  app=$NEW_APP"
echo "  version=$NEW_VERSION"
echo ""
echo "Service endpoints:"
kubectl get endpoints $SERVICE -n $NAMESPACE
echo ""
echo "Verify by checking version:"
echo "  kubectl port-forward svc/$SERVICE 8080:80 -n $NAMESPACE"
echo "  curl http://localhost:8080/version"
echo ""
