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

The compute resources provisioned by this infrastructure layer power a highly resilient, multi-master Kubernetes cluster (`v1.35`) bootstrapped via `kubeadm`. 

The live platform architecture is segmented into the following dedicated operational domains:

  Networking & Edge Load Balancing

* Container Network Interface (CNI): Cilium CNI featuring an eBPF-driven network data plane, high-performance packet routing, and built-in Hubble network telemetry.
* Layer-4 Service Load Balancing: MetalLB acting as an on-premise cloud load balancer to dynamically advertise external service IPs.
* Control Plane High Availability: Kube-VIP providing a highly available virtual floating master IP paired with Ingress-NGINX edge controllers.

  Persistent Distributed Storage

* Distributed Block Storage: Longhorn engine configured with automated multi-replica synchronous mirroring, providing high-performance Persistent Volume Claims (PVCs) directly to worker nodes.
* Local Storage Provisioner: Kubernetes Local Path Provisioner utilized for localized stateless application workloads.

  Zero-Trust Security & Identity

* Centralized Secrets Vaulting: HashiCorp Vault driving the encryption backend.
* Secrets Lifecycle Injection: External Secrets Operator (ESO) integration to natively sync Vault values into Kubernetes namespaces without ever exposing clear-text strings in version control.
* PKI Automation: Cert-Manager driving the automated provisioning and lifecycle tracking of TLS certificates.

  Continuous Delivery (GitOps) & Observability

* Declarative GitOps Engine: ArgoCD managing continuous deployment, dynamically reconciling repository manifests with active live cluster state.
* Full Observability Matrix: Complete telemetry pipelines featuring Prometheus Operator monitoring, Grafana metrics visualization, and Loki log gathering agents.

---

Companion Repository Link
The manifest layouts driven by this infrastructure layer are located in the dedicated GitOps repository here: [K8s-HomeLab-Gitops](https://github.com/taxayp1/K8s-HomeLab-Gitops)
