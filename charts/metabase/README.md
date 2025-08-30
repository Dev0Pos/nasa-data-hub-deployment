# Metabase

Metabase is an open-source business intelligence and analytics platform that allows you to explore and visualize your data.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

```bash
helm install my-metabase ./charts/metabase
```

## Configuration

The following table lists the configurable parameters of the Metabase chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Metabase image repository | `metabase/metabase` |
| `image.tag` | Metabase image tag | `v0.53.18` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Kubernetes service port | `3000` |
| `ingress.enabled` | Enable ingress | `false` |
| `resources.limits.cpu` | CPU resource limits | `1000m` |
| `resources.limits.memory` | Memory resource limits | `2Gi` |
| `resources.requests.cpu` | CPU resource requests | `500m` |
| `resources.requests.memory` | Memory resource requests | `1Gi` |
| `config.encryptionSecretKey` | Encryption secret key | `nasa-data-hub-metabase-secret-key-2024` |
| `config.databaseType` | Application database type | `h2` |
| `config.verticaHost` | Vertica database host | `nasa-data-hub-vertica-nasa-data-hub-vertica` |
| `config.verticaPort` | Vertica database port | `5433` |
| `config.verticaDatabase` | Vertica database name | `nasa_data` |
| `config.verticaUser` | Vertica database user | `dbadmin` |
| `config.verticaPassword` | Vertica database password | `vertica-password-2024` |
| `jdbc.autoDownload` | Auto-download JDBC driver | `true` |
| `jdbc.downloadUrl` | JDBC driver download URL | `https://www.vertica.com/client_drivers/24.2.x/24.2.0-1/vertica-jdbc-24.2.0-1.jar` |
| `initContainers.waitForVertica.enabled` | Enable wait for Vertica init container | `true` |
| `initContainers.downloadJdbcDriver.enabled` | Enable JDBC driver download init container | `true` |

## Usage

1. Install the chart
2. Access Metabase at the service URL
3. Complete the setup wizard to create an administrator account
4. Add Vertica as a data source using the connection details

## Vertica Connection

The chart automatically configures Vertica JDBC driver and provides connection details:

- **Host**: `nasa-data-hub-vertica-nasa-data-hub-vertica`
- **Port**: `5433`
- **Database**: `nasa_data`
- **Username**: `dbadmin`
- **Password**: `vertica-password-2024`

## Security

- Encryption secret key is stored in a Kubernetes Secret
- Database passwords are stored in Kubernetes Secrets
- Service account is created for the deployment

## Troubleshooting

- Check pod logs: `kubectl logs <pod-name> -n <namespace>`
- Verify Vertica connectivity: `kubectl exec <pod-name> -n <namespace> -- nc -z <vertica-host> <vertica-port>`
- Check JDBC driver installation: `kubectl exec <pod-name> -n <namespace> -- ls -la /plugins/`
