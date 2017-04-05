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

After define your networking information like "IP Address and Hostnames", replace the variables inside kube-master-config.yaml and kubeconfig.sh file as show below.

## Step 1: Installing Kubernetes Master

##### Set up your hostname
```
hostname: "kubemaster"
```

##### Configure your SSH plublic key
```
ssh_authorized_keys:
  - ssh-rsa <your_ssh_key.pub>
```

##### Replace all IP address below for yours infrastructure
```  
MASTER_IP=192.168.1.20
K8S_IP=10.3.0.1
# kubernetes workers setup
WORKER_NUMBER=3
WORKERS_FQDN=("worker1.ellesmera.intranet" "worker2.ellesmera.intranet" "worker3.ellesmera.intranet")
WORKERS_IP=("192.168.1.5" "192.168.1.6" "192.168.1.7")
MASTER_IP=("192.168.1.20")
K8S_SERVICE_IP=10.3.0.1
```

###### Replace for your IP address to configure your etcd2 cluster
```
etcd2:
     name: master1
     initial-advertise-peer-urls: http://10.1.0.20:2380
     listen-peer-urls: http://10.1.0.20:2380
     listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     initial-cluster-token: cluster-ellesmera
     initial-cluster: worker1=http://10.1.0.5:2380,worker2=http://10.1.0.6:2380,master1=http://10.1.0.20:2380
     initial-cluster-state: new
```

##### Installing CoreOS Kubermaster 
```
core@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-master.yaml
```

Step 2: Installing Kubernetes Workers
```
coreos@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-worker.yaml

Repeat this step for each worker node of your CoreOS cluster. Remember to replace the "hostname", "ip address", 
```


## Authors

* **Rodrigo Andrade de Carvalho**
* **E-mail: rdgacarvalho@gmail.com**
* **Skype: rdgacarvalho**
