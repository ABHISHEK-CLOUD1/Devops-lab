# Enterprise Hybrid Homelab & Multi-Cloud GitOps Infrastructure

[![Hypervisor](https://img.shields.io/badge/Hypervisor-Proxmox%20VE%209.1.1-E57000?logo=proxmox)](https://www.proxmox.com)
[![Cloud](https://img.shields.io/badge/Cloud-Oracle%20Cloud%20(OCI)-F80000?logo=oracle)](https://cloud.oracle.com)
[![GitOps](https://img.shields.io/badge/GitOps-Argo%20CD%20v3.6.1-EF7B4D?logo=argo)](https://argo-cd.readthedocs.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s%20v1.37.2-326CE5?logo=kubernetes)](https://k3s.io)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20Automation-D24939?logo=jenkins)](https://jenkins.io)
[![Observability](https://img.shields.io/badge/Observability-Prometheus%20%2B%20Grafana%2013.3.1-F46800?logo=prometheus)](https://prometheus.io)
[![Identity](https://img.shields.io/badge/Identity-Samba%20Active%20Directory-blue)](https://samba.org)
[![Live Portfolio](https://img.shields.io/badge/Live%20Platform-GitHub%20Pages-2ea44f?logo=github)](https://abhishek-cloud1.github.io/app/)
[![Autonomous Control](https://img.shields.io/badge/Orchestrator-Google%20Antigravity-4285F4?logo=google)](https://deepmind.google)

---

## 📑 Table of Contents

1. [Architectural Overview & Topology](#1-architectural-overview--topology)
2. [Global Endpoints & Live Services Directory](#2-global-endpoints--live-services-directory)
3. [Complete 10-Node Infrastructure Inventory](#3-complete-10-node-infrastructure-inventory)
4. [Storage Subsystem & LVM Thin-Pool Management](#4-storage-subsystem--lvm-thin-pool-management)
5. [Declarative GitOps Engine (Argo CD App-of-Apps)](#5-declarative-gitops-engine-argo-cd-app-of-apps)
6. [Continuous Integration & Delivery Pipeline (Jenkins)](#6-continuous-integration--delivery-pipeline-jenkins)
7. [Observability & Telemetry Mesh (Prometheus & Grafana)](#7-observability--telemetry-mesh-prometheus--grafana)
8. [Identity, DNS & Directory Services (Samba Active Directory)](#8-identity-dns--directory-services-samba-active-directory)
9. [Multi-Cloud Networking & Security Architecture](#9-multi-cloud-networking--security-architecture)
10. [Portfolio Application Deployment Architecture](#10-portfolio-application-deployment-architecture)
11. [Operational Runbooks & Incident Response](#11-operational-runbooks--incident-response)
12. [Repository Structure](#12-repository-structure)

---

## 1. Architectural Overview & Topology

The platform integrates on-premises virtualization with public cloud infrastructure into a unified, declaratively managed control plane.

```
+-----------------------------------------------------------------------------------------------------------------+
|                                         PROXMOX VE HYPERVISOR (192.168.155.128)                                 |
|                                                                                                                 |
|   Private Internal Subnet: 10.10.10.0/24 (vmbr1)  |  Management LAN Subnet: 192.168.155.0/24 (vmbr0)            |
|                                                                                                                 |
|   +------------------------------------+      +------------------------------------+                            |
|   | CT100: control-node (10.10.10.100) |      | CT105: samba-dc (10.10.10.105)     |                            |
|   | • Ansible Automation Engine        |      | • Active Directory DC (LAB.LOCAL)  |                            |
|   | • Central Git Control Repository   |      | • Kerberos KDC & Integrated DNS    |                            |
|   | • SSH Keymaster & Tunnel Gateway   |      | • Realm Authentication Provider    |                            |
|   +------------------------------------+      +------------------------------------+                            |
|                                                                                                                 |
|   +------------------------------------+      +------------------------------------+                            |
|   | CT101: terraform-test (10.10.10.101|      | CT106: prometheus (10.10.10.106)   |                            |
|   | • Ingress Reverse Proxy (Nginx)    |      | • Prometheus TSDB Core (:9090)     |                            |
|   | • AD Domain Joined (lab.local)     |      | • Scrapes 14 Streams / 11 Targets  |                            |
|   +------------------------------------+      +------------------------------------+                            |
|                                                                                                                 |
|   +------------------------------------+      +------------------------------------+                            |
|   | CT102: jenkins (10.10.10.102)      |      | CT107: preserved-node (Stopped)    |                            |
|   | • Jenkins CI/CD Engine (:8080)     |      | • Preserved container (onboot: 0)  |                            |
|   | • Multi-Stage Build & Deployer     |      | • Reserved for Future Workloads    |                            |
|   +------------------------------------+      +------------------------------------+                            |
|                                                                                                                 |
|   +------------------------------------+      +------------------------------------+                            |
|   | CT103: staging (10.10.10.103)      |      | CT108: docker-host (10.10.10.108)  |                            |
|   | • Staging Validation Runtime       |      | • Docker Engine (2GB RAM + 2GB SW) |                            |
|   | • AD Domain Joined (lab.local)     |      | • Portfolio Website (:8080)        |                            |
|   +------------------------------------+      | • cAdvisor Metrics Stream (:8085)  |                            |
|                                               | • Cloudflare & Localtunnel Daemons |                            |
|   +------------------------------------+      +------------------------------------+                            |
|   | CT104: production (10.10.10.104)   |                                                                        |
|   | • Production App & Database        |      +------------------------------------+                            |
|   | • AD Domain Joined (lab.local)     |      | CT109: argocd-k8s (10.10.10.109)   |                            |
|   +------------------------------------+      | • K3s Lightweight Kubernetes       |                            |
|                                               | • Argo CD v3.6.1 GitOps (:30443)   |                            |
|                                               | • App-of-Apps Master Controller    |                            |
|                                               +------------------------------------+                            |
+-------------------------------------------------------+---------------------------------------------------------+
                                                        |
                                Encrypted Bidirectional Persistent SSH Tunnels
                                                        |
+-------------------------------------------------------▼---------------------------------------------------------+
|                                    ORACLE CLOUD INFRASTRUCTURE (OCI ap-mumbai-1)                                |
|                                                                                                                 |
|   VCN: vcn-mumbai (10.0.0.0/16)  |  Public Cloud Subnet: 10.0.0.0/24                                            |
|                                                                                                                 |
|   +--------------------------------------------------+  +---------------------------------------------------+   |
|   | OCI VM 1: cloud-vm-1 (10.0.0.86 / 137.23.38.177) |  | OCI VM 2: cloud-vm-2 (10.0.0.12 / 130.210.84.113) |   |
|   | • Cloud Grafana 13.3.1 Visualization (:3000)     |  | • Linux Compute Host (Ubuntu 22.04 LTS)           |   |
|   | • Reverse SSH Tunnel to CT106 TSDB (:9090)       |  | • Prometheus Node Exporter (:9100)                |   |
|   | • NSG Security Rule: Ingress 3000 (0.0.0.0/0)    |  | • Multi-Cloud Kubernetes Candidate Node           |   |
|   +--------------------------------------------------+  +---------------------------------------------------+   |
+-----------------------------------------------------------------------------------------------------------------+
```

---

## 2. Global Endpoints & Live Services Directory

| Service | Node / Container | Network Binding | Public / Web URL | Authentication / Protocol |
|---|---|---|---|---|
| **Portfolio Website (Global Edge)** | GitHub Pages | Fastly CDN | [https://abhishek-cloud1.github.io/app/](https://abhishek-cloud1.github.io/app/) | Public (0 gates, instant load, SSL) |
| **Portfolio Website (Docker)** | `CT108` | `10.10.10.108:8080` | [http://192.168.155.139:8080/](http://192.168.155.139:8080/) | Internal LAN (Nginx SPA, `/app` alias) |
| **Cloudflare Zero-Trust Tunnel**| `CT108` | `10.10.10.108:8080` | [Cloudflare Live Edge](https://necessary-lauderdale-behaviour-profits.trycloudflare.com) | Quick Tunnel (HTTPS Edge) |
| **Named Quick Tunnel** | `CT108` | `10.10.10.108:8080` | [https://abhishekmishra.loca.lt](https://abhishekmishra.loca.lt) | Named Localtunnel (`loca.lt`) |
| **Argo CD Web UI** | `CT109` | `10.10.10.109:30443` | [https://192.168.155.142:30443](https://192.168.155.142:30443) | `admin` / `HWx4ss9ED5GQN067` |
| **Cloud Grafana UI** | `OCI VM 1` | `10.0.0.86:3000` | [http://137.23.38.177:3000](http://137.23.38.177:3000) | `admin` / Pre-configured |
| **Prometheus TSDB Core** | `CT106` | `10.10.10.106:9090` | `http://10.10.10.106:9090` | Internal (Scrapes 14 metrics streams) |
| **Jenkins CI/CD Dashboard** | `CT102` | `10.10.10.102:8080` | [http://10.10.10.102:8080](http://10.10.10.102:8080) | Jenkins Admin / RBAC |
| **cAdvisor Container Metrics** | `CT108` | `10.10.10.108:8085` | `http://192.168.155.139:8085` | Internal Prometheus Metric Stream |
| **Active Directory Domain** | `CT105` | `10.10.10.105` | Domain: `LAB.LOCAL` | Kerberos KDC, DNS, LDAP |

---

## 3. Complete 10-Node Infrastructure Inventory

| Node ID | Hostname | Internal IP | External IP | OS / Distribution | vCPU / RAM / Swap | Primary Operational Role | Status |
|---|---|---|---|---|---|---|---|
| **CT100** | `control-node` | `10.10.10.100` | `192.168.155.132` | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Ansible Controller, Git repo `/root/Devops-lab`, SSH gateway | 🟢 Active |
| **CT101** | `terraform-test` | `10.10.10.101` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Nginx Ingress Reverse Proxy, Domain Joined (`lab.local`) | 🟢 Active |
| **CT102** | `jenkins` | `10.10.10.102` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Jenkins CI/CD Engine (`:8080`), automated multibranch pipelines | 🟢 Active |
| **CT103** | `staging` | `10.10.10.103` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Pre-production Staging Runtime, Domain Joined (`lab.local`) | 🟢 Active |
| **CT104** | `production` | `10.10.10.104` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Production Application & Database Tier, Domain Joined | 🟢 Active |
| **CT105** | `samba-dc` | `10.10.10.105` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Active Directory Domain Controller (`LAB.LOCAL`), DNS, KDC | 🟢 Active |
| **CT106** | `prometheus` | `10.10.10.106` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Central Prometheus Core TSDB (`:9090`), 11 targets scraped | 🟢 Active |
| **CT107** | `preserved-node`| `10.10.10.107` | — | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | Preserved container (`onboot: 0`), ready for future deployment | ⚪ Preserved |
| **CT108** | `docker-host` | `10.10.10.108` | `192.168.155.139` | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 2048 MB | Production Docker Runtime, Portfolio App (`:8080`), cAdvisor | 🟢 Active |
| **CT109** | `argocd-k8s` | `10.10.10.109` | `192.168.155.142` | Debian 12 (Bookworm) | 2 vCPU / 2048 MB / 512 MB | K3s Cluster, Argo CD v3.6.1 (`:30443`), Node Exporter | 🟢 Active |
| **OCI 1** | `cloud-vm-1` | `10.0.0.86` | `137.23.38.177` | Ubuntu 22.04 LTS | 1 vCPU / 1024 MB / 1024 MB | Cloud Grafana 13.3.1 (`:3000`), SSH Tunnel Gateway | 🟢 Active |
| **OCI 2** | `cloud-vm-2` | `10.0.0.12` | `130.210.84.113` | Ubuntu 22.04 LTS | 1 vCPU / 1024 MB / 1024 MB | Prometheus Node Exporter (`:9100`), Multi-cloud worker | 🟢 Active |

---

## 4. Storage Subsystem & LVM Thin-Pool Management

### Physical & Logical Volume Hierarchy
* **Hypervisor Storage**: Proxmox Volume Group `pve` (99.49 GiB physical capacity on NVMe/SATA).
* **Thin Provisioning Pool**: `pve/data` (LVM-Thin driver, metadata volume `data_tmeta`).
* **Container Virtual Disks**: Each LXC container mounts a virtual block device (`vm-XXX-disk-0`) formatted with `ext4`.

### Dynamic Thin-Pool Expansion Runbook
During intensive container image compilations, the thin pool `pve/data` reached capacity threshold (100.00%), causing ext4 filesystem writes to be suspended by the kernel. The pool was dynamically expanded live on the Proxmox host (`192.168.155.128`) without data loss:

```bash
# Verify current logical volume and volume group status
lvs -a
vgs

# Dynamically extend thin pool data volume by +10 GB
lvextend -L +10G /dev/pve/data

# Verify new capacity (LSize: 52.25g, Data% dropped from 100.00% to 80.86%)
lvs /dev/pve/data
```

### Container Resource Tuning
To ensure Node.js Webpack and CRACO builds do not encounter Out-Of-Memory (OOM) conditions on CT108:
```bash
# Dynamically adjust memory and swap on CT108
pct set 108 -memory 2048 -swap 2048
```

---

## 5. Declarative GitOps Engine (Argo CD App-of-Apps)

The GitOps engine on **CT109** runs **Argo CD v3.6.1** on **K3s** (`v1.37.2+k3s1`). All infrastructure state is version-controlled in the [ABHISHEK-CLOUD1/Devops-lab](https://github.com/ABHISHEK-CLOUD1/Devops-lab) repository.

### App-of-Apps Hierarchy
The master root application (`root-infrastructure`) reconciles 7 distinct sub-applications:

```
root-infrastructure (Application / argocd)
│
├── 01. argocd-gitops-engine  (Path: gitops/manifests/argocd-gitops-engine)
│   └── Reconciles CT109 K3s node, Argo CD CRDs, and cluster RBAC
│
├── 02. core-network-identity  (Path: gitops/manifests/core-network-identity)
│   └── Reconciles CT100 Ansible controller and CT105 Samba Active Directory
│
├── 03. observability-platform (Path: gitops/manifests/observability-platform)
│   └── Reconciles CT106 Prometheus TSDB and OCI VM 1 Cloud Grafana
│
├── 04. cicd-jenkins           (Path: gitops/manifests/cicd-jenkins)
│   └── Reconciles CT102 Jenkins server, pipeline agents, and build targets
│
├── 05. docker-nodes           (Path: gitops/manifests/docker-nodes)
│   └── Reconciles CT108 Docker daemon, cAdvisor metrics, and runtime host
│
├── 06. cloud-infrastructure   (Path: gitops/manifests/cloud-infrastructure)
│   └── Reconciles OCI VM 1 (Grafana) and OCI VM 2 (Compute Node)
│
└── 07. portfolio-website      (Path: gitops/manifests/portfolio-website)
    └── Reconciles Production Web Deployment, Service, and ConfigMap Runbook
```

### GitOps Features
* **Automated Self-Healing (`auto-prune: true`)**: Any manual configuration drift on the cluster is automatically overwritten by the declared Git state.
* **ExternalName Services**: Avoids bare `Endpoints` warnings while providing clean navigation links within the Argo CD dashboard.
* **Embedded Runbooks**: Detailed operational documentation is embedded in Kubernetes `ConfigMap` resources, allowing engineers to read runbooks directly inside the Argo CD UI.

---

## 6. Continuous Integration & Delivery Pipeline (Jenkins)

Automated continuous integration is executed on **CT102** via Jenkins pipeline `job/devops-pipeline`:

```
[ Git Push to GitHub ]
         │
         ▼
[ Jenkins SCM Webhook / Poll ]
         │
         ▼
[ Stage 1: Checkout & Verification ]
  • Clone ABHISHEK-CLOUD1/Devops-lab and ABHISHEK-CLOUD1/app
         │
         ▼
[ Stage 2: Terraform OCI Validation ]
  • Validate OCI compute, NSG security rules, and VCN routes
         │
         ▼
[ Stage 3: Multi-Stage Container Build ]
  • Compile React 19 SPA using Node 22 Alpine + Yarn
  • Package static bundle into Nginx Alpine runtime
  • Deploy container my-custom-website on CT108 (:8080)
         │
         ▼
[ Stage 4: Kubernetes Containered Stream ]
  • Export Docker image archive and stream to K3s containerd on CT109
         │
         ▼
[ Stage 5: Argo CD GitOps Sync ]
  • Execute: argocd app sync root-infrastructure --prune
  • Health probe verification (retry loop with exponential backoff)
```

---

## 7. Observability & Telemetry Mesh (Prometheus & Grafana)

### Prometheus Core TSDB (`CT106:9090`)
Central Prometheus instance configured with a 15-second scrape interval. Currently tracking **14 metrics streams across 11 targets**, with all targets reporting state `UP` (`1`):

```yaml
# /etc/prometheus/prometheus.yml target definitions
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['10.10.10.100:9100']  # CT100: control-node
      - targets: ['10.10.10.101:9100']  # CT101: terraform-test
      - targets: ['10.10.10.102:9100']  # CT102: jenkins
      - targets: ['10.10.10.103:9100']  # CT103: staging
      - targets: ['10.10.10.104:9100']  # CT104: production
      - targets: ['10.10.10.105:9100']  # CT105: samba-dc
      - targets: ['10.10.10.106:9100']  # CT106: prometheus
      - targets: ['10.10.10.108:9100']  # CT108: docker-host
      - targets: ['10.10.10.109:9100']  # CT109: argocd-k8s
      - targets: ['130.210.84.113:9100'] # OCI VM 2: cloud-vm-2
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['10.10.10.108:8085']  # CT108: Docker Container Metrics
```

### Cloud Grafana 13.3.1 (`OCI VM 1:3000`)
* **Tunnel Architecture**: Systemd unit `prometheus-cloud-tunnel.service` on CT100 maintains an encrypted reverse SSH tunnel forwarding `localhost:9090` on OCI VM 1 to `10.10.10.106:9090`.
* **Telemetry Visualized**: Cluster-wide CPU usage, memory utilization, container CPU/RAM limits, disk I/O latency, network throughput, and Active Directory authentication metrics.

---

## 8. Identity, DNS & Directory Services (Samba Active Directory)

* **Domain Controller**: `CT105` running Samba 4 as Active Directory Domain Controller.
* **Realm**: `LAB.LOCAL` | **Domain NetBIOS**: `LAB`
* **Kerberos KDC**: Running on port `88` (UDP/TCP).
* **Integrated DNS**: Authoritative DNS server for `lab.local` zone.
* **Domain Joined Nodes**: `CT101`, `CT103`, and `CT104` are domain-joined via SSSD and Realm, enabling centralized Active Directory authentication and enterprise Kerberos single sign-on.

---

## 9. Multi-Cloud Networking & Security Architecture

### Network Segmentation
* **Management Network (`192.168.155.0/24`)**: Bound to `vmbr0` (bridged to host physical interface). Used for Proxmox Web GUI (`:8006`), Argo CD NodePort (`:30443`), and direct SSH administration.
* **Isolated LAN Subnet (`10.10.10.0/24`)**: Bound to `vmbr1` (internal virtual switch). Isolated backend network for all inter-container traffic (database, Active Directory, Prometheus scraping).
* **Oracle Cloud VCN (`10.0.0.0/16`)**: Virtual Cloud Network in `ap-mumbai-1` subnetted into `10.0.0.0/24`.

### Security Rules (OCI NSG & Iptables)
* **OCI Network Security Group (`grafana_nsg`)**:
  * Ingress rule allowing TCP port `3000` from `0.0.0.0/0` (Cloud Grafana web interface).
  * Ingress rule allowing TCP port `22` from administrative IP addresses.
* **Host Iptables**: Stateful firewall rules allowing established/related connections and drops unauthenticated ingress packets.

---

## 10. Portfolio Application Deployment Architecture

The developer platform from [ABHISHEK-CLOUD1/app](https://github.com/ABHISHEK-CLOUD1/app) is deployed across a multi-channel mesh:

```
[ Developer Commit ]
         │
         ├──► [ GitHub Pages (Global Edge) ] ──► https://abhishek-cloud1.github.io/app/
         │     • Fastly Edge CDN, zero gates, SPA fallback
         │
         ├──► [ CT108 Docker Host (On-Prem) ] ──► http://192.168.155.139:8080/
         │     • Multi-stage Node 22 + Nginx Alpine
         │     • Cloudflare Zero-Trust Tunnel: https://*.trycloudflare.com
         │     • Named Localtunnel: https://abhishekmishra.loca.lt
         │
         └──► [ CT109 K3s / Argo CD ] ──────────► Application: portfolio-website
               • Declarative Kubernetes Deployment, Service, and ConfigMap
```

### Key Technical Features
* **Aesthetic**: Dark obsidian theme (`#030712`), ambient cyan/purple glow, macOS-styled telemetry card, removed user photo.
* **Email Engine**: Asynchronous AJAX FormSubmit integration (`abhishek010601@gmail.com`) with activation handling.
* **Subpath Routing**: Configured with `"homepage": "https://abhishek-cloud1.github.io/app"` and Nginx rewrite rules to support both root (`/`) and subpath (`/app`) execution.

---

## 11. Operational Runbooks & Incident Response

### Runbook 1: LVM Thin-Pool Out-of-Space Recovery
```bash
# Check if pool is full (Data% == 100.00%)
ssh root@192.168.155.128 "lvs -a"

# Expand thin pool by 10 GB
ssh root@192.168.155.128 "lvextend -L +10G /dev/pve/data"

# Verify expansion
ssh root@192.168.155.128 "lvs /dev/pve/data"
```

### Runbook 2: Argo CD Application Resynchronization
```bash
# Sync entire infrastructure tree
ssh root@192.168.155.128 "pct exec 109 -- /usr/local/bin/argocd app sync root-infrastructure --prune"

# Check health across all 7 child apps
ssh root@192.168.155.128 "pct exec 109 -- /usr/local/bin/argocd app list"
```

### Runbook 3: Restarting Docker Portfolio & Tunnels on CT108
```bash
# Check running containers
ssh root@192.168.155.128 "pct exec 108 -- docker ps"

# Restart portfolio web server
ssh root@192.168.155.128 "pct exec 108 -- docker restart my-custom-website"

# Restart Cloudflare tunnel
ssh root@192.168.155.128 "pct exec 108 -- docker restart cf-tunnel"
```

---

## 12. Repository Structure

```
├── Jenkinsfile                             # Multi-stage CI/CD pipeline definition
├── README.md                               # Comprehensive hybrid architecture documentation
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
├── gitops/                                 # Declarative Argo CD GitOps definitions
│   ├── root-infrastructure.yaml            # Master App-of-Apps root definition
│   ├── apps/                               # Child Application definitions (01 to 07)
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

- **Architect & Homelab Administrator**: **Abhishek Mishra** ([@ABHISHEK-CLOUD1](https://github.com/ABHISHEK-CLOUD1))
- **Autonomous Control Plane**: **Google Antigravity**
