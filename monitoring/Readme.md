Here’s the **complete setup** for **Prometheus, Loki, Alertmanager, and Grafana** in Kubernetes using Helm. This guide includes **persistent storage**, a **custom dashboard**, and an automatic Loki integration in Grafana. 🚀  

---

Note: You Should Run This command In Every Cluster(EKS and GKE) By Changing the Cluster 

## **Step 1: Create a Monitoring Namespace**

```sh
kubectl create namespace monitoring
```

---

## **Step 2: Save Your Custom Values to `values.yaml`**
Create a file named **`values.yaml`** with the following configuration:

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    serviceMonitorNamespaceSelector: {}
    podMonitorSelectorNilUsesHelmValues: false
    podMonitorSelector: {}
    podMonitorNamespaceSelector: {}

    resources:
      requests:
        memory: 400Mi
      limits:
        memory: 2Gi

    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

grafana:
  adminPassword: admin

  persistence:
    enabled: true
    size: 10Gi

  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
        - name: default
          orgId: 1
          folder: ''
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards

  dashboards:
    default:
      multicloud-dashboard:
        file: /var/lib/grafana/dashboards/grafana-dash.json

  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          access: proxy
          url: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090
        - name: Loki
          type: loki
          access: proxy
          url: http://loki.monitoring.svc.cluster.local:3100
          jsonData:
            maxLines: 1000

loki:
  persistence:
    enabled: true
    size: 50Gi

  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 7d

promtail:
  enabled: true
```

---

## **Step 3: Install Prometheus, Loki, and Grafana**
Run the Helm installation with your custom values:

```sh
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
helm install loki grafana-loki/loki-stack -n monitoring -f values.yaml
```

### **Verify Installations**
Check that all pods are running:

```sh
kubectl get pods -n monitoring
```

---

## **Step 4: Deploy Your Custom Grafana Dashboard**
Since your values reference `grafana-dash.json`, create a **ConfigMap**:

1. **Save your `grafana-dash.json` file** locally.
2. **Create a ConfigMap from it**:

```sh
kubectl create configmap grafana-dashboard --from-file=./grafana/grafana-dash.json -n monitoring
```

3. **Mount the ConfigMap in Grafana** by modifying `values.yaml`:

```yaml
grafana:
  extraConfigmapMounts:
    - name: dashboards
      mountPath: /var/lib/grafana/dashboards
      subPath: ""
      configMap: grafana-dashboard
```

4. **Upgrade the Helm installation**:

```sh
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

---

## **Step 5: Expose Prometheus, Grafana & Loki**
### **Expose Prometheus**
```sh
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
👉 Open **http://localhost:9090**

### **Expose Grafana**
```sh
kubectl port-forward -n monitoring svc/grafana 3000:80
```
👉 Open **http://localhost:3000**  
- **Username**: `admin`
- **Password**: `admin`

### **Expose Loki**
```sh
kubectl port-forward -n monitoring svc/loki 3100:3100
```
👉 Open **http://localhost:3100/ready**  
If it works, you should see:  
```
ready
```

---

## **Step 6: Verify Logs in Grafana**
1. **Go to Grafana** (`http://localhost:3000`).
2. Navigate to **Configuration → Data Sources**.
3. Ensure **Loki** is listed.
4. Click **Loki**, then go to **Explore**.
5. Run a query to fetch logs:
   ```
   {job="kubernetes-pods"}
   ```
6. You should see live logs from your Kubernetes pods!

---


To integrate **Prometheus Alerts** for **instance health, CPU, and memory usage**, follow these steps:

---

## **Step 1: Create an Alert Rules ConfigMap**
Since you have alerting rules, we need to load them into Prometheus using a **ConfigMap**.

1. **Save the following content as `alert-rules.yaml`**:

```yaml
groups:
  - name: instance_alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
          cloud: '{{ $labels.cloud }}'
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} has been down for more than 5 minutes."
          
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for more than 5 minutes."

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 85% for more than 5 minutes."
```

---

## **Step 2: Create the ConfigMap in Kubernetes**
Run the following command to create the ConfigMap:

```sh
kubectl create configmap alert-rules --from-file=alert-rules.yaml -n monitoring
```

---

## **Step 3: Update Helm to Load the Alert Rules**
Modify your **values.yaml** file to mount the alert rules:

```yaml
prometheus:
  additionalPrometheusRulesMap:
    instance_alerts:
      groups:
        - name: instance_alerts
          rules:
            - alert: InstanceDown
              expr: up == 0
              for: 5m
              labels:
                severity: critical
                cloud: '{{ $labels.cloud }}'
              annotations:
                summary: "Instance {{ $labels.instance }} down"
                description: "{{ $labels.instance }} has been down for more than 5 minutes."

            - alert: HighCPUUsage
              expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
              for: 5m
              labels:
                severity: warning
              annotations:
                summary: "High CPU usage on {{ $labels.instance }}"
                description: "CPU usage is above 80% for more than 5 minutes."

            - alert: HighMemoryUsage
              expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
              for: 5m
              labels:
                severity: warning
              annotations:
                summary: "High memory usage on {{ $labels.instance }}"
                description: "Memory usage is above 85% for more than 5 minutes."
```

---

## **Step 4: Upgrade Prometheus with the New Rules**
Now, apply the updated configuration:

```sh
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

---

## **Step 5: Verify the Alerts in Prometheus**
1. **Port-forward Prometheus**:
   ```sh
   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
   ```
2. Open **http://localhost:9090**.
3. Go to **Status → Rules**.
4. You should see your alerting rules listed.

---