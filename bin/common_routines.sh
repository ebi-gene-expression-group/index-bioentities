require_env_var() {
  if [[ -z ${!1} ]]
  then
    echo "$1 env var is needed." && exit 1
  fi
}

get_host_from_hostport() {
  echo $(echo $1 | awk -F':' '{ print $1 }')
}

get_port_from_hostport() {
  echo $(echo $1 | awk -F':' '{ print $2 }')
}

# ----------------------------
# Pretty logging & output
# ----------------------------
# Enable colors only when stdout is a TTY, TERM isn't dumb, and NO_COLOR is not set
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ -z "${NO_COLOR:-}" ]; then
  COLORS_ENABLED=1
else
  COLORS_ENABLED=0
fi

if [ "$COLORS_ENABLED" -eq 1 ]; then
  RESET="\033[0m"; BOLD="\033[1m"; BLUE="\033[34m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"
else
  RESET=""; BOLD=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

info()    { printf "%b%s%b\n" "$BLUE$BOLD" "==> $1" "$RESET"; }
success() { printf "%b%s%b\n" "$GREEN" "✔ $1" "$RESET"; }
warn()    { printf "%b%s%b\n" "$YELLOW" "! $1" "$RESET"; }
error()   { printf "%b%s%b\n" "$RED" "✖ $1" "$RESET"; }

function _trap_DEBUG() {
    echo "# $BASH_COMMAND";
    while read -r -e -p "debug> " _command; do
        if [ -n "$_command" ]; then
            eval "$_command";
        else
            break;
        fi;
    done
}

# trap '_trap_DEBUG' DEBUG