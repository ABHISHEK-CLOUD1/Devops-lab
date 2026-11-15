# Enterprise Hybrid Homelab & Multi-Cloud GitOps Infrastructure

[![Hypervisor](https://img.shields.io/badge/Hypervisor-Proxmox%20VE%209.1.1-E57000?logo=proxmox)](https://www.proxmox.com)
[![Cloud](https://img.shields.io/badge/Cloud-Oracle%20Cloud%20(OCI)-F80000?logo=oracle)](https://cloud.oracle.com)
[![GitOps](https://img.shields.io/badge/GitOps-Argo%20CD%20v3.6.1-EF7B4D?logo=argo)](https://argo-cd.readthedocs.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s%20v1.37.2-326CE5?logo=kubernetes)](https://k3s.io)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20Automation-D24939?logo=jenkins)](https://jenkins.io)
[![Observability](https://img.shields.io/badge/Observability-Prometheus%20%2B%20Grafana%2013.3.1-F46800?logo=prometheus)](https://prometheus.io)
[![Autonomous AI](https://img.shields.io/badge/Orchestrator-Google%20Antigravity-4285F4?logo=google)](https://deepmind.google)

---

## 🏛️ Architectural Overview

This repository governs an enterprise-grade hybrid cloud infrastructure bridging an on-premise **Proxmox VE 9.1.1** cluster (`192.168.155.128`) operating on private Class C subnets (`10.10.10.0/24` and `192.168.155.0/24`) to **Oracle Cloud Infrastructure (OCI)** compute nodes via encrypted, zero-trust bidirectional SSH tunnels.

The entire topology is declaratively managed through **Argo CD GitOps**, orchestrated by **Jenkins** and **Ansible**, and continually monitored by a centralized **Prometheus** TSDB with real-time dashboards on **Cloud Grafana**.

```
+----------------------------------------------------------------------------------------------------+
|                                    PROXMOX VE HOST (192.168.155.128)                               |
|                                                                                                    |
|  [CT100: control-node]   --> Ansible Engine, Git Repo (/root/Devops-lab), Central Keymaster        |
|  [CT101: terraform-test] --> Nginx Ingress Proxy, Joined to Active Directory Domain (lab.local)    |
|  [CT102: jenkins]        --> Enterprise CI/CD Engine (:8080), Multi-Stage Automated Pipelines      |
|  [CT103: staging]        --> Pre-production Staging Environment, Domain Joined (lab.local)         |
|  [CT104: production]     --> Production Application & Database Tier, Domain Joined (lab.local)     |
|  [CT105: samba-dc]       --> Samba Active Directory Domain Controller (LAB.LOCAL), Kerberos, DNS  |
|  [CT106: prometheus]     --> Central TSDB Core (:9090), Scrapes 11 On-Prem & Cloud Targets         |
|  [CT107: grafana]        --> Preserved / Stopped container (Available for future purpose)          |
|  [CT108: docker-host]    --> Docker Runtime (2GB RAM + 2GB Swap), Portfolio App (:8080), cAdvisor  |
|  [CT109: argocd-k8s]     --> K3s Cluster, Argo CD v3.6.1 (:30443), Declarative App-of-Apps Tree    |
+--------------------------------------------------+-------------------------------------------------+
                                                   |
                             Encrypted Reverse & Forward SSH Tunnels
                                                   |
+--------------------------------------------------▼-------------------------------------------------+
|                               ORACLE CLOUD INFRASTRUCTURE (OCI ap-mumbai-1)                         |
|                                                                                                    |
|  [OCI VM 1: Cloud Grafana]    --> Grafana 13.3.1 (:3000), Public IP: 137.23.38.177                 |
|  [OCI VM 2: Cloud Kubernetes] --> Node Exporter (:9100), K8s Candidate, Public IP: 130.210.84.113  |
+----------------------------------------------------------------------------------------------------+
```

---

## 🌐 Quick Access Directory & Endpoints

| Service / Workload | Host Identifier | URL / Endpoint | Credentials / Details |
|---|---|---|---|
| **Portfolio Website (Live)** | `CT108` (`docker-host`) | [http://192.168.155.139:8080/](http://192.168.155.139:8080/) | Live React 19 app from [ABHISHEK-CLOUD1/app](https://github.com/ABHISHEK-CLOUD1/app) |
| **Argo CD GitOps Web UI** | `CT109` (`argocd-k8s`) | [https://192.168.155.142:30443](https://192.168.155.142:30443) | User: `admin` \| Pass: `HWx4ss9ED5GQN067` |
| **Cloud Grafana Dashboards** | OCI Cloud VM 1 | [http://137.23.38.177:3000](http://137.23.38.177:3000) | Live 11-node hybrid telemetry dashboard |
| **Jenkins CI/CD Engine** | `CT102` (`jenkins`) | [http://10.10.10.102:8080/](http://10.10.10.102:8080/) | Job: `devops-pipeline` (Auto SCM Trigger) |
| **Prometheus TSDB Core** | `CT106` (`prometheus`) | [http://10.10.10.106:9090](http://10.10.10.106:9090) | Central TSDB, 11/11 Active Targets `UP` |
| **cAdvisor Container Metrics** | `CT108` (`docker-host`) | [http://10.10.10.108:8085](http://10.10.10.108:8085) | Live Docker container resource consumption |
| **Proxmox VE Hypervisor** | Physical Host | [https://192.168.155.128:8006](https://192.168.155.128:8006) | Proxmox VE 9.1.1 Management UI |

---

## 🖥️ Node & Workload Inventory

| VMID / Host | Hostname | IP Address | Platform | Specs | Primary Role |
|---|---|---|---|---|---|
| **CT100** | `control-node` | `10.10.10.100`<br>`192.168.155.132` | Proxmox LXC | 2 vCPU / 1 GB | Ansible Hub, SSH Keymaster, Systemd Hybrid Tunnel Gateway |
| **CT101** | `terraform-test` | `10.10.10.101` | Proxmox LXC | 2 vCPU / 1 GB | Nginx Ingress Reverse Proxy, Domain Joined (`lab.local`) |
| **CT102** | `jenkins` | `10.10.10.102` | Proxmox LXC | 2 vCPU / 2 GB | Jenkins Automation Server, Docker CLI, Git SCM Poller |
| **CT103** | `staging` | `10.10.10.103` | Proxmox LXC | 2 vCPU / 1 GB | Pre-Production Staging Runtime, Domain Joined (`lab.local`) |
| **CT104** | `production` | `10.10.10.104` | Proxmox LXC | 2 vCPU / 1 GB | Production Application Tier, Domain Joined (`lab.local`), DB Host |
| **CT105** | `samba-dc` | `10.10.10.105` | Proxmox LXC | 2 vCPU / 1 GB | Active Directory Domain Controller (`LAB.LOCAL`), Kerberos, DNS |
| **CT106** | `prometheus` | `10.10.10.106` | Proxmox LXC | 2 vCPU / 1 GB | Central Prometheus TSDB Core (`:9090`), Alertmanager |
| **CT107** | `grafana` | `10.10.10.107` | Proxmox LXC | 2 vCPU / 512 MB | *(Stopped / Preserved)* Config preserved for future container repurposing |
| **CT108** | `docker-host` | `10.10.10.108`<br>`192.168.155.139` | Proxmox LXC | 2 vCPU / 2 GB RAM + 2 GB Swap | Docker Runtime, Portfolio App (`:8080`), cAdvisor (`:8085`) |
| **CT109** | `argocd-k8s` | `10.10.10.109`<br>`192.168.155.142` | Proxmox LXC | 2 vCPU / 3 GB RAM + 1 GB Swap | K3s Kubernetes Cluster, Argo CD v3.6.1 (`:30443`), node-exporter |
| **Cloud VM 1** | `cloud-grafana` | `137.23.38.177` | Oracle Cloud | 1 OCPU / 1 GB + 2 GB Swap | Cloud Grafana 13.3.1 (`:3000`), Global Hybrid Dashboards |
| **Cloud VM 2** | `cloud-k8s` | `130.210.84.113` | Oracle Cloud | 2 OCPU / 12 GB | Node Exporter (`:9100`), Cloud Kubernetes Cluster Worker Candidate |

---

## 🐙 GitOps Control Plane (Argo CD App-of-Apps)

The entire hybrid architecture is modeled declaratively in Argo CD via a hierarchical **App-of-Apps pattern** (`gitops/root-infrastructure.yaml`):

```
root-infrastructure (Master App-of-Apps)
 ├── 01-core-network-identity    -> CT100 (Ansible/Gateway) & CT105 (Samba Active Directory/DNS)
 ├── 02-observability-platform   -> CT106 (Prometheus TSDB) & OCI VM 1 (Cloud Grafana 13.3.1)
 ├── 03-cicd-jenkins             -> CT102 (Jenkins CI/CD Automation Engine)
 ├── 04-docker-nodes             -> CT108 (Production Docker Runtime & cAdvisor)
 ├── 05-argocd-gitops-engine     -> CT109 (Argo CD & K3s Kubernetes Control Plane)
 ├── 06-cloud-infrastructure     -> OCI VM 1 (Grafana Host) & OCI VM 2 (Kubernetes Node)
 └── 07-portfolio-website        -> Production Deployment & Service of Abhishek Mishra's Portfolio App
```

### UI Transparency for New Engineers:
- **Direct External Links**: Each application card features a direct external link button in the upper-right corner leading to that service's web UI.
- **Node Specs & Guides**: Each application houses an embedded Markdown `README.md` guide inside a ConfigMap detailing hardware specs, network IPs, roles, active ports, dependencies, and operational runbooks.
- **Zero Warnings**: Pruned legacy endpoints so all 8 applications display clean **`<none>`** under Conditions.

---

## 🔄 End-to-End CI/CD Pipeline (Jenkins)

The CI/CD pipeline (`Jenkinsfile`) automates the full journey from code commit to multi-cloud deployment and GitOps synchronization:

```
[Developer pushes commit to GitHub]
              │
              ▼
    [Jenkins SCM Poller] (polls every minute on CT102)
              │
              ▼
    [Stage: Checkout] (pulls latest code from main)
              │
              ▼
    [Stage: Deploy Cloud Infrastructure] (Terraform init/plan/apply for OCI compute & NSGs)
              │
              ▼
    [Stage: Deploy Docker App via Ansible]
     ├── 1. Clones/pulls ABHISHEK-CLOUD1/app.git on CT108
     ├── 2. Executes multi-stage Docker build (React 19 + CRACO + Tailwind -> Nginx Alpine)
     ├── 3. Restarts container my-custom-website on port 8080
     ├── 4. Streams container image to CT109 K3s containerd runtime
     └── 5. Triggers argocd app sync portfolio-website
              │
              ▼
    [Stage: Verify] (asserts HTTP 200 OK on live endpoints)
              │
              ▼
    [Post Action: Success] ("Docker Deployment successful! V2 is live.")
```

---

## 📊 Observability & Telemetry Mesh

Centralized monitoring aggregates metrics across all 11 hybrid targets:

| Target Instance | Scrape Endpoint | Job Name | Role & Description | Status |
|---|---|---|---|---|
| `127.0.0.1:9090` | `prometheus` | `prometheus` | Prometheus TSDB self-monitoring | **UP** |
| `10.10.10.100:9100` | `control-node` | `node` | Ansible Controller & Tunnel Gateway | **UP** |
| `10.10.10.101:9100` | `terraform-test` | `node` | Nginx Ingress Web Server | **UP** |
| `10.10.10.102:9100` | `jenkins` | `node` | Jenkins CI/CD Engine | **UP** |
| `10.10.10.103:9100` | `staging` | `node` | Staging Pre-prod Runtime | **UP** |
| `10.10.10.104:9100` | `production` | `node` | Production Application Host | **UP** |
| `10.10.10.105:9100` | `samba-dc` | `node` | Samba Active Directory Domain Controller | **UP** |
| `10.10.10.106:9100` | `prometheus` | `node` | Prometheus Server Host | **UP** |
| `10.10.10.108:9100` | `docker-host` | `node` | Docker Container Runtime Host | **UP** |
| `10.10.10.108:8085` | `docker-host` | `cadvisor` | cAdvisor Container Health & Resource Usage | **UP** |
| `10.10.10.109:9100` | `argocd-k8s` | `node` | Argo CD GitOps & K3s Control Plane | **UP** |
| `10.10.10.100:9101` | `cloud-grafana` | `node` | Oracle Cloud VM 1 (Grafana Host via SSH Tunnel) | **UP** |
| `10.10.10.100:9102` | `cloud-k8s` | `node` | Oracle Cloud VM 2 (Kubernetes Node via SSH Tunnel) | **UP** |

---

## 🔒 Zero-Trust Hybrid Cloud Networking

Because the homelab resides behind double-NAT with no public IPv4 address, and Oracle Cloud compute instances strictly filter inbound traffic:
- **Reverse Port Forward (`-R 9090:10.10.10.106:9090`):** Exposes on-premise Prometheus to Cloud Grafana over `127.0.0.1:9090` without opening any public firewall ports.
- **Local Port Forwards (`-L 0.0.0.0:9101:127.0.0.1:9100` & `9102`):** Brings Cloud VM 1 and Cloud VM 2 telemetry securely into the private homelab subnet for Prometheus scraping.
- **Persistent Daemons:** Managed by systemd units `prometheus-cloud-tunnel.service` and `k8s-cloud-tunnel.service` on CT100 with auto-restart.

---

## 📁 Repository Structure

```
.
├── Jenkinsfile                             # Multi-stage CI/CD pipeline definition
├── README.md                               # Infrastructure architecture documentation
├── inventory.ini                           # Unified 11-node Ansible inventory
├── ansible/                                # Automation playbooks
│   ├── activate-eth1.yml                   # Secondary network interface activator
│   ├── deploy-app.yml                      # Automated Docker build, stream & Argo CD sync
│   ├── fix-samba.yml                       # Samba DC repair playbook
│   ├── install-jenkins.yml                 # Jenkins deployment playbook
│   ├── install-nginx.yml                   # Nginx reverse proxy installer
│   ├── install-samba-dc.yml                # Active Directory deployment playbook
│   ├── join-domain.yml                     # SSSD / Realm Active Directory joining
│   ├── node_exporter.yml                   # Prometheus node_exporter installer
│   └── inventory.ini                       # Playbook inventory reference
├── app/                                    # Portfolio application deployment specifications
│   ├── Dockerfile                          # Multi-stage React/Craco + Nginx Dockerfile
│   └── nginx.conf                          # Production Nginx SPA fallback configuration
├── docs/                                   # Architecture specifications & diagrams
│   ├── Hybrid_Infrastructure_DevOps_Architecture.docx
│   ├── Hybrid_Infrastructure_DevOps_Architecture.pdf
│   └── hybrid_infrastructure_architecture.jpg
├── gitops/                                 # Declarative Argo CD GitOps definitions
│   ├── root-infrastructure.yaml            # Master App-of-Apps root definition
│   ├── apps/                               # Child Application definitions
│   │   ├── 01-core-network-identity.yaml
│   │   ├── 02-observability-platform.yaml
│   │   ├── 03-cicd-jenkins.yaml
│   │   ├── 04-docker-nodes.yaml
│   │   ├── 05-argocd-gitops-engine.yaml
│   │   ├── 06-cloud-infrastructure.yaml
│   │   └── 07-portfolio-website.yaml
│   └── manifests/                          # Declarative Kubernetes / Homelab specs
│       ├── argocd-gitops-engine/
│       ├── cicd-jenkins/
│       ├── cloud-infrastructure/
│       ├── core-network-identity/
│       ├── docker-nodes/
│       ├── observability-platform/
│       └── portfolio-website/
├── monitoring/                             # Centralized Prometheus configuration
│   └── prometheus.yml                      # 11-target scrape configuration
├── systemd/                                # Persistent SSH tunnel service units
│   ├── k8s-cloud-tunnel.service
│   └── prometheus-cloud-tunnel.service
└── terraform/                              # Infrastructure as Code (OCI compute & security)
    ├── main.tf
    └── variables.tf
```

---

## 👤 Author & Governance

- **Architect & Administrator**: **Abhishek Mishra** ([@ABHISHEK-CLOUD1](https://github.com/ABHISHEK-CLOUD1))
- **Autonomous Control Plane**: **Google Antigravity**
