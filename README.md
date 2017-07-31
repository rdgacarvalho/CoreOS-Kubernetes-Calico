# What is CoreOS?

CoreOS is a Linux distribuiton dedicated to run docker containers, nowdays called Container Linux CoreOS was designed for painless management in large clusters.

Welcome to new era of containers applications.

# What is Kubernetes?

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

# Install CoreOS Linux Container (from strach)

After define your networking information like "IP Address and Hostnames", replace the variables inside cloud-kubernetes-master.yaml and kubeconfig.sh file as show below.

## Pay attention: All changes should be made into cloud-kubernetes-master.yaml file

## Installing Kubernetes Master

##### Step 1: Setup your hostname

```
hostname: "kubemaster"
```

##### Step 2: Configure your SSH plublic key
```
ssh_authorized_keys:
  - ssh-rsa <your_ssh_key.pub>
```

##### Step 3: Replace all IP address below for yours infrastructure

```  
MASTER_IP=192.168.1.20
K8S_IP=10.3.0.1
# kubernetes workers setup
WORKER_NUMBER=1
WORKERS_FQDN=("worker1.ellesmera.intranet" "worker2.ellesmera.intranet" "worker3.ellesmera.intranet")
WORKERS_IP=("192.168.1.5" "192.168.1.6" "192.168.1.7")
MASTER_IP=("192.168.1.20")
K8S_SERVICE_IP=10.3.0.1
```

###### Step 3: Replace for your IP address to configure your etcd2 cluster

```
etcd2:
     name: master1
     initial-advertise-peer-urls: http://10.1.0.20:2380
     listen-peer-urls: http://10.1.0.20:2380
     listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     initial-cluster-token: kube-cluster
     initial-cluster: master1=http://10.1.0.20:2380
     initial-cluster-state: new
```

##### Step 4: Installing CoreOS Kubermaster

```
core@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-master.yaml
```

## Installing Kubernetes Workers Nodes

##### Step 1: Set up your hostname

```
hostname: "worker1"
```

##### Step 2: Configure your SSH plublic key
```
ssh_authorized_keys:
  - ssh-rsa <your_ssh_key.pub>
```

##### Step 3: Replace all IP address below for yours infrastructure


## Installing Kubernetes Workers

> Repeat this step for each worker node of your CoreOS cluster. Remember to replace the "hostname" and "ip address" into cloud-kubernetes-worker.yml file before start the installation process.

## Defining your Etcd2 Cluster
```
  ADV_IP=192.168.1.5
  MASTER=192.168.1.20 
  ETCD_END=http://10.1.0.5:2379,http://10.1.0.6:2379,http://10.1.0.7:2379
  K8S=v1.6.1_coreos.0
  NETWORK=
  SERVICE_IP=10.3.0.0/24
  DNS_SERVICE=10.3.0.10
```

## Setup your Etcd2 Cluster (please respect your cluster size defined previously)

```
  etcd2:
     name: worker1
     initial-advertise-peer-urls: http://10.1.0.5:2380
     listen-peer-urls: http://10.1.0.5:2380
     listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
     initial-cluster-token: cluster-worker
     initial-cluster: worker1=http://10.1.0.5:2380,worker2=http://10.1.0.6:2380,worker3=http://10.1.0.7:2380
     initial-cluster-state: new
```

## Installing your Workers Node

```
coreos@localhost# coreos-install -d /dev/sda -c cloud-kubernetes-worker.yaml
```

## Author

* **Rodrigo Andrade de Carvalho**
* **E-mail: rdgacarvalho@gmail.com**
* **Skype: rdgacarvalho**
