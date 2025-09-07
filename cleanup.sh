#!/bin/bash

# NASA Data Hub Cleanup Script
# Simple cleanup - removes Helm release and namespace

set -e

NAMESPACE="nasa-data-hub"
RELEASE_NAME="nasa-data-hub"

echo "🧹 Cleaning up NASA Data Hub..."

# Stop port-forward if running
echo "🛑 Stopping port-forward processes..."
pkill -f "kubectl port-forward.*nasa-data-hub" || true

# Clean up MinIO buckets before uninstalling
echo "🧹 Cleaning up MinIO buckets..."
# Wait for MinIO to be available for cleanup
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=minio -n $NAMESPACE --timeout=60s || true

# Use MinIO client to remove buckets
kubectl run minio-cleanup --rm -i --restart=Never --image=bitnami/minio-client:latest -n $NAMESPACE -- \
  sh -c "
    mc alias set nasa-minio http://nasa-data-hub-minio:9000 admin nasa-data-hub-2025 || true
    mc rm --recursive --force nasa-minio/nasa-data-hub-vertica || true
    mc rb --force nasa-minio/nasa-data-hub-vertica || true
  " || true

# Uninstall Helm release
echo "🗑️ Uninstalling Helm release..."
helm uninstall $RELEASE_NAME -n $NAMESPACE || true

# Delete namespace (this will delete all resources in the namespace)
echo "🗑️ Deleting namespace..."
kubectl delete namespace $NAMESPACE --force --grace-period=0 || true

# Delete PersistentVolumes (cluster-scoped resources)
echo "🗑️ Deleting PersistentVolumes..."
kubectl delete pv nasa-data-hub-minio-pv nasa-data-hub-vertica-pv-0 nasa-data-hub-metabase-data-pv --force --grace-period=0 || true

# Delete StorageClass (cluster-scoped resource)
echo "🗑️ Deleting StorageClass..."
kubectl delete storageclass local-storage --force --grace-period=0 || true

# Clean up host-path directories (local storage)
echo "🧹 Cleaning up host-path directories..."
sudo rm -rf /tmp/nasa-data-hub-minio || true
sudo rm -rf /tmp/nasa-data-hub-vertica* || true
sudo rm -rf /tmp/nasa-data-hub-metabase-data || true

# Wait for namespace to be fully deleted
echo "⏳ Waiting for namespace deletion to complete..."
while kubectl get namespace $NAMESPACE 2>/dev/null; do
    echo "Waiting for namespace to be deleted..."
    sleep 5
done

echo "✅ NASA Data Hub cleanup completed successfully!"
echo ""
echo "🎯 To redeploy, run: ./deploy.sh"
