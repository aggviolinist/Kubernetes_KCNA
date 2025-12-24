# Kubernetes_KCNA
Repo to practice as I prepare for the Kubernetes_KCNA
#0
Getting the short names of commands 
```sh
kubectl api-resources
```

## 1. Installing all the dependencies needed to run the Sinatra ruby app
```sh
bundle install
bundle add rackup puma
bundle exec ruby server.rb
```
## 2. Look at the webapp on the browser
```sh
curl localhost:4567
```
## 3. Buld the docker container
```sh
docker build . -t sinatra-webapp-sample
```

## 4. Deploy the docker file to ECR on AWS
- Create ECR on AWS using console
- Follow the upload instructions

## 5. Since we have Minikube already, we don't need to download it
When we want to move a file to be used universally in a linux system we use
```sh
sudo mv kubectl /usr/local/bin/
```

## 6. Start kubectl
```sh
minikube start
kubectl apply -f k8s/deployment.yml
kubectl get deployments
kubectl get pods
kubectl get services/svc
kubectl get pods -o wide
```

## 7. Forward our 4567 port to 8080
```sh
kubectl port-forward deployment/sinatra-webapp 8080:4567 --address 0.0.0.0
curl localhost:8080
```
## 8. Viewing our cluster on Kubernetes Dashboard
### a. Install the dashboard (if not yet done)
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```
### b. Create a ServiceAccount in the kubernetes-dashboard namespace
```sh
kubectl create serviceaccount dashboard-user -n kubernetes-dashboard
```
### c. Bind the ServiceAccount to cluster-admin role (for full access)
```sh
kubectl create clusterrolebinding dashboard-user-binding --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-user
```

### d. Generate the login token for the dashboard-user service account
```sh
kubectl -n kubernetes-dashboard create token dashboard-user
```

> Save the token output, this will be used to log in to the dashboard

### e. Port-forward the Kubernetes Dashboard service inside Codespaces to port 8443
```sh
kubectl -n kubernetes-dashboard port-forward service/kubernetes-dashboard 8443:443
```
> View port 8443 from terminal

### We can view the dashboard this way if we are using cloud 9

```sh
minikube start --listen-address='0.0.0.0'
kubectl proxy --address='0.0.0.0' --disable-filter=true
minikube dashboard --url
```

# Pods communicating with each other using BUSY BOX
## 9. Pod IP communication (Dynamic) 
Download busy box using the commands below
```sh
kubectl run -it --rm --restart=Never busybox --image=busybox -- sh
kubectl get pods - busy box is up and running
```
Inside busy box
```sh
kubectl get pods -o wide

kubectl run -it --rm --restart=Never busybox --image=busybox -- sh
wget 10.0.0.1:4567 -- Grab the IP address of the pod
cat index.html
```
## 10. Using ClusterIP to access cluster (static)
This is useful if we want to cummunicate with other clusters using a static IP address
```sh
kubectl apply -f k8s/service-clusterip.yml
kubectl get svc  -- our custom service is part of clusterIP
kubectl describe svc -- Grab the IP address on there
```
Running the cluster node inside busy box
```sh
kubectl get pods -o wide

