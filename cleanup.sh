#!/bin/bash

# NASA Data Hub Cleanup Script
# This script removes all NASA Data Hub resources and data from the cluster

set -e

NAMESPACE="nasa-data-hub"

echo "🧹 Cleaning up NASA Data Hub..."

# Stop port-forward if running
echo "🛑 Stopping port-forward processes..."
pkill -f "kubectl port-forward.*nasa-data-hub" || true

# Delete namespace (this will delete all resources in the namespace)
echo "🗑️ Deleting namespace..."
kubectl delete namespace $NAMESPACE --force --grace-period=0 || true

# Delete PersistentVolumes
echo "🗑️ Deleting PersistentVolumes..."
kubectl delete pv nasa-data-hub-minio-pv nasa-data-hub-vertica-pv-0 nasa-data-hub-metabase-data-pv --force --grace-period=0 || true

# Delete StorageClass
echo "🗑️ Deleting StorageClass..."
kubectl delete storageclass local-storage --force --grace-period=0 || true

# Clean up host-path directories
echo "🧹 Cleaning up host-path directories..."
sudo rm -rf /tmp/nasa-data-hub-* || true
sudo rm -rf /mnt/data/nasa-data-hub-* || true
sudo rm -rf /var/lib/nasa-data-hub-* || true
sudo rm -rf /opt/nasa-data-hub-* || true
sudo rm -rf /home/nasa-data-hub-* || true
sudo rm -rf /data/nasa-data-hub-* || true
sudo rm -rf /srv/nasa-data-hub-* || true
sudo rm -rf /usr/local/nasa-data-hub-* || true
sudo rm -rf /var/tmp/nasa-data-hub-* || true
sudo rm -rf /tmp/metabase-* || true
sudo rm -rf /tmp/minio-* || true
sudo rm -rf /tmp/vertica-* || true
sudo rm -rf /tmp/verticadb-* || true
sudo rm -rf /tmp/nasa-data-hub-metabase-* || true
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
