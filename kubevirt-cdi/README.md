## kubevirt-cdi

In this lab, you will learn how to use Containerized Data Importer (CDI) to import Virtual Machine images for use with Kubevirt. 
CDI simplifies the process of importing data from various sources into Kubernetes Persistent Volumes, making it easier to use 
that data within your virtual machines.

### Install CDI

```
export VERSION=$(basename $(curl -s -w %{redirect_url} https://github.com/kubevirt/containerized-data-importer/releases/latest))
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
kubectl get cdi cdi -n cdi
```

### Import a CDI


```
cat <<EOF > dv_fedora.yml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "fedora"
spec:
  storage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi
  source:
    http:
      url: "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-AmazonEC2.x86_64-40-1.14.raw.xz"
EOF
```

Install the DataVolume using:

```
kubectl create -f dv_fedora.yml
```

### Create VM

```
wget https://kubevirt.io/labs/manifests/vm1_pvc.yml
cat vm1_pvc.yml
```

Create an SSH key and override the YAML definition so you can log in

```
ssh-keygen
PUBKEY=`cat ~/.ssh/id_rsa.pub`
sed -i "s%ssh-rsa.*%$PUBKEY%" vm1_pvc.yml
kubectl create -f vm1_pvc.yml
```


It'll take some time, wait for the VM to load.

```
kubectl get pod -o wide
```

Login to the VM

```
virtctl console vm1
```

### Expose VM so you can log in

You can do it via NodePort, or in our case, since we have a LoadBalancer:

```
virtctl expose vmi vm1   --name=vm1-ssh   --port=20222   --target-port=22   --type=LoadBalancer
kubectl get svc
```

### Log in

```
ssh -i ~/.ssh/id_rsa fedora@VM_IP -p 20222
```

It should you into the VM.
