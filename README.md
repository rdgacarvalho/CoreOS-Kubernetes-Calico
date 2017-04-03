# CoreOS 
CoreOS is a Linux version dedicated to running docker containers, nowdays called Container Linux CoreOS was designed for painless management in large clusters.

Welcome to new era of containers applications.

# Kubernetes

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

# Why use Kubernetes?

* [Automatic binpacking]          
* [Self-healing]
* [Horizontal scaling]
* [Service discovery and load balancing]
* [Automated rollouts and rollbacks]
* [Secret and configuration management]
* [Storage orchestration]
* [Batch execution]

# Install CoreOS using YAML file
After define your networking information like "IP Address and Hostnames", replace the variables inside kubeconfig.sh script and kube-master-config.yaml file.

Step 1: Installing Kubernetes Master
```
core@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-master.yaml
```

Step 2: Installing Kubernetes Workers
```
coreos@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-worker.yaml

Repeat this step for each worker node of your CoreOS cluster. Remember to replace the "hostname", "ip address", 
```


## Authors

* **Rodrigo Andrade de Carvalho** - *Initial work*
