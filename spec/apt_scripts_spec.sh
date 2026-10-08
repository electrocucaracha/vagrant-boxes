#!/bin/bash
# shellcheck disable=SC2329,SC2034 # ShellSpec invokes command stubs dynamically.

Include scripts/ubuntu2204/apt.sh
Include scripts/ubuntu2404/apt.sh
Include scripts/ubuntu2604/apt.sh

Describe 'APT retry helpers'
  setup() {
    TEST_ROOT=$(mktemp -d)
  }

  cleanup() {
    command rm -rf "$TEST_ROOT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  run_apt2204_main() {
    local apt_root="$TEST_ROOT/apt2204"
    APT_ETC_ROOT="$apt_root/etc"
    APT_USR_LIB_ROOT="$apt_root/usr/lib"
    mkdir -p \
      "$APT_ETC_ROOT/update-manager" \
      "$APT_ETC_ROOT/apt/apt.conf.d" \
      "$APT_ETC_ROOT/default" \
      "$APT_ETC_ROOT/profile.d" \
      "$APT_ETC_ROOT/cron.d" \
      "$APT_USR_LIB_ROOT/ubuntu-release-upgrader"
    printf 'Prompt=normal\n' > "$APT_ETC_ROOT/update-manager/release-upgrades"
    printf 'APT::Periodic::Enable "1";\nAPT::Periodic::AutocleanInterval "1";\n' > "$APT_ETC_ROOT/apt/apt.conf.d/10periodic"
    : > "$APT_USR_LIB_ROOT/ubuntu-release-upgrader/release-upgrade-motd"
    : > "$APT_ETC_ROOT/apt/sources.list.curtin.old"
    printf 'ENABLED="false"\n' > "$APT_ETC_ROOT/default/sysstat"
    printf '127.0.0.1 localhost\n' > "$APT_ETC_ROOT/resolv.conf"
    sysctl() { printf 'sysctl:%s\n' "$*"; }
    dpkg() { return 0; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    apt-cache() { return 0; }
    systemctl() {
      case "$*" in
        '--quiet list-unit-files '* | '--quiet is-active '* | '--quiet is-enabled '*) return 0 ;;
        'is-enabled apt-news.service' | 'is-enabled apt-daily.service') printf 'masked\n' ;;
        'is-enabled packagekit.service' | 'is-enabled snapd.socket') printf 'disabled\n' ;;
        'is-enabled '* ) printf 'masked\n' ;;
        stop\ * | disable\ * | mask\ * | unmask\ * | enable\ * | start\ *) printf 'systemctl:%s\n' "$*" ;;
      esac
    }
    stub_portable_sed
    rm() {
      [[ "$1" != --force ]] || shift
      command rm -f "$@"
    }

    apt2204_main
    grep -q '^Prompt=never$' "$APT_ETC_ROOT/update-manager/release-upgrades" &&
      test ! -e "$APT_ETC_ROOT/apt/sources.list.curtin.old" &&
      grep -q 'APT::Periodic::Enable "0";' "$APT_ETC_ROOT/apt/apt.conf.d/10periodic" &&
      grep -q 'APT::Acquire::Retries "0";' "$APT_ETC_ROOT/apt/apt.conf.d/20retries" &&
      grep -q 'ENABLED="true"' "$APT_ETC_ROOT/default/sysstat" &&
      grep -q "alias vi=vim" "$APT_ETC_ROOT/profile.d/vim.sh" &&
      grep -q '@reboot root command bash' "$APT_ETC_ROOT/cron.d/mlocate"
  }

  retry_once() {
    local retry_function=$1
    TERM=xterm
    retry_attempts=0
    apt_step() {
      retry_attempts=$((retry_attempts + 1))
      [[ ${retry_attempts} -gt 1 ]]
    }
    which() { printf '/usr/bin/tput\n'; }
    tput() { printf 'tput:%s\n' "$*"; }
    sleep() { printf 'sleep:%s\n' "$1"; }
    "$retry_function" apt_step 2>&1
  }

  retry_exhaustion() {
    local retry_function=$1
    apt_step() { return 1; }
    which() { return 1; }
    sleep() { :; }
    "$retry_function" apt_step 2>&1
  }

  invoke_error_handler() {
    local error_function=$1
    exit() { return "$1"; }
    false
    "$error_function"
    local result=$?
    unset -f exit
    return "$result"
  }

  It 'retries package commands on Ubuntu 22.04'
    When call retry_once apt2204_retry
    The status should be success
    The output should include 'apt_step failed... retrying 2 of 10.'
    The output should include 'sleep:10'
    The output should include 'tput:setaf 1'
    The output should include 'tput:sgr0'
  End

  It 'stops after ten failures on Ubuntu 22.04'
    When call retry_exhaustion apt2204_retry
    The status should be failure
    The output should include 'The command failed 10 times.'
  End

  It 'reports an APT error on Ubuntu 22.04'
    When call invoke_error_handler apt2204_error
    The status should be failure
    The output should include 'APT failed... again.'
  End

  It 'retries package commands on Ubuntu 24.04'
    When call retry_once apt2404_retry
    The status should be success
    The output should include 'apt_step failed... retrying 2 of 10.'
    The output should include 'sleep:10'
  End

  It 'stops after ten failures on Ubuntu 24.04'
    When call retry_exhaustion apt2404_retry
    The status should be failure
    The output should include 'The command failed 10 times.'
  End

  It 'reports an APT error on Ubuntu 24.04'
    When call invoke_error_handler apt2404_error
    The status should be failure
    The output should include 'APT failed... again.'
  End

  It 'retries package commands on Ubuntu 26.04'
    When call retry_once apt2604_retry
    The status should be success
    The output should include 'apt_step failed... retrying 2 of 10.'
    The output should include 'sleep:10'
  End

  It 'stops after ten failures on Ubuntu 26.04'
    When call retry_exhaustion apt2604_retry
    The status should be failure
    The output should include 'The command failed 10 times.'
  End

  It 'reports an APT error on Ubuntu 26.04'
    When call invoke_error_handler apt2604_error
    The status should be failure
    The output should include 'APT failed... again.'
  End

  It 'runs Ubuntu 22.04 APT setup in an isolated temp root'
    When call run_apt2204_main
    The status should be success
    The output should include 'sysctl:net.ipv6.conf.all.disable_ipv6=1'
    The output should include 'apt-get:--assume-yes install vim'
    The output should include 'systemctl:mask apt-news.service'
    The output should include 'systemctl:enable sysstat.service'
  End
End