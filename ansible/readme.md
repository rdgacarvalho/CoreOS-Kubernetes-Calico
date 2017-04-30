# Welcome to Ansible area

## Here you will find a playbooks to configure docker to use device mapper (LVM)

#### Remember to define your invetory into the host file of your ansible controller.

# Infrastructure:

* Docker Swarm

* 01 manager
* 03 workers


## 1 - Add a new hard disk (HD) on-the-fly to your servers on your cluster. After that just running the playbook from the manager.

## 2 - Before running your playbook against your infrastructure please validate it before. For example:


```
ansible-playbook -C docker-devicemapper.yml -v
```

## The command above you'll check all tasks inside "docker-devicemapper.yml" without execute any task in the server(s).

## 3 - Execute the playbook

```
# ansible-playbook docker-devicemapper.yml -v
```

## This playbook is compatible with any Linux flavor, so don't worries about you distro. 

Thank you!
