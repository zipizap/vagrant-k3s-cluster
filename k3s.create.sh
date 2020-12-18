#!/usr/bin/env bash
#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__dbg_on_off=on  # on off
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
function dbg { [[ "$__dbg_on_off" == "on" ]] || return; echo -e '\033[1;34m'"dbg $(date +%Y%m%d%H%M%S) ${BASH_LINENO[0]}\t: $@"'\033[0m';  }
exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
set -o errexit
  # NOTE: the "trap ... ERR" alreay stops execution at any error, even when above line is commente-out
set -o pipefail
set -o nounset
set -o xtrace
export PS4='\[\e[44m\]\[\e[1;30m\](${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+ ${FUNCNAME[0]}():}\[\e[m\]	'


assure_dot_ssh_keys_exist() {
  [[ -r ./.ssh/id_rsa ]] && return 1
  mkdir -p .ssh
  ssh-keygen -f ./.ssh/id_rsa -N ''
}

vagrant_up() {
  vagrant up
}

k3sKubeconfig_kubectl() {
  # Get kubectl
  if ! which kubectl 
  then
    curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o ./kubectl
    chmod +x ./kubectl
    alias kubectl="$PWD/kubectl"
  fi

  export KUBECONFIG=$PWD/k3s.kubeconfig.yaml
  rm -f "${KUBECONFIG}"
  vagrant ssh kubemaster1 -c "sudo cat /etc/rancher/k3s/k3s.yaml" > "${KUBECONFIG}"
  kubectl get nodes -o wide

}

launch_test_deployment() {
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/fr/examples/controllers/nginx-deployment.yaml
  kubectl get pods -o wide
}

helm_cleanup_repo_stable() {
  # Helm: add repo stable
  # Note: all charts in https://github.com/helm/charts/tree/master/stable
  if helm repo list | grep stable &>/dev/null
  then
    helm repo remove stable
  fi
  #helm repo add stable https://charts.helm.sh/stable &&\
  helm repo update
}

helm_install_my-docker-registry_using_PVClocalPath() {
  "${__dir}/helm.my-docker-registry.install.sh"
}

main() {
  ## USAGE:
  #
  ## For normal k3s:
  # ./k3s.create.sh
  #
  ## For istio:
  # export K3S_MASTER_ADDITIONAL_OPTS='--no-deploy=traefik'
  # ./k3s.create.sh && ./istio.install.sh

  cd "${__dir}"
  shw_info "== assure_dot_ssh_keys_exist =="
  assure_dot_ssh_keys_exist

  shw_info "== vagrant up =="
  vagrant_up

  k3sKubeconfig_kubectl
    # ATP: kubectl can be use

  helm_cleanup_repo_stable

  #shw_info "== Helm: my-docker-registry =="
  #helm_install_my-docker-registry_using_PVClocalPath 

  launch_test_deployment
  shw_info "== Execution completed successfully =="
}

main "${@}"

