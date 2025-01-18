# Define colors using tput for portability
color_yellow=$(tput setaf 3) # Yellow
color_red=$(tput setaf 1)    # Red
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