kubectl run -it --rm --restart=Never busybox --image=busybox -- sh
wget 10.0.0.1:8080 -- Grab the IP address of our clusterIP
cat index.html
kubectl delete svc sinatra-webapp -- Delete our custom ClusterIP
```

## 11. Using Nodeport to access cluster (using port to connect to cluster)
This is useful when we want to access our cluster using our nodeport
```sh
kubectl apply -f k8s/service-nodeport.yml
kubectl get svc
kubectl describe svc
```
Running the nodeport
```sh
minikube service service-nodeport --url
curl http://192.x.x.2:30001
```
```sh
kubectl delete svc service-nodeport
kubectl delete -f deploy.yml #delete deployment
kubectl get svc
```

## 12. Connecting loadblancer to our cluster
Useful when we want to distribute traffic in our cluster
- Note the Loadbalancer we use is Network Loadbalancer(T3/TCP/UDP)
```sh
kubectl apply -f k8s/service-loadbalancer.yml
kubectl get svc
kubectl describe svc
```
Getting where our cluster is running at 
```sh
kubectl cluster-info
```

## 13. Debugging our DNS
> https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
```sh
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl get pods dnsutils
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
```
## 14. Ingress
> https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
We need to enable the ingress controller
```sh
minikube addons enable ingress
```
Verify that the NGINX Ingress controller is running
```sh
kubectl get pods -n ingress-nginx
```
Expose the port to the net
```sh
kubectl expose deployment sinatra-webapp --type=NodePort --port=8080
```
Check out the service
```sh
kubectl get service sinatra-webapp
```
Get the url
```sh
minikube service sinatra-webapp --url
```
Get info
```sh
curl http://172.17.0.15:31637 
```
Deploy the ingress
```sh
kubectl apply -f k8s/ingress.yaml
kubectl get ingress
```

## 15. Create jobs
> https://kubernetes.io/docs/reference/kubectl/quick-reference/
```sh
kubectl create job hello --image=busybox:1.28 -- echo "Learning k8s meehhnn"
```
> https://devhints.io/cron
Cron job that prints `hello` world every second
```sh
kubectl create cronjob hello --image=busybox:1.28   --schedule="*/1 * * * *" -- echo "Hello World"
```

## 16. Replicasets
We define them on our deployments. We also specify how many we want
```sh
replicas: 2
```
Confirming their implementation
```sh
kubectl get pods sinatra-webapp-f5b7cfff7-t5hz9
kubectl describe pods sinatra-webapp-f5b7cfff7-t5hz9
```
## 17. Scale
Scaling our replicas
```sh
kubectl scale --replicas=4 deploy/sinatra-webapp
```
Confirming our replicas
```sh
kubectl get deploy
kubectl get pods
kubectl describe svc sinatra-webapp
kubectl get svc sinatra-webapp
```
## 18. Auto Scaling (HPA)
We want to scale our deployments, remember we can't scale pods/svc's
```sh
kubectl autoscale deployment sinatra-webapp --cpu-percent=50 --min=3 --max=10
```
Confirming if our code works
```sh
kubectl get deploy
kubectl get pods
kubectl describe svc sinatra-webapp
kubectl get svc sinatra-webapp
```
> ![Alt text](images/hpa.png?raw=true "The hpa output")
## 19. Pods
Inspecting pods
 - desired state (.spec)
 - current observed state (.status)
```sh
kubectl get pods hello-pod -o yaml
kubectl get pods hello-pod -o wide   
```
```sh
kubectl describe pods hello-pod
kubectl describe pods <pod>
```
log-in to containers running in Pods
```sh
kubectl exec -it voting-app-deploy-777c699fdf-5xxtx -- sh
kubectl exec -it voting-app-deploy-777c699fdf-5xxtx -- bash
# apk add curl
# curl localhost:8080
```
trying to see if the front end is displaying manually
```sh
kubectl port-forward pod/voting-app-deploy-777c699fdf-5xxtx 8080:80
curl http://localhost:8080
```
```sh
kubectl logs <pod>
```
```sh
# exit
kubectl delete -f pod.yml
```
## 20. Deployment
```sh
kubectl describe deploy hello-deploy
kubectl get deploy hello-deploy
```
monitor the progress of the rolling update
```sh
kubectl rollout status deployment hello-deploy
kubectl rollout history deployment hello-deploy
kubectl get rs
```
## 21. Probes
Probe Types

> ![Alt text](images/probe_types.png?raw=true "The probe types")

Probe Applications


> ![Alt text](images/probe_app.png?raw=true "The probe applications")

## 22. Services
Creating services imperatively
```sh
kubectl expose deployment web-deploy \
--name=hello-svc \
--target-port=8080 \
--type=NodePort

service/hello-svc exposed
```
## 22. ConfigMap
Confirming if our configured to our pod
```sh
kubectl exec nameofpod -- env | grep NAME
kubectl exec nameofpod -- ls /etc/name
```



