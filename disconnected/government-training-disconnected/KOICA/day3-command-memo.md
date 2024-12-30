# day3

## pacemaker dashboard

```bash
node1# ss -antp | grep 2224
bare# firefox https://192.168.90.110:2224

```
## storage

install the targetd server for iSCSI service

```bash
# dnf install epel-release
# dnf search targetd
# dnf install targetd 
# systemctl enable --now targetd
# systemctl status targetd    ## if the services show "error" ignore it.
```

install target client tool

```bash
# dnf install targetcli -y
# targetcli ls /
```

```bash
node1# firewall-cmd --add-service=iscsi-target
node1# mkdir -p /var/lib/iscsi_disks
node1# targetcli backstores/fileio create iscsi /var/lib/iscsi_disks/iscsi_disk.img 2G
node1# targetcli ls /
```



```bash

node1# targetcli iscsi/ create iqn.2023-02.com.example:blocks
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/luns/ create /backstores/fileio/iscsi/

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example.com:node1.init
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example.com:node2.init
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example.com:node3.init


node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example.com:node1.init set auth userid=username
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example.com:node1.init set auth password=username

```



# iscsi



About ISCSI for understanding what is diffrent between target(iscsi) and HBA(Dell and EMC).

https://www.ibm.com/docs/en/spectrumvirtualsoftw/8.2.x?topic=planning-iscsi-overview

https://github.com/open-iscsi/open-iscsi



## Cluster Does Not Form
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/cluster_administration/s1-cluster-noform-ca


## Fencing Occurs at Random
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/cluster_administration/s1-randomfence-ca



## Debug Resource Manager

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/cluster_administration/s2-clustcrash-gdb


## RHCS v2 cluster.conf

https://www.alteeve.com/w/RHCS_v2_cluster.conf#two_node

>two_node
>
>This allows you to configure a cluster with only two nodes. Normally, the loss of quorum after one of two nodes fails prevents the remaining node from continuing (if both nodes have one vote.). The default is '0'. To enable a two-node cluster, set this to '1'. If this is enabled, you must also set 'expected_votes' to '1'.
>
>    Default is 0 (disabled)
>    Must be set to 0 or 1 
