#!/usr/bin/bash

###################################
# Script config Kubernetes
###################################

function main()
{
  echo "Begin setup Cluster ...";
  
  echo "Set up core user password";
  echo 'core:core' | chpasswd

  # openssl.cnf setup
  HOST_IP=${MASTERIP}
  K8S_IP=10.3.0.1

  # kubernetes workers setup
  WORKER_NUMBER=3
  WORKERS_FQDN=("worker1.ellesmera.intranet" "worker2.ellesmera.intranet" "worker3.ellesmera.intranet")
  WORKERS_IP=("${WORKERIP1}" "${WORKERIP2}" "${WORKERIP3}")
  MASTER_IP=("${MASTERIP}")
  K8S_SERVICE_IP=10.3.0.1

  # kubernetes master setup
  ADV_IP=${MASTERIP}
  # Etcd cluster member list
  ETCD_END=http://10.1.0.5:2379,http://10.1.0.6:2379,http://10.1.0.7:2379
  K8S=v1.5.1_coreos.0
  NETWORK=cni
  SERVICE_RANGE=10.3.0.0/24
  DNS_SERVICE=10.3.0.10

  # kubernetes certificates setup
  CA_CERT=/etc/kubernetes/ssl/ca.pem
  ADMIN_KEY=/etc/kubernetes/ssl/admin-key.pem
  ADMIN_CERT=/etc/kubernetes/ssl/admin.pem
  MASTER_HOST=${MASTERIP}

  create_ca

}
function create_ca()
{

  echo "Create a Cluster Root CA ...";

  if [ ! -f /etc/kubernetes/ssl/ca-key.pem ]; then
    openssl genrsa -out ca-key.pem 2048
    openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
  fi

  config_cluster

}

function config_cluster()
{

  echo "Set up Mater IP and K8S IP ...";

  eval sed -i -e "s#\\\${MASTER_IP}#"$HOST_IP"#g" openssl.cnf
  eval sed -i -e "s#\\\${K8S_SERVICE_IP}#"$K8S_IP"#g" openssl.cnf
  echo "Done.";

  create_keypair

}

function create_keypair()
{

  echo "Generate the API Server Keypair ...";

  if [ ! -f apiserver-key.pem -a ! -f apiserver.csr ]; then
   openssl genrsa -out apiserver-key.pem 2048
   openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
   openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
  fi
  echo "Done ...";

  create_worker

}

function create_worker()
{

  echo "Generate the Kubernetes Worker Keypairs ...";

  if [ ! -f /etc/kubernetes/ssl/worker*.pem -a ! -f /etc/kubernetes/ssl/worker*.csr ]; then
    echo "Generating TLS keys."
    openssl genrsa -out worker-key.pem 2048
    WORKER_IP="${MASTER_IP}" openssl req -new -key worker-key.pem -out worker.csr -subj "/CN=worker" -config worker-openssl.cnf
    WORKER_IP="${MASTER_IP}" openssl x509 -req -in worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf

    for ((i=0; i <= "$WORKER_NUMBER" - 1; i++));
    do
      echo "${WORKERS_IP[i]}" --- "${WORKERS_FQDN[i]}";
      openssl genrsa -out "${WORKERS_FQDN[i]}"-worker-key.pem 2048
      WORKER_IP="${WORKERS_IP[i]}" openssl req -new -key "${WORKERS_FQDN[i]}"-worker-key.pem -out "${WORKERS_FQDN[i]}"-worker.csr -subj "/CN="${WORKERS_FQDN[i]}"" -config worker-openssl.cnf
      WORKER_IP="${WORKERS_IP[i]}" openssl x509 -req -in "${WORKERS_FQDN[i]}"-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out "${WORKERS_FQDN[i]}"-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf
      sleep 2;
      tar cfv "${WORKERS_FQDN[i]}".tgz ca.pem "${WORKERS_FQDN[i]}"-worker-key.pem "${WORKERS_FQDN[i]}"-worker.pem
      tar tf "${WORKERS_FQDN[i]}".tgz
      scp "${WORKERS_FQDN[i]}".tgz core@"${WORKERS_FQDN[i]}":~/
    done
  fi

  create_adminkey

}

function create_adminkey()
{

  echo "Generate the Cluster Administrator Keypair ...";

  if [ ! -f admin-key.pem -a ! -f admin.csr ]; then
   openssl genrsa -out admin-key.pem
   openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
   openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365
  fi

  create_dirs

}

function create_dirs()
{

  echo "Creating directories structure ..."
  sh create_dirs

  kubernetes_setup

}

function kubernetes_setup()
{

  echo "Flannel Network Configuration ..."
  
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/flannel/options.env
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"$ETCD_END"#g' /etc/flannel/options.env

  echo "Create the kubelet Unit ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${DNS_SERVICE_IP}#"$DNS_SERVICE"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${K8S_VER}#"$K8S"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${NETWORK_PLUGIN}#"$NETWORK"#g' /etc/systemd/system/kubelet.service

  echo "Set Up the kube-apiserver Pod ..."
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"$ETCD_END"#g' /etc/kubernetes/manifests/kube-apiserver.yaml
  eval sed -i -e 's#\\\${SERVICE_IP_RANGE}#"$SERVICE_RANGE"#g' /etc/kubernetes/manifests/kube-apiserver.yaml
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/kubernetes/manifests/kube-apiserver.yaml

  echo "Set Up Calico Node Container (optional) ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/systemd/system/calico-node.service
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"$ETCD_END"#g' /etc/systemd/system/calico-node.service

  echo "Set Up the policy-controller Pod (optional) ..."
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"$ETCD_END"#g' /etc/kubernetes/manifests/policy-controller.yaml

  echo "Set Up the CNI config (optional) ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/kubernetes/cni/net.d/10-calico.conf
  eval sed -i -e 's#\\\$ETCD_ENDPOINTS#"$ETCD_END"#g' /etc/kubernetes/cni/net.d/10-calico.conf

  setup_certs

}

function setup_certs()
{

  echo "TLS Assets ...";
  chmod 600 /etc/kubernetes/ssl/*-key.pem
  chown root:root /etc/kubernetes/ssl/*-key.pem

  daemon_reload

}

function daemon_reload()
{

  echo "Saving settings ..."
  systemctl daemon-reload
  systemctl restart etcd2

}

function setup_kubectl()
{

  sh /opt/bin/kubernetes-install.sh
  sh /opt/bin/calico-install.sh

  /opt/bin/kubectl config set-cluster default-cluster --server=https://"${MASTER_HOST}" --certificate-authority="${CA_CERT}"
  /opt/bin/kubectl config set-credentials default-admin --certificate-authority="${CA_CERT}" --client-key="${ADMIN_KEY}" --client-certificate="${ADMIN_CERT}"
  /opt/bin/kubectl config set-context default-system --cluster=default-cluster --user=default-admin
  /opt/bin/kubectl config use-context default-system

  curl -H "Content-Type: application/json" -XPOST -d'{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"kube-system"}}' "http://127.0.0.1:8080/api/v1/namespaces"
  curl -H "Content-Type: application/json" -XPOST -d'{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"calico-system"}}' "http://127.0.0.1:8080/api/v1/namespaces"
}

############### Start Script ####################

$@
