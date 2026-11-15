# Enterprise Hybrid Homelab & Multi-Cloud GitOps Infrastructure

[![Hypervisor](https://img.shields.io/badge/Hypervisor-Proxmox%20VE%209.1.1-E57000?logo=proxmox)](https://www.proxmox.com)
[![Cloud](https://img.shields.io/badge/Cloud-Oracle%20Cloud%20(OCI)-F80000?logo=oracle)](https://cloud.oracle.com)
[![GitOps](https://img.shields.io/badge/GitOps-Argo%20CD%20v3.6.1-EF7B4D?logo=argo)](https://argo-cd.readthedocs.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s%20v1.37.2-326CE5?logo=kubernetes)](https://k3s.io)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20Automation-D24939?logo=jenkins)](https://jenkins.io)
[![Observability](https://img.shields.io/badge/Observability-Prometheus%20%2B%20Grafana%2013.3.1-F46800?logo=prometheus)](https://prometheus.io)
[![Portfolio Live](https://img.shields.io/badge/Portfolio%20Live-GitHub%20Pages-2ea44f?logo=github)](https://abhishek-cloud1.github.io/app/)
[![Autonomous AI](https://img.shields.io/badge/Orchestrator-Google%20Antigravity-4285F4?logo=google)](https://deepmind.google)

---

## 🏛️ Architectural Overview

This repository governs an enterprise-grade hybrid cloud infrastructure bridging an on-premise **Proxmox VE 9.1.1** cluster (`192.168.155.128`) operating on dual Class C subnets (`10.10.10.0/24` and `192.168.155.0/24`) to **Oracle Cloud Infrastructure (OCI)** compute nodes via encrypted, zero-trust bidirectional SSH tunnels.

The entire topology is declaratively managed through **Argo CD GitOps**, automated by **Jenkins** and **Ansible**, and monitored by a centralized **Prometheus** TSDB with real-time visualization dashboards on **Cloud Grafana**.

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
|  [CT107: preserved-node] --> Preserved / Stopped container (Ready for future container deployment) |
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
|  [OCI VM 2: K8s Candidate]    --> Node Exporter (:9100), Public IP: 130.210.84.113                 |
+----------------------------------------------------------------------------------------------------+
```

---

## 🚀 Live Services & Port Forwarding Directory

| System / Application | Host Node | Internal IP | External / Web Endpoint | Credentials / Access |
|---|---|---|---|---|
| **Portfolio (Global Edge)** | GitHub Pages | N/A | [https://abhishek-cloud1.github.io/app/](https://abhishek-cloud1.github.io/app/) | Public (Fastly Global CDN, 0 gates) |
| **Portfolio (Docker Host)** | `CT108` | `10.10.10.108` | [http://192.168.155.139:8080/](http://192.168.155.139:8080/) | Public inside LAN / Homelab |
| **Portfolio (Cloudflare Tunnel)** | `CT108` | `10.10.10.108` | [Cloudflare Live Edge](https://necessary-lauderdale-behaviour-profits.trycloudflare.com) | HTTPS Zero-Trust Tunnel |
| **Portfolio (Named Tunnel)** | `CT108` | `10.10.10.108` | [https://abhishekmishra.loca.lt](https://abhishekmishra.loca.lt) | Named Tunnel (`loca.lt`) |
| **Argo CD Control Plane** | `CT109` | `10.10.10.109` | [https://192.168.155.142:30443](https://192.168.155.142:30443) | `admin` / `HWx4ss9ED5GQN067` |
| **Cloud Grafana 13.3.1** | `OCI VM 1` | `10.0.0.86` | [http://137.23.38.177:3000](http://137.23.38.177:3000) | `admin` / configured |
| **Prometheus Core TSDB** | `CT106` | `10.10.10.106` | `http://10.10.10.106:9090` | Internal (Scrapes 11 targets) |
| **Jenkins CI/CD Automation** | `CT102` | `10.10.10.102` | [http://10.10.10.102:8080](http://10.10.10.102:8080) | Jenkins Admin / Pre-configured |
| **cAdvisor Container Metrics**| `CT108` | `10.10.10.108` | `http://192.168.155.139:8085` | Internal Prometheus Metric Stream |
| **Active Directory Domain Controller** | `CT105` | `10.10.10.105` | Domain: `LAB.LOCAL` | Kerberos KDC, DNS, LDAP |

---

## 📦 10-Node Infrastructure Inventory

| Node ID | Hostname | Internal IP | External IP | OS / Distribution | vCPU / RAM | Role & Primary Workloads | Status |
|---|---|---|---|---|---|---|---|
| **CT100** | `control-node` | `10.10.10.100` | `192.168.155.132` | Debian 12 | 2 vCPU / 2048 MB | Ansible Control Node, Git Central Repo, Keymaster | 🟢 Active |
| **CT101** | `terraform-test` | `10.10.10.101` | — | Debian 12 | 2 vCPU / 2048 MB | Nginx Ingress, Domain Joined (`lab.local`) | 🟢 Active |
| **CT102** | `jenkins` | `10.10.10.102` | — | Debian 12 | 2 vCPU / 2048 MB | Jenkins CI/CD Engine (`:8080`), Docker build pipeline | 🟢 Active |
| **CT103** | `staging` | `10.10.10.103` | — | Debian 12 | 2 vCPU / 2048 MB | Staging runtime environment, Domain Joined | 🟢 Active |
| **CT104** | `production` | `10.10.10.104` | — | Debian 12 | 2 vCPU / 2048 MB | Production database & runtime, Domain Joined | 🟢 Active |
| **CT105** | `samba-dc` | `10.10.10.105` | — | Debian 12 | 2 vCPU / 2048 MB | Active Directory DC (`LAB.LOCAL`), DNS, Kerberos | 🟢 Active |
| **CT106** | `prometheus` | `10.10.10.106` | — | Debian 12 | 2 vCPU / 2048 MB | Central Prometheus Core TSDB (`:9090`), 11 targets | 🟢 Active |
| **CT107** | `preserved-node`| `10.10.10.107` | — | Debian 12 | 2 vCPU / 2048 MB | Preserved container (`onboot: 0`), ready for reuse | ⚪ Stopped |
| **CT108** | `docker-host` | `10.10.10.108` | `192.168.155.139` | Debian 12 | 2 vCPU / 2048 MB | Docker Runtime, Portfolio App (`:8080`), cAdvisor | 🟢 Active |
| **CT109** | `argocd-k8s` | `10.10.10.109` | `192.168.155.142` | Debian 12 | 2 vCPU / 2048 MB | K3s Cluster, Argo CD v3.6.1 (`:30443`), Node Exporter | 🟢 Active |
| **OCI 1** | `cloud-vm-1` | `10.0.0.86` | `137.23.38.177` | Ubuntu 22.04 | 1 vCPU / 1024 MB | Cloud Grafana 13.3.1 (`:3000`), SSH Tunnel Gateway | 🟢 Active |
| **OCI 2** | `cloud-vm-2` | `10.0.0.12` | `130.210.84.113` | Ubuntu 22.04 | 1 vCPU / 1024 MB | Node Exporter (`:9100`), Multi-cloud worker candidate | 🟢 Active |

---

## 💽 Proxmox Storage Architecture & LVM Thin-Pool Optimization

During high-volume multi-stage container builds, the Proxmox LVM thin pool (`pve/data`) was dynamically expanded to ensure zero disk throttling:

```bash
# Proxmox Host Storage Diagnostics & Dynamic Expansion
lvextend -L +10G /dev/pve/data
# Increased thin pool data size from 42.25 GB to 52.25 GB
# Reduced data utilization from 100.00% to 80.86%
```

* **Storage Pool**: LVM-Thin `pve-data` (`52.25 GB` total capacity, `~10 GB` unallocated headroom).
* **Container Disks**: All 10 containers mount root filesystems formatted in `ext4` on virtual thin volumes (`vm-XXX-disk-0`).
* **CT108 Tuning**: Upgraded to `2048 MB` RAM + `2048 MB` Swap to support parallel Webpack/CRACO builds without memory pressure.

---

## 🐙 Declarative GitOps Model (Argo CD App-of-Apps)

Argo CD v3.6.1 runs on **CT109** under K3s `v1.37.2+k3s1`. The root application (`root-infrastructure`) declaratively governs 7 child applications:

```
root-infrastructure (Master App-of-Apps)
│
├── 01. argocd-gitops-engine  --> CT109 GitOps Control Plane & Core K8s Manifests
├── 02. core-network-identity  --> CT100 Ansible Gateway & CT105 Samba Domain Controller
├── 03. observability-platform --> CT106 Prometheus TSDB & OCI VM 1 Cloud Grafana
├── 04. cicd-jenkins           --> CT102 Jenkins Enterprise CI/CD Automation Engine
├── 05. docker-nodes           --> CT108 Production Docker Runtime & cAdvisor
├── 06. cloud-infrastructure   --> OCI VM 1 (Grafana) & OCI VM 2 (Kubernetes Node)
└── 07. portfolio-website      --> React Production Application, Service & Spec ConfigMap
```

### Manifest Specifications
All declarative manifests reside in `gitops/` and are synchronized automatically:
* Self-healing enabled with automated pruning.
* `ExternalName` and ClusterIP services provide zero-warning UI navigation pills.
* Custom ConfigMaps provide full operational runbooks viewable directly inside the Argo CD web dashboard.

---

## 🔄 Automated CI/CD Pipeline (Jenkins)

The Jenkins pipeline (`job/devops-pipeline`) automated on **CT102** triggers on every commit:

1. **SCM Checkout**: Clones latest code from [ABHISHEK-CLOUD1/Devops-lab](https://github.com/ABHISHEK-CLOUD1/Devops-lab) and [ABHISHEK-CLOUD1/app](https://github.com/ABHISHEK-CLOUD1/app).
2. **Infrastructure Validation**: Runs `terraform plan` and `terraform apply` for Oracle Cloud Infrastructure compute nodes and network security groups.
3. **Container Build & Distribution**:
   - Executes multi-stage compilation using `node:22-alpine` and `yarn build`.
   - Packages optimized static assets into lightweight `nginx:alpine` runtime image.
   - Deploys container `my-custom-website` on CT108 on port `8080`.
   - Exports image archive and streams directly to K3s containerd runtime on CT109.
4. **GitOps Synchronization**: Dispatches `argocd app sync root-infrastructure` with automatic retry handling.

---

## 📊 Observability & Telemetry Mesh

### Prometheus Core TSDB (`CT106:9090`)
Centralized Prometheus configuration scrapes **11 distributed targets** with all endpoints reporting state `UP` (`1`):
1. `control-node` (`10.10.10.100:9100`)
2. `terraform-test` (`10.10.10.101:9100`)
3. `jenkins` (`10.10.10.102:9100`)
4. `staging` (`10.10.10.103:9100`)
5. `production` (`10.10.10.104:9100`)
6. `samba-dc` (`10.10.10.105:9100`)
7. `prometheus` (`10.10.10.106:9100`)
8. `docker-host` (`10.10.10.108:9100`)
9. `argocd-k8s` (`10.10.10.109:9100`)
10. `cadvisor-docker` (`10.10.10.108:8085`)
11. `cloud-vm-2` (`130.210.84.113:9100`)

### Cloud Grafana (`OCI VM 1:3000`)
* Connected to Prometheus TSDB via secure SSH tunnel (`localhost:9090` $\rightarrow$ `10.10.10.106:9090`).
* Live dashboards monitor node CPU, memory pressure, disk I/O, container resource limits, and network throughput across the entire hybrid cloud.

---

## 👤 Author & Governance

- **Architect & Homelab Administrator**: **Abhishek Mishra** ([@ABHISHEK-CLOUD1](https://github.com/ABHISHEK-CLOUD1))
- **Autonomous Control Plane**: **Google Antigravity**
