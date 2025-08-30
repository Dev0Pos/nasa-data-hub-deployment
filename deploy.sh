#!/bin/bash

# NASA Data Hub Deployment Script
# This script deploys the NASA Data Hub using kubectl apply instead of Helm
# to avoid the Helm release secret size limitation

set -e

NAMESPACE="nasa-data-hub"
RELEASE_NAME="nasa-data-hub"

echo "🚀 Deploying NASA Data Hub..."

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Generate manifests
echo "📋 Generating manifests..."
helm template $RELEASE_NAME . -n $NAMESPACE > nasa-data-hub-manifest.yaml

# Apply manifests
echo "🔧 Applying manifests..."
kubectl apply -f nasa-data-hub-manifest.yaml

# Create a fake Helm release secret to track the deployment
echo "📝 Creating Helm release tracking..."
kubectl create secret generic sh.helm.release.v1.$RELEASE_NAME.v1 \
  --from-literal=release="{\"name\":\"$RELEASE_NAME\",\"namespace\":\"$NAMESPACE\",\"version\":1,\"status\":\"deployed\"}" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Note: MinIO will wait for preinstall job in its init container
echo "ℹ️ MinIO will wait for preinstall job to complete in its init container"

# Wait for all pods to be ready
echo "⏳ Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=metabase -n $NAMESPACE --timeout=600s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=minio -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=verticadb -n $NAMESPACE --timeout=600s

echo "✅ NASA Data Hub deployed successfully!"
echo ""
echo "📊 Check status with: kubectl get all -n $NAMESPACE"
echo "🔍 View logs with: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=nasa-data-hub"
echo ""
echo "🌐 Access points:"
echo "  - MinIO Console: kubectl port-forward -n $NAMESPACE svc/nasa-data-hub-minio-console 9090:9090"
echo "  - Metabase: kubectl port-forward -n $NAMESPACE svc/nasa-data-hub-metabase 3000:3000"
echo ""
echo "🔑 Metabase login:"
echo "  - Email: admin@nasa-data-hub.com"
echo "  - Password: NasaDataHub2024!"
