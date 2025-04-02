---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: %CUSTOMER%-deployment
  labels:
    app: %CUSTOMER%
spec:
  selector:
    matchLabels:
      app: %CUSTOMER%
  template:
    metadata:
      labels:
        app: %CUSTOMER%
    spec:
      containers:
      - name: container
        image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: %CUSTOMER%-service
spec:
  selector:
    app: %CUSTOMER%
  ports:
  - protocol: TCP
    port: 80 
    targetPort: 8080
  type: ClusterIP 
---
kind: HTTPRoute
apiVersion: gateway.networking.k8s.io/v1beta1
metadata:
  name: %CUSTOMER%-httproute
spec:
  parentRefs:
    - kind: Gateway
      name: external-http
  hostnames:
    - "%CUSTOMER%.lbimits.dariobanfi.demo.altostrat.com"
  rules:
    - backendRefs:
        - name: %CUSTOMER%-service
          port: 80