#!/bin/bash

# NASA Data Hub Deployment Script
# This script deploys the NASA Data Hub using a single helm install with dependencies

set -e

NAMESPACE="nasa-data-hub"
RELEASE_NAME="nasa-data-hub"

echo "🚀 Deploying NASA Data Hub..."

# Validate NASA API key
echo "🔑 Validating NASA API key..."
if ! grep -q "nasaApiKey: \"[^\"]*\"" values.yaml || grep -q "nasaApiKey: \"\"" values.yaml; then
    echo "❌ ERROR: NASA API key is not set!"
    echo "Please set nasa-etl.nasaApiKey in values.yaml"
    echo "You can get your API key from: https://api.nasa.gov/"
    exit 1
fi
echo "✅ NASA API key is configured"

# Update dependencies
echo "📦 Updating Helm dependencies..."
helm dependency update

# Install everything with a single helm install
echo "📦 Installing NASA Data Hub with all components..."
helm install $RELEASE_NAME . -n $NAMESPACE --create-namespace

echo "✅ NASA Data Hub deployed successfully!"
echo ""
echo "📊 Check status with: kubectl get all -n $NAMESPACE"
echo "🔍 View logs with: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=nasa-data-hub"
echo ""
echo "🌐 Access points:"
echo "  - MinIO Console: kubectl port-forward -n $NAMESPACE svc/nasa-data-hub-minio-console 9090:9090"
echo "  - Metabase: kubectl port-forward -n $NAMESPACE svc/nasa-data-hub-metabase 3000:3000"
echo "  - NASA ETL CronJob: kubectl get cronjobs -n $NAMESPACE"
echo ""
echo "🔑 Metabase login:"
echo "  - Email: admin@nasa-data-hub.com"
echo "  - Password: CHANGE_ME_METABASE_PASSWORD"
