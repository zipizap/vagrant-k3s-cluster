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

main() {
  cd "${__dir}"
  assure_dot_ssh_keys_exist

  vagrant_up

  k3sKubeconfig_kubectl
    # ATP: kubectl can be use

  launch_test_deployment
  shw_info "== Execution completed successfully =="
}

main "${@}"

