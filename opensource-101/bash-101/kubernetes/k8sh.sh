ct() {
  if [ -z "$1" ]; then
    local contexts=$(k config get-contexts -o=name | sort -n)
    echo "$contexts"
    return
  fi
  export KUBECTL_CONTEXT=$1
}
export -f ct

_ct_completions()
{
  local contexts=$(k config get-contexts -o=name | sort -n)
  COMPREPLY=($(compgen -W "${contexts}" "${COMP_WORDS[1]}"))
}
export -f _ct_completions

ns() {
  if [ -z "$1" ]; then
    local namespaces=$(k get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')
    echo "${namespaces}"
    return
  fi
  export KUBECTL_NAMESPACE=$1
}
export -f ns

_ns_completions()
{
  local namespaces=$(k get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')
  COMPREPLY=($(compgen -W "${namespaces}" "${COMP_WORDS[1]}"))
}
export -f _ns_completions

reloadExtensions() {
  if [ -e ~/.k8sh_extensions ]; then
    echo "Sourcing in ~/.k8sh_extensions..."
    source ~/.k8sh_extensions
  fi
}
export -f reloadExtensions

k8sh_init () {
  RED='\033[00;31m'
  GREEN='\033[00;32m'
  YELLOW='\033[00;33m'
  BLUE='\033[00;34m'
  PURPLE='\033[00;35m'
  CYAN='\033[00;36m'
  LIGHTGRAY='\033[00;37m'
  LRED='\033[01;31m'
  LGREEN='\033[01;32m'
  LYELLOW='\033[01;33m'
  LBLUE='\033[01;34m'
  LPURPLE='\033[01;35m'
  LCYAN='\033[01;36m'
  WHITE='\033[01;37m'
  RESTORE='\033[0m'
  PS_RED='\[\033[00;31m\]'
  PS_GREEN='\[\033[00;32m\]'
  PS_YELLOW='\[\033[00;33m\]'
  PS_BLUE='\[\033[00;34m\]'
  PS_PURPLE='\[\033[00;35m\]'
  PS_CYAN='\[\033[00;36m\]'
  PS_LIGHTGRAY='\[\033[00;37m\]'
  PS_LRED='\[\033[01;31m\]'
  PS_LGREEN='\[\033[01;32m\]'
  PS_LYELLOW='\[\033[01;33m\]'
  PS_LBLUE='\[\033[01;34m\]'
  PS_LPURPLE='\[\033[01;35m\]'
  PS_LCYAN='\[\033[01;36m\]'
  PS_WHITE='\[\033[01;37m\]'
  PS_RESTORE='\[\033[0m\]'
  CONTEXT_COLOR=$LRED
  PS_CONTEXT_COLOR=$PS_LRED
  NAMESPACE_COLOR=$LCYAN
  PS_NAMESPACE_COLOR=$PS_LCYAN

  echo ""
  echo -e "${LPURPLE}Welcome to k${LRED}8${LPURPLE}sh${RESTORE}"
  if [ -e ~/.bash_profile ]; then
    echo "Sourcing in ~/.bash_profile..."
    source ~/.bash_profile
  fi
  echo "Gathering current kubectl state..."
  export KUBECTL_CONTEXT=$(kubectl config current-context)
  export KUBECTL_NAMESPACE=${DEFAULT_NAMESPACE-default}

  echo "Making aliases..."
  alias kubectl="kubectl --context \$KUBECTL_CONTEXT --namespace \$KUBECTL_NAMESPACE"
  alias k="kubectl"

  # Common actions
  alias describe="k describe"
  alias get="k get"
  alias create="k create"
  alias apply="k apply"
  alias delete="k delete"
  alias scale="k scale"
  alias rollout="k rollout"
  alias logs="k logs"
  alias explain="k explain"

  alias pods="get pods"
  alias services="get svc"
  alias deployments="get deployments"
  alias dep="get deployments" # NON-STANDARD!!
  alias replicasets="get rs"
  alias replicationcontrollers="get rc"
  alias rc="get rc"
  alias nodes="get nodes"
  alias limitranges="get limitranges"
  alias limits="get limitranges"
  alias events="get events"
  alias persistentvolumes="get pv"
  alias pv="get pv"
  alias persistentvolumeclaims="get pvc"
  alias pvc="get pvc"
  alias namespaces="get ns"
  alias ingresses="get ing"
  alias ing="get ing"
  alias configmaps="get configmaps"
  alias secrets="get secrets"

  complete -F _ns_completions ns
  complete -F _ct_completions ct

  local bash_completion_present=$(type -t _get_comp_words_by_ref)

  if [[ ! -z "$bash_completion_present" ]]; then
    echo "Setting up k completion..."
    # without sourcing completion for `k` does not recognize __start_kubectl
    source <(kubectl completion bash)
    # make completion work for `k`
    complete -F __start_kubectl k
  else
      echo -e "${RED}For k completion please install bash-completion${RESTORE}"
  fi

 # Set up PS1 prompt
  export PS1="($PS_CONTEXT_COLOR\$KUBECTL_CONTEXT$PS_RESTORE/$PS_NAMESPACE_COLOR\$KUBECTL_NAMESPACE$PS_RESTORE) \W ${PS_LPURPLE}\$${PS_RESTORE} "

  reloadExtensions

  echo ""
  echo -e "Context: $CONTEXT_COLOR$KUBECTL_CONTEXT$RESTORE"
  echo -e "Namespace: $NAMESPACE_COLOR$KUBECTL_NAMESPACE$RESTORE"
}

export -f k8sh_init

echo "Initializing..."
export PS1="" # Clear PS1 for prettier init
bash -i <<< 'k8sh_init; exec </dev/tty'
