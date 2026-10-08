# shellcheck shell=bash
# shellcheck disable=SC2329 # Invoked by ShellSpec through the sourced helper.

spec_helper_precheck() {
  : minimum_version "0.28.1"
}

spec_helper_loaded() {
  :
}

spec_helper_configure() {
  :
}

# shellcheck shell=bash
stub_portable_sed() {
  sed() {
    local expression
    local file
    [[ "$1" != -i ]] || shift
    [[ "$1" != -e ]] || shift
    expression=$1
    file=$2
    command sed -e "$expression" "$file" > "$file.tmp" && command mv "$file.tmp" "$file"
  }
}
