# Kubernetes_KCNA
Repo to practice as I prepare for the Kubernetes_KCNA

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
## 9. Download busy box using
```sh
kubectl run -it --rm --restart=Never busybox --image=busybox -- sh
kubectl get pods - busy box is up and running
```
Inside busy box
```sh
kubectl get pods -o wide
wget 10.0.0.1:4567 -- Grab the IP address of the pod
cat index.html
```
## 10. Using ClusterIP to access cluster
This is useful if we want to cummunicate with other clusters using a static IP address
```sh
kubectl apply -f k8s/service-clusterip.yml
kubectl get svc  -- our custom service is part of clusterIP
kubectl describe svc -- Grab the IP address on there
```
Inside busy box
```sh
kubectl get pods -o wide
wget 10.0.0.1:8080 -- Grab the IP address of our clusterIP
cat index.html
kubectl delete svc sinatra-webapp -- Delete our custom ClusterIP
```
