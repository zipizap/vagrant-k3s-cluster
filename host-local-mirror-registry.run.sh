docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name=host-local-mirror-registry \
  -e REGISTRY_PROXY_REMOTEURL="https://registry-1.docker.io" \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true  \
  registry:2

docker logs host-local-mirror-registry -f



# Now in every master-node and worker-node of k3s, put the file /etc/rancher/k3s/registries.yaml with:
# --- begin file ---
# mirrors:
#   docker.io:
#     endpoint:
#       - "http://10.0.2.2:5000"
# configs:
#   "10.0.2.2:5000":
#     insecure_skip_verify: true
# --- end file ---
# and then: 
#systemctl restart k3s
#
# Test that all docker.io images are now being pull'ed-through our host-local-mirror-registry at http://10.0.2.2:5000
#crictl images | grep alpine
#kubectl run test -it --rm --image=alpine
#crictl images | grep alpine
#crictl rmi alpine
#crictl images | grep alpine


