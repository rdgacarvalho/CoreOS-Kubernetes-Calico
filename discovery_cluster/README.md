# Install CoreOS Linux Container Static Cluster

After define your networking information like "IP Address and Hostnames", replace the variables inside kubemaster.yaml.

## Pay attention: All changes should be made into static_cluster/ files

## Installing Kubernetes Master - Static Cluster

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
WORKERS_FQDN=("worker1.ellesmera.com" "worker2.ellesmera.com" "worker3.ellesmera.com")
WORKERS_IP=("192.168.1.5" "192.168.1.6" "192.168.1.7")
MASTER_IP=("192.168.1.20")
K8S_SERVICE_IP=10.3.0.1
```

##### Step 4: Replace for your IP address to configure your etcd2 cluster

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

##### Step 5: Installing CoreOS Kubermaster

```
core@localhost# coreos-install -d /dev/sda -c kubemaster.yaml
```

##### Step 6: Install and Configure Kubernetes Components

Access your kubemaster server using a ssh client and execute the following command:

```
core@localhost# cd /etc/kubernetes/ssl/ ; sudo bash kubeconfig.sh setupkube
```

#### Step 7: Starting Services

```
core@localhost# sudo systemctl restart etcd2 kubelet
```

#### Step 8: Checking Services

```
core@localhost# systemctl status etcd2 kubelet
```

#### Step 9: Checking Kubernetes Cluster

```
core@localhost# kubectl get nodes
```

## Installing Kubernetes Workers Nodes - Static Cluster

## Pay attention: All changes should be made into static_cluster/ files

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

> Repeat these steps for each worker node of your CoreOS cluster. Remember to replace the "hostname" and "ip address" into workers.yml file before start the installation process.

#### Defining your Etcd2 Cluster
```
  ADV_IP=192.168.1.5
  MASTER=192.168.1.20 
  ETCD_END=http://10.1.0.5:2379,http://10.1.0.6:2379,http://10.1.0.7:2379
  K8S=v1.6.1_coreos.0
  NETWORK=""
  SERVICE_IP=10.3.0.0/24
  DNS_SERVICE=10.3.0.10
```

#### Step 4: Setup your Etcd2 Cluster (please respect your cluster size defined previously)

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

#### Step 5: Installing your Workers Node

```
coreos@localhost# coreos-install -d /dev/sda -c workers.yaml
```

##### Step 6: Install and Configure Kubernetes Components

Access your kubemaster server via ssh client and execute the follow command:

```
core@localhost# cd /etc/kubernetes/ssl/ ; sudo bash kubeconfig.sh main
```

#### Step 7: Check your environment

```
core@localhost# sudo systemctl restart etcd2 kubelet
```
#### Step 8: Checking Services

```
core@localhost# systemctl status etcd2 kubelet
```
