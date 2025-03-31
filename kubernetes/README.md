# **Setting Up Istio and Cert-Manager on EKS and GKE**

This guide walks you through setting up Istio service mesh and Cert-Manager for TLS certificate management on both Amazon EKS and Google GKE Kubernetes clusters.

![Multi-cloud Istio Architecture](../screenshots/Screenshot%20from%202025-03-29%2023-44-44.png)

## **What You'll Accomplish**

- Deploy Istio service mesh for traffic management
- Set up Cert-Manager for automated TLS certificate provisioning
- Configure secure ingress with automatic HTTPS certificates
- Deploy and expose a sample application

## **Prerequisites**

Before starting, ensure you have:

- **Active EKS and GKE clusters** with admin access
- **Command-line tools**:
  - `kubectl` (v1.21+) - for Kubernetes management
  - `helm` (v3.8+) - for package installation
  - AWS CLI (for EKS) and Google Cloud SDK (for GKE)
- **Kubeconfig configured** for both clusters:
  ```bash
  # For EKS
  aws eks update-kubeconfig --region <region> --name <cluster-name>
  
  # For GKE
  gcloud container clusters get-credentials <cluster-name> --region <region>
  ```
- **Registered domain name** with access to DNS management (Route 53, Cloudflare, etc.)

## **Installation Procedure**

### **1. Install Istio Service Mesh**

The following steps should be performed on **both EKS and GKE clusters**.

#### 1.1. Add Istio Helm Repository
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

#### 1.2. Create Namespace and Install Istio Components
```bash
# Create namespace for Istio components
kubectl create namespace istio-system

# Install Istio base components
helm install istio-base istio/base -n istio-system

# Install Istio control plane (Istiod)
helm install istiod istio/istiod -n istio-system --wait

# Install Istio ingress gateway
helm install istio-ingress istio/gateway -n istio-system --wait
```

#### 1.3. Enable Automatic Sidecar Injection
This will automatically inject the Istio proxy into your pods.
```bash
kubectl label namespace default istio-injection=enabled
```

#### 1.4. Verify Istio Installation
```bash
# Check Istio pods
kubectl get pods -n istio-system

# Verify the ingress gateway has an external IP/hostname
kubectl get svc istio-ingressgateway -n istio-system
```

### **2. Install Cert-Manager**

Cert-Manager automates the issuance and renewal of TLS certificates.

#### 2.1. Add Jetstack Helm Repository
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

#### 2.2. Install Cert-Manager with CRDs
```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

#### 2.3. Verify Cert-Manager Installation
```bash
kubectl get pods -n cert-manager
```
All pods should show `Running` status.

### **3. Configure ACME Certificate Issuers**

Let's Encrypt requires different issuers for each cluster to manage certificates.

#### 3.1. Create ClusterIssuer for EKS

Create a file named `eks-clusterissuer.yaml`:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-eks
spec:
  acme:
    # Use Let's Encrypt production server (for real certificates)
    server: https://acme-v02.api.letsencrypt.org/directory
    # IMPORTANT: Replace with your actual email address
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-private-key
    solvers:
    - http01:
        ingress:
          class: istio
```

Apply the configuration:
```bash
kubectl apply -f eks-clusterissuer.yaml
```

#### 3.2. Create ClusterIssuer for GKE

Create a file named `gke-clusterissuer.yaml`:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-gke
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-private-key
    solvers:
    - http01:
        ingress:
          class: istio
```

Apply the configuration:
```bash
kubectl apply -f gke-clusterissuer.yaml
```

> **Tip**: For testing, you can use the staging server by changing the URL to `https://acme-staging-v02.api.letsencrypt.org/directory` to avoid rate limits.

### **4. Deploy a Sample Application**

Let's deploy the httpbin service to test our setup.

#### 4.1. Create Deployment
Create a file named `httpbin-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
      - name: httpbin
        image: kennethreitz/httpbin
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
```

#### 4.2. Create Service
Create a file named `httpbin-service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: httpbin
spec:
  ports:
  - port: 80
    targetPort: 80
    name: http
  selector:
    app: httpbin
```

