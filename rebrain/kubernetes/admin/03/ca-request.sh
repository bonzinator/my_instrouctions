#!/bin/bash

cat <<EOF > server3.json
{
     "CN": "etcd-member-node3",
     "hosts": [
         "localhost", 
         "kube-v3a-2-3-wccya",
         "etcd.kube-system.svc.cluster.local",
         "etcd.kube-system",
         "etcd",
         "10.129.0.28",
         "127.0.0.1"
     ],
     "key": {
         "algo": "ecdsa",
         "size": 256
     }
 }
EOF