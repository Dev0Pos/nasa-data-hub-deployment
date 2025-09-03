# NASA Data Hub - Helm Chart

A comprehensive data analytics platform for NASA EONET data processing and visualization.

## Architecture

The system consists of four main components:

1. **MinIO** - Object storage (data lake) for raw data
2. **Vertica Operator** - Manages Vertica database lifecycle
3. **Vertica** - Analytical database (data warehouse) for processed data
4. **Metabase** - Data visualization and dashboard creation tool

## Features

- **Fully Automated Deployment** - One-command deployment with `./deploy.sh`
- **Automatic Setup** - Metabase automatically configured with admin user and Vertica database
- **Smart Init Containers** - Proper dependency management between components
- **Preinstall Jobs** - Infrastructure preparation (directories, permissions)
- **JDBC Driver Management** - Automatic download of Vertica JDBC driver
- **Cleanup Script** - Complete cleanup with `./cleanup.sh`

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- RKE2 cluster
- Storage Class for Persistent Volumes

## Quick Start

### 1. Deploy NASA Data Hub

**Option 1: Using deployment script (RECOMMENDED)**
```bash
# Use the deployment script to avoid Helm release secret size issues
./deploy.sh
```

**Option 2: Direct Helm installation**
```bash
# Basic installation
helm install nasa-data-hub . --namespace nasa-data-hub --create-namespace

# With custom values (if you have custom values file)
helm install nasa-data-hub . -f values-custom.yaml --namespace nasa-data-hub --create-namespace
```

**Note:** If you encounter "data: Too long" error with Helm, use the deployment script instead.

### 2. Check installation status

```bash
# Check all resources
kubectl get all -n nasa-data-hub

# Check specific component status
kubectl get pods -n nasa-data-hub
kubectl get services -n nasa-data-hub
kubectl get pvc -n nasa-data-hub
```

## Configuration

### Main parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `minio.enabled` | Enable/disable MinIO | `true` |
| `verticadb-operator.enabled` | Enable/disable Vertica Operator | `true` |
| `verticadb.enabled` | Enable/disable Vertica | `true` |
| `metabase.enabled` | Enable/disable Metabase | `true` |

### Storage Configuration

Adjust Storage Class for your cluster in `values.yaml`:

```yaml
minio:
  persistence:
    storageClass: "local-storage"
verticadb:
  persistence:
    storageClass: "local-storage"
```

## Access to Components

### MinIO Console

```bash
kubectl port-forward svc/nasa-data-hub-minio-console 9090:9090 -n nasa-data-hub
```

Open http://localhost:9090 in your browser
- Username: `admin`
- Password: `nasa-data-hub-2025`

### Metabase

```bash
kubectl port-forward svc/nasa-data-hub-metabase 3000:3000 -n nasa-data-hub
```

Open http://localhost:3000 in your browser

**Login Credentials:**
- Email: `admin@nasa-data-hub.com`
- Password: `NasaDataHub2024!`

**Note:** Metabase is automatically configured during deployment with Vertica database connection. No manual setup required.

### Vertica Database

```bash
kubectl port-forward svc/nasa-data-hub-vertica 5433:5433 -n nasa-data-hub
```

## Deployment Order

The components are deployed in the following order with dependency management:

1. **Preinstall Job** - Creates directories and sets permissions
2. **MinIO** - Object storage (waits for preinstall job via init container)
3. **Vertica Operator** - Database management
4. **Vertica** - Database instance
5. **Metabase** - BI tool (waits for Vertica via init container, auto-configured with database connection)

## Monitoring and Logs

### Check component status

```bash
# Pod status
kubectl get pods -n nasa-data-hub

# Service status
kubectl get services -n nasa-data-hub

# PVC status
kubectl get pvc -n nasa-data-hub
```

### Component logs

```bash
# MinIO logs
kubectl logs -l app.kubernetes.io/name=minio -n nasa-data-hub

# Vertica Operator logs
kubectl logs -l app.kubernetes.io/name=verticadb-operator -n nasa-data-hub

# Metabase logs
kubectl logs -l app.kubernetes.io/name=metabase -n nasa-data-hub
```

## Data Structure

### MinIO Buckets

- `nasa-data-hub-vertica` - Default bucket for data storage

### Vertica Tables

- `events` - EONET event data
- `categories` - Event categories
- `sources` - Data sources
- `geometries` - Geometric data

## Troubleshooting

### Helm Release Secret Size Issues

If you encounter "data: Too long" error when using `helm install`:

```bash
# Use the deployment script instead
./deploy.sh
```

This script uses `kubectl apply` with Helm templates to avoid the secret size limitation.

### Persistent Volume Issues

If PVCs remain in Pending state:

```bash
kubectl get pvc -n nasa-data-hub
kubectl describe pvc <pvc-name> -n nasa-data-hub
```

### Database Connection Issues

Check if Vertica is ready:

```bash
kubectl get verticadb -n nasa-data-hub
kubectl describe verticadb nasa-data-hub-vertica -n nasa-data-hub
```

### Setup Job Issues

Check setup job logs (includes Metabase setup and Vertica database addition):

```bash
kubectl logs job/nasa-data-hub-metabase-setup-database -n nasa-data-hub
```

## Updating

```bash
# Regenerate and apply manifests
helm template nasa-data-hub . -n nasa-data-hub > nasa-data-hub-manifest.yaml
kubectl apply -f nasa-data-hub-manifest.yaml
```

## Uninstalling

**Option 1: Using cleanup script (RECOMMENDED)**
```bash
./cleanup.sh
```

**Option 2: Manual cleanup**
```bash
# Delete all resources
kubectl delete -f nasa-data-hub-manifest.yaml

# Delete namespace
kubectl delete namespace nasa-data-hub

# Clean up host paths (if using local storage)
sudo rm -rf /tmp/nasa-data-hub-*
```

## Project Structure

```
nasa-data-hub-deployment/
├── charts/                    # Sub-charts for components
│   ├── metabase/             # Metabase Helm chart
│   ├── minio/                # MinIO Helm chart
│   ├── verticadb-operator/   # Vertica Operator chart
│   └── preinstall/           # Preinstall resources
├── templates/                 # Main chart templates
├── values.yaml               # Main configuration
├── deploy.sh                 # Deployment script
├── cleanup.sh                # Cleanup script
└── README.md                 # This file
```

## Next Steps

1. Configure your NASA API key for the ETL application
2. Set up ingress for external access
3. Configure storage classes for persistent volumes
4. Access Metabase to create dashboards and visualizations
5. Deploy your Go ETL application separately

## Support

For issues:

1. Check component logs
2. Check Persistent Volume status
3. Check network and DNS configuration
4. Check ServiceAccount permissions

## License

MIT License - see [LICENSE](LICENSE) file for details.
