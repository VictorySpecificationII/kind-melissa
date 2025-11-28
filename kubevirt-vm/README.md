## kubevirt-vm

This tutorial shows you how to fire up a VM on Kubernetes. It requires `virtctl` to be installed.

### Download and deploy an example VM
```
wget https://kubevirt.io/labs/manifests/vm.yaml
less vm.yaml
kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml
kubectl get vms
kubectl get vms -o yaml testvm
```

### Start the VM
```
virtctl start testvm
```

### Get instances of VM's running
```
kubectl get vmis
kubectl get vmis -o yaml testvm
```

### Console into the VM
```
virtctl console testvm
```

Press `Ctrl + ]` to exit the console.


### Stop the VM
```
virtctl stop testvm
```

### Delete the VM
```
kubectl delete vm testvm
```
