require_env_var() {
  if [[ -z ${!1} ]]
  then
    echo "$1 env var is needed." && exit 1
  fi
}
