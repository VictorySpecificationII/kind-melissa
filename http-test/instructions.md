Run:

```
kubectl apply -f namespace.yaml
kubectl apply -f http-server.yaml
kubectl apply -f http-server-svc.yaml
kubectl apply -f http-client.yaml
```

Shell into the container to check that your client can receive from the server
```
kubectl exec -n http-test -it http-client -- sh
curl http://http-server.http-test.svc.cluster.local
exit
```

You can now use Hubble to observe the traffic flows:

```
hubble observe -P -n http-test
hubble observe -P -n http-test --protocol http
```
