# NASA Data Hub - Helm Chart

A comprehensive data analytics platform for NASA EONET data processing and visualization.

## Architecture

The system consists of four main components:

1. **MinIO** - Object storage (data lake) for raw data
2. **Vertica Operator** - Manages Vertica database lifecycle
3. **Vertica** - Analytical database (data warehouse) for processed data
4. **Metabase** - Data visualization and dashboard creation tool

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- RKE2 cluster
- Storage Class for Persistent Volumes

## Quick Start

### 1. Install the chart

```bash
# Basic installation
helm install nasa-data-hub . --namespace nasa-data-hub --create-namespace

# With custom values
helm install nasa-data-hub . -f values-prod.yaml --namespace nasa-data-hub --create-namespace
```

### 2. Check installation status

```bash
helm status nasa-data-hub -n nasa-data-hub
kubectl get pods -n nasa-data-hub
```

## Configuration

### Main parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `minio.enabled` | Enable/disable MinIO | `true` |
| `vertica-operator.enabled` | Enable/disable Vertica Operator | `true` |
| `vertica.enabled` | Enable/disable Vertica | `true` |
| `metabase.enabled` | Enable/disable Metabase | `true` |

### Storage Configuration

Adjust Storage Class for your cluster:

```yaml
minio:
  persistence:
    storageClass: "your-storage-class"
vertica:
  persistence:
    storageClass: "your-storage-class"
```

## Access to Components

### MinIO Console

```bash
kubectl port-forward svc/nasa-data-hub-minio 9001:9001 -n nasa-data-hub
```

Open http://localhost:9001 in your browser
- Username: `admin`
- Password: `nasa-data-hub-2024`

### Metabase

```bash
kubectl port-forward svc/nasa-data-hub-metabase 3000:3000 -n nasa-data-hub
```

Open http://localhost:3000 in your browser

### Vertica Database

```bash
kubectl port-forward svc/nasa-data-hub-vertica 5433:5433 -n nasa-data-hub
```

## Deployment Order

The components are deployed in the following order with dependency management:

1. **MinIO** - Object storage
2. **Vertica Operator** - Database management
3. **Vertica** - Database (waits for MinIO via init containers)
4. **Metabase** - Visualization (waits for Vertica via init containers)

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
kubectl logs -l app.kubernetes.io/component=storage -n nasa-data-hub

# Vertica Operator logs
kubectl logs -l app.kubernetes.io/component=operator -n nasa-data-hub

# Metabase logs
kubectl logs -l app.kubernetes.io/component=visualization -n nasa-data-hub
```

## Data Structure

### MinIO Buckets

- `nasa-eonet-data` - Raw data from NASA EONET API

### Vertica Tables

- `events` - EONET event data
- `categories` - Event categories
- `sources` - Data sources
- `geometries` - Geometric data

## Troubleshooting

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

### Init Container Issues

Check init container logs:

```bash
kubectl logs <pod-name> -c wait-for-minio -n nasa-data-hub
kubectl logs <pod-name> -c wait-for-vertica -n nasa-data-hub
```

## Updating

```bash
helm upgrade nasa-data-hub . -n nasa-data-hub
```

## Uninstalling

```bash
helm uninstall nasa-data-hub -n nasa-data-hub
kubectl delete namespace nasa-data-hub
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
