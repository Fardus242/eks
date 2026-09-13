# GameGrid GitOps Platform

A complete AWS Kubernetes platform for deploying and operating a containerised 2048 application on Amazon EKS.

The project covers the full path from infrastructure provisioning to application deployment and monitoring. I was given the requirements for the platform and worked through the architecture, tooling choices, infrastructure, CI/CD pipeline and Kubernetes deployment.

The goal was to build a platform that is repeatable, automated and maintainable rather than manually configuring individual AWS and Kubernetes resources.

## Architecture

The platform follows this flow:

```text
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Build Docker image
   ├── Trivy security scan
   ├── Authenticate to AWS using OIDC
   └── Push image to ECR
            │
            ▼
      Amazon ECR
            │
            ▼
   Update Helm image tag
            │
            ▼
         ArgoCD
            │
            ▼
      Amazon EKS
            │
            ▼
   Kubernetes Ingress
            │
            ▼
        AWS ALB
            │
            ▼
       2048 Application
```

Infrastructure is provisioned using Terraform, while ArgoCD manages the Kubernetes application using GitOps.

## Technologies

### AWS

* Amazon EKS — managed Kubernetes cluster
* Amazon ECR — container image registry
* Application Load Balancer — external access to the application
* VPC — networking infrastructure
* IAM — access control and least-privilege permissions
* EC2 — EKS worker nodes

### Infrastructure as Code

* Terraform — provisioning AWS infrastructure

### Containers & Kubernetes

* Docker — containerising the 2048 application
* Kubernetes — application orchestration
* Helm — packaging and configuration
* AWS Load Balancer Controller — provisioning the AWS ALB from Kubernetes Ingress resources

### CI/CD & GitOps

* GitHub Actions — build, security scanning and image publishing
* ArgoCD — GitOps-based Kubernetes deployment

### Security & Observability

* Trivy — container vulnerability scanning
* AWS IAM / OIDC — secure GitHub Actions authentication
* Prometheus — metrics collection
* Grafana — metrics visualisation

## Project Structure

```text
.
├── app/
│   ├── Dockerfile
│   └── ...
│
├── kubernetes/
│   └── 2048-game/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
│
├── terraform/
│   └── ...
│
├── .github/
│   └── workflows/
│       └── ...
│
└── README.md
```

## How the Platform Works

### 1. Infrastructure

Terraform provisions the AWS infrastructure required by the platform, including the VPC, networking, EKS cluster and worker nodes.

The infrastructure is defined as code so that it can be recreated consistently rather than configured manually.

### 2. Containerisation

The 2048 application is packaged into a Docker image.

The image is built from the application source using the project's Dockerfile.

### 3. Container Registry

The Docker image is pushed to Amazon ECR.

Images are tagged using the Git commit SHA, giving each deployment an identifiable and immutable image version.

Example:

```text
388212729357.dkr.ecr.eu-west-2.amazonaws.com/2048-game:<commit-sha>
```

### 4. CI/CD

GitHub Actions automates the container build and publishing process.

The pipeline:

1. Checks out the repository
2. Builds the Docker image
3. Scans the image using Trivy
4. Authenticates to AWS using GitHub OIDC
5. Pushes the image to Amazon ECR
6. Updates the Helm image tag
7. Commits the updated Helm configuration back to Git

This means a change pushed to `main` can progress through the deployment pipeline without manually pushing images or updating Kubernetes manifests.

### 5. GitOps with ArgoCD

ArgoCD monitors the Kubernetes configuration stored in Git.

When the Helm configuration changes, ArgoCD detects the new revision and synchronises the desired state with the EKS cluster.

```text
Git
 ↓
ArgoCD
 ↓
EKS
```

ArgoCD is configured with automated synchronisation, pruning and self-healing.

### 6. Kubernetes

The application runs as Kubernetes Pods managed by a Deployment.

A Kubernetes `ClusterIP` Service provides internal access to the application.

The AWS Load Balancer Controller watches the Kubernetes Ingress and provisions an internet-facing AWS Application Load Balancer.

```text
Internet
   ↓
AWS ALB
   ↓
Ingress
   ↓
ClusterIP Service
   ↓
2048 Pods
```

### 7. Monitoring

Prometheus and Grafana are deployed to the cluster using the `kube-prometheus-stack` Helm chart.

Prometheus collects Kubernetes metrics while Grafana provides dashboards for monitoring cluster and application resources.

This allows CPU, memory and pod-level behaviour to be observed through dashboards rather than relying only on command-line inspection.

## Running the Application Locally

### Prerequisites

Install:

* Docker
* Node.js
* npm

Clone the repository:

```bash
git clone https://github.com/Fardus242/eks.git
cd eks
```

Install the application dependencies:

```bash
cd app
npm install
```

Start the application:

```bash
npm start
```

The application should then be available at:

```text
http://localhost:3000
```

### Running with Docker

Build the image:

```bash
docker build -t 2048-game ./app
```

Run the container:

```bash
docker run -p 3000:3000 2048-game
```

The application can then be accessed at:

```text
http://localhost:3000
```

## Deploying to Kubernetes

The Kubernetes application is packaged as a Helm chart located at:

```text
kubernetes/2048-game
```

The chart contains the Kubernetes resources required to run the application, including:

* Deployment
* Service
* Ingress

The application can be deployed using Helm:

```bash
helm upgrade --install 2048-game ./kubernetes/2048-game
```

The AWS Load Balancer Controller then manages the AWS ALB associated with the Ingress.

<img width="953" height="475" alt="2048 game " src="https://github.com/user-attachments/assets/ec87198c-4efb-4730-9957-8de991e8d5f8" />


## Monitoring

Grafana can be accessed locally using Kubernetes port forwarding:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```

Then open:

```text
http://localhost:3000
```

Prometheus can similarly be accessed using:

```bash
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090
```
<img width="948" height="470" alt="grafana metrics 3" src="https://github.com/user-attachments/assets/5108b5ec-6825-4e2c-aac3-a216813e7b6c" />


## Future Improvements

The current platform provides the core deployment and operational workflow. Future improvements could include:

* HTTPS using cert-manager
* Custom DNS using ExternalDNS
* Route 53 integration



