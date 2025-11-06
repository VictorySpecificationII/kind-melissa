# KinD-melissa

You can either read it as the greek word for bee, or the name.

This repository houses an implementation for a Kubernetes-in-Docker HA cluster. 
You can use this to spin up and tear down a quick cluster for learning and development.
It comes bundled with `kube-metrics` so you can have basic observability for your cluster.

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


## Usage
 - Run `chmod +x spin_up.sh`
 - Run `chmod +x tear_down.sh`
 - To spin up, run `./spin_up.sh`
 - To tear down, run `./tear_down.sh`
 - To view cluster load, run `kubectl top node`

## Cool Stuff to experiment with

 - https://github.com/run-ai/fake-gpu-operator | Emulating GPU clusters without physical hardware
 - https://github.com/canonical/microceph | HPC storage supporting block, file and S3
 - https://slurm.schedmd.com/slinky.html | SLURM on Kubernetes
