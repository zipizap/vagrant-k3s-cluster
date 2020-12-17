
```
# terminal 1
vi Vagrantfile
  # MASTER_COUNT (>=1) and NODE_COUNT (>=1)
  # vb.cpus and vb.memory 

./k3s.create.sh && ./istio.install.sh

# terminal 2 (once k3s.source is updated by k3s.create.sh)
source k3s.source && k9s


# if its usefull
./istio.install.sh restoreSnapshotPreIstio_and_reinstall
./istio.install.sh uninstall


```
