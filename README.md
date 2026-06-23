# KinD-melissa

You can either read it as the greek word for bee, or the name.

This repository implements a reproducible Kubernetes-in-Docker cluster designed to act as a mini HPC and platform experimentation environment. It allows rapid spin-up and tear-down of a full infrastructure stack locally, enabling safe experimentation with orchestration, networking, storage, observability, and compute workloads.

Unlike a default KinD cluster, this environment intentionally replaces and extends core Kubernetes components to more closely resemble production infrastructure.

It disables the native CNI and replaces it with `Cilium` and `Hubble` for eBPF-based networking and observability, uses `MetalLB` for L2 LoadBalancer functionality, and deploys `NGINX` for ingress control. `KubeVirt` is installed to allow virtual machines to run alongside containers, enabling hybrid workload experimentation. The cluster includes `metrics-server` to provide baseline telemetry.

This particular implementation is meant to act as a mini HPC and platform engineering environment, supporting experimentation across the full infrastructure stack.

Following this guide, you will set up:

- **Infrastructure layer** — Kubernetes control plane and worker nodes  
- **Compute layer** — container workloads and virtual machines (KubeVirt, SLURM experimentation)  
- **Networking layer** — Cilium CNI, Hubble observability, MetalLB LoadBalancer, ingress routing  
- **Storage layer** — designed for integration with BeeGFS and Ceph (RBD, CephFS, RGW modes)  
- **Management layer** — kubectl, hubble, cilium CLI, and platform tooling  

By the end of this process, you will have a fully reproducible mini HPC and platform infrastructure environment running locally.

---

## Purpose

This environment exists to provide a safe, reproducible platform for infrastructure experimentation, validation, and learning.

It enables:

- Testing infrastructure configurations before production deployment  
- Experimenting with Kubernetes networking and observability  
- Running hybrid VM and container workloads  
- Evaluating distributed storage integration patterns  
- Understanding cluster behavior under different orchestration scenarios  

The cluster lifecycle is fully automated, allowing rapid creation, teardown, and iteration.

---

## Prerequisites

For this to work, you need `kind` and `kubectl`. Follow the instructions to install them on your operating system.

### KinD
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Helm

Placeholder for the procedure, you can get by using:
```
sudo snap install helm --classic
```

## Usage

For a HA cluster, you are going to hit inotify limits. Before running anything, run:

```
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

It won't survive a reboot, bear in mind.

For it to do, run:

```
echo -e "fs.inotify.max_user_watches = 524288\nfs.inotify.max_user_instances = 512" | sudo tee /etc/sysctl.d/99-kind-inotify.conf
sudo sysctl --system
```


Now run:

 - Run `chmod +x spin_up.sh`
 - Run `chmod +x tear_down.sh`
 - To spin up, run `./spin_up.sh`
 - To tear down, run `./tear_down.sh`
 - To view cluster load, run `kubectl top node`

## Install Cilium

Once your cluster is online, install Cilium
```
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.18.4 --namespace kube-system --set image.pullPolicy=IfNotPresent --set ipam.mode=kubernetes
```

Now you can go ahead and test it works by deploying some pods.
```
kubectl create ns cilium-test
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/1.18.4/examples/kubernetes/connectivity-check/connectivity-check.yaml
```


Give it a minute or two, then
```
kubectl get pods -n cilium-test
```
should show all the pods running. You know Cilium is working in your cluster.

You can go ahead and delete the namespace.
```
kubectl delete ns cilium-test
```

## Install Cilium CLI

Copy and paste the following into your terminal:

```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

Once it's installed, run `cilium status` to see the status of your CNI.

## Install Hubble

You can install Hubble via the Helm chart:
```
helm upgrade cilium cilium/cilium --version 1.18.4 --namespace kube-system --reuse-values --set hubble.relay.enabled=true
```

You can run `cilium status` to see the Hubble status: It should say `OK`.

## Install Hubble CLI

Run the following sequence in your terminal:

```
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

```

You can verify your Hubble installation by running `hubble status -P`. You can observe the flow by querying the API with `hubble observe -P`.

## Install MetalLB

First, install it
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
```

Then, apply the IP address pool by running `kubectl apply -f iprange.yaml` inside the `metallb` directory.

## Install NGINX Ingress Controller

Install it using the following command:
```
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

You can then see the Ingress Controller grab a LoadBalancer address from `MetalLB` by running `kubectl get svc -A` and inspecting the
`EXTERNAL IP` field.

## Install KubeVirt

KubeVirt allows you to launch Virtual Machines on Kubernetes.

Install the CRD's using:

```
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml"
```

Then install KubeVirt using:

```
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
```

If the deployment doesn't come up and the handler pods complain about `too many open files`, increase the number on the host:

```
echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf
echo "fs.inotify.max_user_instances = 8192" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Install KubeVirt CLI

Install using:
```
VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
ARCH="$(uname -s | tr 'A-Z' 'a-z')-$(uname -m | sed 's/x86_64/amd64/')"
URL="https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}"
curl -L -o virtctl "$URL"
chmod +x virtctl
sudo mv virtctl /usr/local/bin/
virtctl version
```

## Example applications

In the `http-echo` and `http-test` directories, you can find example applications to run. Their respective READMEs will help guide you.

## Cool Stuff to experiment with

 - https://github.com/run-ai/fake-gpu-operator | Emulating GPU clusters without physical hardware
 - https://github.com/canonical/microceph | HPC storage supporting block, file and S3
 - https://github.com/SlinkyProject/slurm-operator | SLURM on Kubernetes
