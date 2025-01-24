# Define colors using tput for portability
color_yellow=$(tput setaf 3) # Yellow
color_red=$(tput setaf 1) # Red
color_green=$(tput setaf 2)  # Green
color_bold=$(tput bold)          # Bold font
color_normal=$(printf '\e[22m')  # Disable bold only
color_reset=$(tput sgr0)     # Reset formatting

log_msg() {
  echo "$1${color_bold}[$2]${color_normal} $3${color_reset}" >&2
}
log_info() {
  log_msg "${color_yellow}" "INFO" "$*"
}
log_fail() {
  log_msg "${color_red}" "FAIL" "$*"
}

confirm() {
  local question="$1"
  local response

  while true; do
    read -r "?${color_green}${question} (yes/no):${color_reset} " response
    case "$response" in
      [Yy][Ee][Ss]|[Yy]) return 0 ;;  # Return 0 for yes
      [Nn][Oo]|[Nn]) return 1 ;;      # Return 1 for no
      *) log_fail "Please answer yes or no." ;;
    esac
  done
}

read_match() {
  local question="$1"
  local regex="$2"
  local result="$3"
  local response

  while true; do
    read "?${color_green}${question}${color_reset}: " response
    if [[ $response =~ $regex ]]; then
      typeset -g "$result"="$response"
      return 0
    else
      log_fail "does not match the regular expression ${regex}"
    fi
  done
}