#### 4.3. Apply Configurations
```bash
kubectl apply -f httpbin-deployment.yaml
kubectl apply -f httpbin-service.yaml
```

### **5. Configure Istio Gateway and Routing**

Now let's expose our service through Istio.

#### 5.1. Create Gateway for HTTP Traffic
Create a file named `gateway.yaml`:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "YOUR-DOMAIN.COM"  # Replace with your actual domain
```

#### 5.2. Create VirtualService for Routing
Create a file named `virtualservice.yaml`:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "YOUR-DOMAIN.COM"  # Replace with your actual domain
  gateways:
  - httpbin-gateway
  http:
  - route:
    - destination:
        host: httpbin
        port:
          number: 80
```

#### 5.3. Apply Configurations
```bash
kubectl apply -f gateway.yaml
kubectl apply -f virtualservice.yaml
```

### **6. Set Up TLS Certificates**

Now let's secure our application with HTTPS.

#### 6.1. Request Certificate from Let's Encrypt
Create a file named `certificate.yaml`:
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: httpbin-cert
spec:
  secretName: httpbin-tls
  issuerRef:
    # Use letsencrypt-eks for EKS cluster, letsencrypt-gke for GKE
    name: letsencrypt-eks  
    kind: ClusterIssuer
  commonName: "YOUR-DOMAIN.COM"  # Replace with your actual domain
  dnsNames:
  - "YOUR-DOMAIN.COM"  # Replace with your actual domain
```

#### 6.2. Apply the Certificate Request
```bash
kubectl apply -f certificate.yaml
```

#### 6.3. Update Gateway for HTTPS
Update your `gateway.yaml` file:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "YOUR-DOMAIN.COM"  # Replace with your actual domain
    tls:
      mode: SIMPLE
      credentialName: httpbin-tls
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "YOUR-DOMAIN.COM"  # Replace with your actual domain
    tls:
      httpsRedirect: true  # Redirect HTTP to HTTPS
```

#### 6.4. Apply Updated Gateway
```bash
kubectl apply -f gateway.yaml
```

### **7. Configure DNS**

Configure your DNS provider to point your domain to the Istio Ingress Gateway's external IP or hostname.

#### 7.1. Get External IP/Hostname
```bash
kubectl get svc istio-ingressgateway -n istio-system
```

#### 7.2. Create DNS A Record
In your DNS provider's console:
- Create an A record for `YOUR-DOMAIN.COM` pointing to the external IP

### **8. Verification and Troubleshooting**

#### 8.1. Check Certificate Status
```bash
kubectl describe certificate httpbin-cert
```
Look for the `Status.Conditions` section - it should show `Ready: True`.

#### 8.2. Check Certificate Secret
```bash
kubectl get secret httpbin-tls
```

#### 8.3. Test with curl
```bash
# Test HTTPS endpoint (might take some time for DNS to propagate)
curl https://YOUR-DOMAIN.COM/headers

# Test with -v flag for more details
curl -v https://YOUR-DOMAIN.COM/headers
```

#### 8.4. Troubleshooting
If you encounter issues:

- **Check certificate issuance logs**:
  ```bash
  kubectl logs -n cert-manager -l app=cert-manager -c cert-manager
  ```

- **Check Istio ingress logs**:
  ```bash
  kubectl logs -n istio-system -l app=istio-ingressgateway -c istio-proxy
  ```

- **Verify ClusterIssuer status**:
  ```bash
  kubectl describe clusterissuer letsencrypt-eks
  ```

## **Next Steps**

Now that you have Istio and Cert-Manager working:

1. **Set up mutual TLS** between services for enhanced security
2. **Configure additional Istio features** like circuit breaking, fault injection, etc.
3. **Set up monitoring** with Kiali, Grafana, and Prometheus

## **Common Customizations**

- **For production workloads**, increase replica count in deployment
- **For custom domains**, update host values in Gateway, VirtualService, and Certificate
- **For different certificate issuers**, modify the ClusterIssuer configuration

## **References**

- [Official Istio Documentation](https://istio.io/latest/docs/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)