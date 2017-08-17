#!/bin/bash

#set -x

usage() {
        echo "Usage: $0 number_of_coreos_nodes $1 kubemaster/worker $3 end_ip_address"
        echo "Example: 3 worker 2"
}

if [ "$1" == "" -a "$2" == "" -a "$3" == "" ]; then
        usage
        exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "'$1' is not a number"
        usage
        exit 1
fi

if [ $2 != "kubemaster"  ||  $2 != "worker" ]; then
        echo "'$2' kubemaster/worker"
        usage
        exit 2
fi

if [ $3 <= "1" ]; then
        echo "'$3' IP Address starts in 2"
        usage
        exit 3
fi

LIBVIRT=/var/lib/libvirt/images/
LIBVIRT_PATH=/var/lib/libvirt/images/$2
GITHUB="https://github.com/rdgacarvalho/coreos"
GITPROJECT=coreos
CLUSTERTYPE=discovery_cluster
USER_DATA_TEMPLATE=/opt/$GITPROJECT/$CLUSTERTYPE/$2.yaml
ETCD_DISCOVERY=$(curl -s "https://discovery.etcd.io/new?size=$1")
CHANNEL=stable
RELEASE=current
RAM=1024
CPUs=1
IMG_NAME="coreos_${CHANNEL}_${RELEASE}_qemu_image.img"
IMG_DISK="coreos_production_qemu_image.img"

if [ ! -d /opt/$GITPROJECT ]; then
        echo "Clone CoreOS Project from GitHUB ..."
        git clone $GITHUB /opt/ || (echo "Can not clone $GITHUB project" && exit 1)
fi

if [ ! -d $LIBVIRT_PATH ]; then
        mkdir -p $LIBVIRT_PATH || (echo "Can not create $LIBVIRT_PATH directory" && exit 1)
fi

if [ ! -f /opt/$GITPROJECT/$CLUSTERTYPE/$2.yaml ]; then
        echo "$USER_DATA_TEMPLATE template doesn't exist"
        exit 1
fi

for SEQ in $(seq 1 $1); do
        COREOS_HOSTNAME="$2$SEQ"
        IP_ADDR=`seq 2 "$3"`

        if [ ! -d $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest ]; then
                echo "Creating Deploy Path ..."
                mkdir -p $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest || (echo "Can not create $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest directory" && exit 1)
        fi

        if [ ! -f $LIBVIRT/$IMG_DISK ]; then
                echo "Downloading CoreOS ISO ..."
                wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_qemu_image.img.bz2 -O - | bzcat > $LIBVIRT_PATH/$IMG_NAME || (rm -f $LIBVIRT_PATH/$IMG_NAME && echo "Failed to download image" && exit 1)
        fi

        if [ ! -f $LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2 ]; then
                echo "Creating CoreOS Disk ..."
                qemu-img create -f qcow2 -b $LIBVIRT/$IMG_DISK $LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2
        fi

        cp /opt/$GITPROJECT/$CLUSTERTYPE/$2.yaml $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest/user_data
        sed "s#%HOSTNAME%#$COREOS_HOSTNAME#g;s#%DISCOVERY%#$ETCD_DISCOVERY#g;s#%IP_ADDR%#$IP#g" $USER_DATA_TEMPLATE > $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest/user_data
        sleep 2

        virt-install --connect qemu:///system \
                     --import \
                     --name $COREOS_HOSTNAME \
                     --ram $RAM \
                     --vcpus $CPUs \
                     --os-type=linux \
                     --os-variant=virtio26 \
                     --disk path=$LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2,format=qcow2,bus=virtio \
                     --filesystem $LIBVIRT_PATH/$COREOS_HOSTNAME/,config-2,type=mount,mode=squash \
                     --network bridge=virbr0 \
                     --network bridge=virbr1 \
                     --network bridge=virbr2 \
                     --vnc \
                     --noautoconsole
done
