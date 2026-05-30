 Cloud-Native Bare-Metal Cluster Lifecycle Architecture via IaC

An enterprise-grade Infrastructure as Code (IaC) implementation designed to automate, govern, and lifecycle-manage a high-availability, 6-node multi-master compute pool across a 3-node physical hypervisor footprint. This repository handles the core infrastructure bootstrap layer, providing a deterministic hardware baseline to sustain a zero-trust, automated GitOps Kubernetes platform.

---

Virtual Infrastructure & Hypervisor Mapping

The table below details the declarative allocation of physical resources across the bare-metal virtualization hosts, enforcing rigid disk arrays, unique hardware MAC boundaries, and layer-2 hypervisor firewall states.

  Virtual Infrastructure Map

* pve01 (Proxmox Host 1)
    * `cp-01` (Control Plane Node): 2 vCPUs (Host-Passthrough), 7GB ECC RAM, 32GB VirtIO Boot Storage.
    * `wk-01` (Worker Compute Node): 2 vCPUs (Host-Passthrough), 12GB ECC RAM, 32GB Boot Disk + 100GB Dedicated Storage Disk.
* pve02 (Proxmox Host 2)
    * `cp-02` (Control Plane Node): 2 vCPUs (Host-Passthrough), 7GB ECC RAM, 32GB VirtIO Boot Storage, Layer-2 Edge Firewall Active.
    * `wk-02` (Worker Compute Node): 2 vCPUs (Host-Passthrough), 12GB ECC RAM, 32GB Boot Disk + 100GB Dedicated Storage Disk, Layer-2 Edge Firewall Active.
* pve03 (Proxmox Host 3)
    * `cp-03` (Control Plane Node): 2 vCPUs (Host-Passthrough), 7GB ECC RAM, 32GB VirtIO Boot Storage.
    * `wk-03` (Worker Compute Node): 2 vCPUs (Host-Passthrough), 12GB ECC RAM, 32GB Boot Disk + 100GB Dedicated Storage Disk.
---

  Infrastructure Core Automation Stack

  IaC & State Governance

* Core Provisioning Engine: Terraform (HashiCorp Configuration Language - HCL)
* Target Environment REST API: Proxmox VE Integration via the `bpg/proxmox` provider engine
* Secrets Isolation & Decoupling: Dynamic local credentials mapping utilizing un-tracked variable injection rules (`terraform.tfvars`) coupled with strict `.gitignore` tracking boundaries.
* Advanced State Management: Native state ingestion logic utilizing specific state-import blocks to align live hypervisor runtime profiles without causing system reboots or service disruption.

---

Downstream Cloud-Native Platform Architecture

The compute resources provisioned by this infrastructure layer power a highly resilient, multi-master Kubernetes cluster (v1.35) bootstrapped via kubeadm. It is intentionally scaled to support heavy, stateful enterprise workloads such as self-hosted VCS (Gitea) and private cloud storage (Nextcloud).

The live platform architecture is segmented into the following dedicated operational domains:

Networking & Edge Load Balancing: Cilium CNI featuring an eBPF-driven network data plane, MetalLB for Layer-4 load balancing, and Kube-VIP providing a highly available virtual floating master IP.

Persistent Distributed Storage: Longhorn engine configured with automated multi-replica synchronous mirroring, providing high-performance Persistent Volume Claims (PVCs) directly to worker nodes for stateful applications.

Zero-Trust Security & Identity: HashiCorp Vault driving the encryption backend, integrated with the External Secrets Operator (ESO) to natively sync values into Kubernetes without exposing clear-text strings. Cert-Manager automates TLS provisioning via Cloudflare DNS-01 challenges.

Continuous Delivery & Observability: ArgoCD managing continuous deployment directly from a local Gitea instance. Full telemetry pipelines feature Prometheus monitoring, Grafana metrics visualization, and Loki log gathering.

Companion Repository Link: The manifest layouts driven by this infrastructure layer are located in the dedicated GitOps repository here: K8s-HomeLab-Gitops
