swap off and edit fstab to put # in last line for persistent 


1) sudo swapoff -a

2) sudo vim /etc/fstab


enable ip forwarding 


3) cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-iptables  = 1
   net.bridge.bridge-nf-call-ip6tables = 1
   net.ipv4.ip_forward                 = 1
   EOF

Apply the changes

4) sudo sysctl --system



overlay and netfilter setting

5) cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
   overlay
   br_netfilter
   EOF

6) sudo modprobe overlay
   sudo modprobe br_netfilter


install container runtime

7) sudo apt install containerd

8) sudo mkdir -p /etc/containerd/

generate default config

9) sudo containerd config default | sudo tee /etc/containerd/config.toml

edit dafult config and put true front of system cgroup option

10) sudo vim /etc/containerd/config.toml

restart the containerd service

11) sudo systemctl restart containerd



12) sudo apt-get update
 
apt-transport-https may be a dummy package; if so, you can skip that package

13) sudo apt-get install -y apt-transport-https ca-certificates curl gpg


download public signing key for repo and particular version

14) curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


15) echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


install kubeadm kubelet and kubectl

16) sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl



17) sudo systemctl enable --now kubelet



for HA multi master controlplane need to install kube-vip for single floating ip between 3 controlplane

export VIP=192.168.0.210   >> single floating ip 
export INTERFACE=enp6s18   >> proxmox vm interface
export KVVERSION=v1.1.2

sudo mkdir -p /etc/kubernetes/manifests

sudo ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION
sudo ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip manifest pod \
    --arp \
    --controlplane \
    --address $VIP \
    --interface $INTERFACE \
    --enableLoadBalancer \
    --leaderElection | sudo tee /etc/kubernetes/manifests/kube-vip.yaml



ONLY ON FIRST CONTROLPLANE (FIRST INIT NODE)

command pre-kubeadm:

sed -i 's#path: /etc/kubernetes/admin.conf#path: /etc/kubernetes/super-admin.conf#' \
          /etc/kubernetes/manifests/kube-vip.yaml


command post-kubeadm (Edit note: this causes a pod restart and may cause flaky behavior):

sed -i 's#path: /etc/kubernetes/super-admin.conf#path: /etc/kubernetes/admin.conf#' \
          /etc/kubernetes/manifests/kube-vip.yaml



Cloud Provider Config >> good for loadbalancer service so it can get ip from range config if want



kubeadm init \
  --control-plane-endpoint "192.168.0.210:6443" \
  --upload-certs \
  --pod-network-cidr=10.244.0.0/16

remove kubeproxy daemon set before cilium 

helm install cilium cilium/cilium --version 1.15.6 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=192.168.0.210 \
  --set k8sServicePort=6443 \
  --set operator.replicas=1



For ControlPlane Nodes>>

  kubeadm join 192.168.0.210:6443 --token  \
        --discovery-token-ca-cert-hash sha256 \
        --control-plane --certificate-key 


For Workers Nodes>>>

kubeadm join 192.168.0.210:6443 --token \
        --discovery-token-ca-cert-hash sha256:






After setup


alias k='kubectl'

source ~/.bashrc

sudo apt install bash-completion -y

source <(kubectl completion bash)
complete -F __start_kubectl k

source ~/.bashrc




Apply these fixes on the base Ubuntu operating system layer right after cloning the VM from Proxmox to prevent hardware network hangs under load.


Add to the bottom of your physical 'iface' section

post-up /usr/sbin/ethtool -K $IFACE tso off gso off gro off tx off rx off
post-up /usr/sbin/ethtool -K $IFACE sg off rxvlan off txvlan off



1. Edit the file
nano /etc/default/grub

2. Update this line
GRUB_CMDLINE_LINUX_DEFAULT="quiet pcie_aspm=off e1000e.IntMode=1 e1000e.InterruptThrottleRate=4,4 intel_idle.max_cstate=1"

3. Apply changes
update-grub
reboot


----------------------------------------------------------------------------------------------------