#!/usr/bin/bash

###################################
# Script configuracao Kubernetes
###################################

function main()
{
  echo "Begin Setup"
  echo 'core:core' | chpasswd

  create_dirs

}
function create_dirs()
{

  # Automated creatre directories
  sh create_dirs

  kubernetes_setup

}

function kubernetes_setup()
{

  ADV_IP=192.168.1.5
  MASTER=192.168.1.20
  ETCD_END=http://10.1.0.5:2379,http://10.1.0.6:2379,http://10.1.0.7:2379,http://10.1.0.20:2379
  K8S=v1.5.1_coreos.0
  NETWORK="cni"
  SERVICE_IP=10.3.0.0/24
  DNS_SERVICE=10.3.0.10

  echo "Flannel Network Configuration ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/flannel/options.env
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"$ETCD_END"#g' /etc/flannel/options.env

  echo "Create the kubelet Unit ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"$ADV_IP"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${MASTER_HOST}#"$MASTER"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${DNS_SERVICE_IP}#"$DNS_SERVICE"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${K8S_VER}#"$K8S"#g' /etc/systemd/system/kubelet.service
  eval sed -i -e 's#\\\${NETWORK_PLUGIN}#"$NETWORK"#g' /etc/systemd/system/kubelet.service

  eval sed -i -e 's#\\\${ADVERTISE_IP}#"${ADV_IP}"#g' /etc/kubernetes/cni/net.d/10-calico.conf
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"${ETCD_END}"#g' /etc/kubernetes/cni/net.d/10-calico.conf
  eval sed -i -e 's#\\\${MASTER_HOST}#"${MASTER}"#g' /etc/kubernetes/cni/net.d/10-calico.conf

  echo "Set Up the kube-apiserver Pod ..."
  eval sed -i -e 's#\\\${MASTER_HOST}#"$MASTER"#g' /etc/kubernetes/manifests/kube-proxy.yaml

  echo "Set Up Calico Node Container (optional) ..."
  eval sed -i -e 's#\\\${ADVERTISE_IP}#"${ADV_IP}"#g' /etc/systemd/system/calico-node.service
  eval sed -i -e 's#\\\${ETCD_ENDPOINTS}#"${ETCD_END}"#g' /etc/systemd/system/calico-node.service
  eval sed -i -e 's#\\\${MASTER_HOST}#"${MASTER}"#g' /etc/systemd/system/calico-node.service

  install_kubernets

}

function install_kubernets()
{
  sh kubernetes-install.sh
  sh calico-install.sh

  find ~core/ -type f -name '*.tgz' -exec sudo tar xfv {} \;

  chmod 600 /etc/kubernetes/ssl/*-key.pem
  chown root:root /etc/kubernetes/ssl/*-key.pem

  ln -s $(hostname)-worker.pem worker.pem
  ln -s $(hostname)-worker-key.pem worker-key.pem

  daemon_reload

}

function daemon_reload() {

  echo "Saving settings ..."
  eval systemctl daemon-reload

  echo "Starting services ...";

}

############### Start Script ####################
$@
