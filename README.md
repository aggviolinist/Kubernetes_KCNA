# Kubernetes_KCNA
Repo to practice as I prepare for the Kubernetes_KCNA

1. Installing all the dependencies needed to run the Sinatra ruby app
```sh
bundle install
bundle add rackup puma
bundle exec ruby server.rb
```
2. Look at the webapp on the browser
```sh
curl localhost:4567
```
3. Buld the docker container
```sh
docker build . -t sinatra-webapp-sample
```

4. Deploy the docker file to ECR on AWS
- Create ECR on AWS using console
- Follow the upload instructions

5. Since we have Minikube already, we don't need to download it
When we want to move a file to be used universally in a linux system we use
```sh
sudo mv kubectl /usr/local/bin/
```

6. Start kubectl
```sh
minikube start
kubectl apply -f k8s/deployment.yml
kubectl get deployments
kubectl get pods
```

7. Forward our 4567 port to 8080
```sh
kubectl port-forward deployment/sinatra-webapp 8080:4567 --address 0.0.0.0
curl localhost:8080
```
