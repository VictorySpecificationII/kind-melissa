## http-test

This example application serves two purposes;

 - To show you how you can access an application from the ingress controller.
 - To show you how you can observe the traffic flow in-cluster via the client pod and from the outside in via the browser.

Run:

```
kubectl apply -f namespace.yaml
kubectl apply -f http-server.yaml
kubectl apply -f http-server-svc.yaml
kubectl apply -f http-server-ingress.yaml
kubectl apply -f http-client.yaml
```

## Be a client from your browser
Run `kubectl get svc -A` and grab the `EXTERNAL IP` of the ingress controller.

In your `/etc/hosts` file, add it as <EXTERNAL_IP http-server.local>.

You can now navigate to it in your browser to see the page.


## Using the in-cluster client
Shell into the container to check that your client can receive from the server
```
kubectl exec -n http-test -it http-client -- sh
curl http://http-server.http-test.svc.cluster.local
exit
```


## Observe
You can now use Hubble to observe the traffic flows while you play around with either approach above; Open a terminal and run

```
hubble observe -P -n http-test
hubble observe -P -n http-test --protocol http
```
