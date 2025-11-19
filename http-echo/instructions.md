# http-echo

The `http-echo` application let's you see the Load Balancer hand out addresses in action.
To test, apply the deployment by running `kubectl apply -f echo.yaml`.
You can then run `kubectl get svc` and grab the external IP of the `http-echo` service, then navigate to it from your browser.
