#!/bin/bash

# NASA Data Hub - Installation Script
# This script installs the NASA Data Hub Helm chart

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="nasa-data-hub"
RELEASE_NAME="nasa-data-hub"
VALUES_FILE="values.yaml"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! command_exists helm; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if we can connect to Kubernetes cluster
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create namespace
create_namespace() {
    print_status "Creating namespace: $NAMESPACE"
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        kubectl create namespace "$NAMESPACE"
        print_success "Namespace $NAMESPACE created"
    else
        print_status "Namespace $NAMESPACE already exists"
    fi
}

# Function to install the chart
install_chart() {
    print_status "Installing NASA Data Hub chart..."
    
    if [ -f "$VALUES_FILE" ]; then
        print_status "Using values file: $VALUES_FILE"
        helm install "$RELEASE_NAME" . -f "$VALUES_FILE" -n "$NAMESPACE" --wait --timeout=15m
    else
        print_warning "Values file $VALUES_FILE not found, using default values"
        helm install "$RELEASE_NAME" . -n "$NAMESPACE" --wait --timeout=15m
    fi
    
    print_success "Chart installed successfully"
}

# Function to check installation status
check_installation() {
    print_status "Checking installation status..."
    
    # Wait a bit for pods to start
    sleep 15
    
    # Check pods
    print_status "Pod status:"
    kubectl get pods -n "$NAMESPACE"
    
    # Check services
    print_status "Service status:"
    kubectl get services -n "$NAMESPACE"
    
    # Check persistent volume claims
    print_status "PVC status:"
    kubectl get pvc -n "$NAMESPACE"
    
    # Check VerticaDB custom resource
    print_status "VerticaDB status:"
    kubectl get verticadb -n "$NAMESPACE" 2>/dev/null || print_warning "VerticaDB CRD not available yet"
}

# Function to show access information
show_access_info() {
    print_success "Installation completed!"
    echo
    echo "=== Access Information ==="
    echo
    echo "MinIO Console:"
    echo "  kubectl port-forward svc/$RELEASE_NAME-minio 9001:9001 -n $NAMESPACE"
    echo "  URL: http://localhost:9001"
    echo "  Username: admin"
    echo "  Password: nasa-data-hub-2024"
    echo
    echo "Metabase:"
    echo "  kubectl port-forward svc/$RELEASE_NAME-metabase 3000:3000 -n $NAMESPACE"
    echo "  URL: http://localhost:3000"
    echo
    echo "Vertica Database:"
    echo "  kubectl port-forward svc/$RELEASE_NAME-vertica 5433:5433 -n $NAMESPACE"
    echo
    echo "=== Monitoring Commands ==="
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl get verticadb -n $NAMESPACE"
    echo "  kubectl logs -l app.kubernetes.io/component=storage -n $NAMESPACE"
    echo
    echo "=== Deployment Order ==="
    echo "1. MinIO (Object Storage)"
    echo "2. Vertica Operator"
    echo "3. Vertica Database (waits for MinIO)"
    echo "4. Metabase (waits for Vertica)"
    echo
    echo "=== Next Steps ==="
    echo "1. Configure your NASA API key for the ETL application"
    echo "2. Set up ingress for external access"
    echo "3. Configure storage classes for persistent volumes"
    echo "4. Access Metabase to create dashboards"
    echo "5. Deploy your Go ETL application separately"
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -n, --namespace NAME     Kubernetes namespace (default: nasa-data-hub)"
    echo "  -r, --release NAME       Helm release name (default: nasa-data-hub)"
    echo "  -f, --values FILE        Values file to use (default: values.yaml)"
    echo "  -h, --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0                                    # Install with default settings"
    echo "  $0 -f values-prod.yaml               # Install with production values"
    echo "  $0 -n my-namespace -r my-release     # Install with custom namespace and release name"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -f|--values)
            VALUES_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main installation process
main() {
    echo "=== NASA Data Hub Installation Script ==="
    echo
    
    check_prerequisites
    create_namespace
    install_chart
    check_installation
    show_access_info
}

# Run main function
main "$@"
