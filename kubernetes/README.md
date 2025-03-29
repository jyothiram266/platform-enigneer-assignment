# **Istio + Cert-Manager Setup on EKS and GKE**  

## **1. Prerequisites**  
Ensure you have:  
- **EKS and GKE clusters ready**  
- `kubectl` and `helm` installed  
- `aws eks update-kubeconfig` and `gcloud container clusters get-credentials` configured for respective clusters  
- A **domain** and **DNS provider** (e.g., Cloudflare, AWS Route 53)  

---

## **2. Install Istio Using Helm**  

### **On EKS**  
1. **Add the Istio Helm repo and update:**  
   ```sh
   helm repo add istio https://istio-release.storage.googleapis.com/charts
   helm repo update
   ```  
2. **Create Istio namespace:**  
   ```sh
   kubectl create namespace istio-system
   ```  
3. **Install Istio Base Components:**  
   ```sh
   helm install istio-base istio/base -n istio-system
   ```  
4. **Install Istiod (Control Plane):**  
   ```sh
   helm install istiod istio/istiod -n istio-system --wait
   ```  
5. **Install Istio Ingress Gateway:**  
   ```sh
   helm install istio-ingress istio/gateway -n istio-system --wait
   ```  
6. **Enable automatic sidecar injection:**  
   ```sh
   kubectl label namespace default istio-injection=enabled
   ```  

### **On GKE**  
Repeat the same steps as in **EKS** to ensure consistency.

---

## **3. Install Cert-Manager Using Helm**  

### **On EKS**  
1. **Add the Jetstack Helm repository:**  
   ```sh
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   ```  
2. **Install Cert-Manager:**  
   ```sh
   helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --set installCRDs=true
   ```  
3. **Verify Cert-Manager installation:**  
   ```sh
   kubectl get pods -n cert-manager
   ```  

### **On GKE**  
Repeat the same steps as in **EKS**.

---

## **4. Configure ClusterIssuer for Cert-Manager**  

### **On EKS**  
1. **Create a ClusterIssuer YAML file (`eks-clusterissuer.yaml`)**  
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-eks
   spec:
     acme:
       email: your-email@example.com
       server: https://acme-v02.api.letsencrypt.org/directory
       privateKeySecretRef:
         name: letsencrypt-private-key
       solvers:
       - http01:
           ingress:
             class: istio
   ```  
2. **Apply the ClusterIssuer:**  
   ```sh
   kubectl apply -f eks-clusterissuer.yaml
   ```  

### **On GKE**  
1. **Create a ClusterIssuer YAML file (`gke-clusterissuer.yaml`)**  
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-gke
   spec:
     acme:
       email: your-email@example.com
       server: https://acme-v02.api.letsencrypt.org/directory
       privateKeySecretRef:
         name: letsencrypt-private-key
       solvers:
       - http01:
           ingress:
             class: istio
   ```  
2. **Apply the ClusterIssuer:**  
   ```sh
   kubectl apply -f gke-clusterissuer.yaml
   ```  

---

## **5. Deploy Sample Application (httpbin)**  

### **On Both EKS and GKE**  
1. **Deploy the `httpbin` application:**  
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
   ```  
   ```sh
   kubectl apply -f httpbin-deployment.yaml
   ```  

2. **Expose `httpbin` as a Service:**  
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: httpbin
   spec:
     ports:
     - port: 80
       targetPort: 80
     selector:
       app: httpbin
   ```  
   ```sh
   kubectl apply -f httpbin-service.yaml
   ```  

---

## **6. Configure Istio Gateway and VirtualService**  

### **On Both EKS and GKE**  
1. **Create a Gateway resource (`gateway.yaml`)**  
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
       - "example.com"
   ```  
   ```sh
   kubectl apply -f gateway.yaml
   ```  

2. **Create a VirtualService resource (`virtualservice.yaml`)**  
   ```yaml
   apiVersion: networking.istio.io/v1beta1
   kind: VirtualService
   metadata:
     name: httpbin
   spec:
     hosts:
     - "example.com"
     gateways:
     - httpbin-gateway
     http:
     - route:
       - destination:
           host: httpbin
           port:
             number: 80
   ```  
   ```sh
   kubectl apply -f virtualservice.yaml
   ```  

---

## **7. Configure TLS Certificates**  

### **On Both EKS and GKE**  
1. **Create a Certificate resource (`certificate.yaml`)**  
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
     name: httpbin-cert
   spec:
     secretName: httpbin-tls
     issuerRef:
       name: letsencrypt-eks  # Change to letsencrypt-gke for GKE
       kind: ClusterIssuer
     commonName: "example.com"
     dnsNames:
     - "example.com"
   ```  
   ```sh
   kubectl apply -f certificate.yaml
   ```  

2. **Update the Gateway for HTTPS (`gateway.yaml`)**  
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
       - "example.com"
       tls:
         mode: SIMPLE
         credentialName: httpbin-tls
   ```  
   ```sh
   kubectl apply -f gateway.yaml
   ```  

---

## **8. Verification Steps**  

1. **Check certificate status:**  
   ```sh
   kubectl describe certificate httpbin-cert
   ```  
2. **Check Istio Ingress Gateway external IP:**  
   ```sh
   kubectl get service istio-ingressgateway -n istio-system
   ```  
3. **Test application with `curl`:**  
   ```sh
   curl -k https://example.com
   ```  

---