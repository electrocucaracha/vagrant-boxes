#!/bin/bash
# shellcheck disable=SC2329,SC2034 # ShellSpec invokes helpers and shares globals dynamically.

Include scripts/common/lockout.sh
Include scripts/common/machine.sh
Include scripts/common/leases.sh
Include scripts/common/localtime.sh
Include scripts/common/keys.sh
Include scripts/common/motd.sh
Include scripts/common/zerodisk.sh
Include scripts/ubuntu2204/fixtty.sh
Include scripts/ubuntu2404/fixtty.sh
Include scripts/ubuntu2604/fixtty.sh
Include scripts/ubuntu2204/floppy.sh
Include scripts/ubuntu2404/floppy.sh
Include scripts/ubuntu2604/floppy.sh
Include scripts/ubuntu2204/profile.sh
Include scripts/ubuntu2404/profile.sh
Include scripts/ubuntu2604/profile.sh
Include scripts/ubuntu2204/vagrant.sh
Include scripts/ubuntu2404/vagrant.sh
Include scripts/ubuntu2604/vagrant.sh
Include scripts/ubuntu2204/motd.sh
Include scripts/ubuntu2404/motd.sh
Include scripts/ubuntu2604/motd.sh
Include scripts/ubuntu2204/network.sh
Include scripts/ubuntu2404/network.sh
Include scripts/ubuntu2604/network.sh
Include scripts/ubuntu2204/cleanup.sh
Include scripts/ubuntu2404/cleanup.sh
Include scripts/ubuntu2604/cleanup.sh

Describe 'common scripts'
  setup_zerodisk_commands() {
    df() {
      local mountpoint
      local available=${ROOT_AVAILABLE}
      for mountpoint in "$@"; do
        :;
      done
      [[ ${mountpoint} != "${BOOT_MOUNT_POINT}" ]] || available=${BOOT_AVAILABLE}
      printf 'Filesystem 1M-blocks Used Available Use%% Mounted on\n/dev/mock 100 20 %s 20%% %s\n' "$available" "$mountpoint"
    }
    dd() { printf '%s\n' "$*" >> "$DD_CALLS_FILE"; }
    sync() { :; }
    rm() {
      [[ "$1" != --force ]] || shift
      command rm -f "$@"
    }
  }

  run_zerodisk_with_dd_count() {
    zerodisk_main
    printf 'dd-count:%s\n' "$(wc -l < "$DD_CALLS_FILE" | tr -d '[:space:]')"
  }

  run_profile_variant() {
    local profile_func=$1
    local with_vagrant=${2:-false}
    local variant_root="$TEST_ROOT/${profile_func}"
    local current_dir=$PWD

    mkdir -p "$variant_root/root"
    : > "$variant_root/root/.bashrc"
    if [[ ${with_vagrant} == true ]]; then
      mkdir -p "$variant_root/vagrant"
      : > "$variant_root/vagrant/.bashrc"
    fi
    PROFILE_ROOT_HOME="$variant_root/root"
    PROFILE_VAGRANT_HOME="$variant_root/vagrant"
    patch() {
      command cat >/dev/null
    }
    chown() { printf 'chown:%s\n' "$*"; }

    "$profile_func"
    local result=$?
    cd "$current_dir" || return 1
    return "$result"
  }

  run_vagrant_variant() {
    local provisioner_func=$1
    local variant_root="$TEST_ROOT/${provisioner_func}"
    VAGRANT_USERADD_CMD=useradd
    VAGRANT_SUDOERS_FILE="$variant_root/sudoers/vagrant"
    VAGRANT_HOME_DIR="$variant_root/home/vagrant"
    VAGRANT_BUILD_TIME_FILE="$variant_root/vagrant_box_build_time"
    mkdir -p "$(dirname "$VAGRANT_SUDOERS_FILE")" "$VAGRANT_HOME_DIR"
    useradd() { printf 'useradd:%s\n' "$*"; }
    passwd() {
      local password_input
      password_input=$(command cat)
      printf 'passwd:%s:%s\n' "$*" "${password_input//$'\n'/,}"
    }
    chmod() { printf 'chmod:%s\n' "$*"; }
    chown() { printf 'chown:%s\n' "$*"; }
    date() { printf 'build-time\n'; }
    "$provisioner_func"
  }

  run_motd_variant() {
    local provisioner_func=$1
    local variant_root="$TEST_ROOT/${provisioner_func}"
    local pam_file

    MOTD_PAM_SSHD_FILE="$variant_root/pam/sshd"
    MOTD_PAM_LOGIN_FILE="$variant_root/pam/login"
    MOTD_ROOT_HOME="$variant_root/root"
    MOTD_VAGRANT_HOME="$variant_root/vagrant"
    MOTD_APT_NOTIFIER_FILE="$variant_root/apt/99update-notifier"
    MOTD_FILE="$variant_root/etc/motd"
    MOTD_NEWS_FILE="$variant_root/default/motd-news"
    mkdir -p "$(dirname "$MOTD_PAM_SSHD_FILE")" "$MOTD_ROOT_HOME" "$MOTD_VAGRANT_HOME" "$(dirname "$MOTD_APT_NOTIFIER_FILE")" "$(dirname "$MOTD_FILE")" "$(dirname "$MOTD_NEWS_FILE")"
    for pam_file in "$MOTD_PAM_SSHD_FILE" "$MOTD_PAM_LOGIN_FILE"; do
      printf 'motd=/run/motd.dynamic\npam_motd.so noupdate\n' > "$pam_file"
    done
    printf 'stale notifier\n' > "$MOTD_APT_NOTIFIER_FILE"
    printf 'stale message\n' > "$MOTD_FILE"
    printf 'ENABLE=1\n' > "$MOTD_NEWS_FILE"
    stub_portable_sed
    truncate() {
      [[ "$1" == --size=0 ]] || return 1
      : > "$2"
    }
    chown() { printf 'chown:%s\n' "$*"; }
    systemctl() {
      case "$*" in
        '--quiet is-active '* | '--quiet is-enabled '*) return 0 ;;
        'stop '* | 'disable '*) printf 'systemctl:%s\n' "$*" ;;
      esac
    }

    "$provisioner_func"
    for pam_file in "$MOTD_PAM_SSHD_FILE" "$MOTD_PAM_LOGIN_FILE"; do
      grep -q 'motd=/etc/motd' "$pam_file" || return 1
      grep -q '# pam_motd.so noupdate' "$pam_file" || return 1
    done
    test -f "$MOTD_ROOT_HOME/.cache/motd.legal-displayed" &&
      test -f "$MOTD_VAGRANT_HOME/.cache/motd.legal-displayed" &&
      test ! -s "$MOTD_APT_NOTIFIER_FILE" &&
      test ! -s "$MOTD_FILE" &&
      grep -q '^ENABLE=0$' "$MOTD_NEWS_FILE"
  }

  run_network_variant() {
    local provisioner_func=$1
    local variant_root="$TEST_ROOT/${provisioner_func}"
    local release=${provisioner_func#network}
    local hostname

    release=${release%_main}
    NETWORK_SYSCTL_CONF="$variant_root/sysctl.conf"
    NETWORK_HOSTNAME_FILE="$variant_root/hostname"
    NETWORK_HOSTS_FILE="$variant_root/hosts"
    NETWORK_NETPLAN_FILE="$variant_root/netplan/01-netcfg.yaml"
    NETWORK_RESOLVED_CONF="$variant_root/resolved.conf"
    NETWORK_IFPLUGD_FILE="$variant_root/ifplugd"
    NETWORK_SHUTDOWN_CMD=shutdown
    mkdir -p "$(dirname "$NETWORK_NETPLAN_FILE")"
    printf '#DNS=\n#FallbackDNS=\n#Domains=\n#DNSSEC=\n#Cache=\n#DNSStubListener=\n' > "$NETWORK_RESOLVED_CONF"
    printf 'INTERFACES=\n' > "$NETWORK_IFPLUGD_FILE"
    sysctl() { printf 'sysctl:%s\n' "$*"; }
    netplan() { printf 'netplan:%s\n' "$*"; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }
    shutdown() { :; }
    stub_portable_sed

    "$provisioner_func" || return 1
    hostname="ubuntu${release}.localdomain"
    [[ $(<"$NETWORK_HOSTNAME_FILE") == "$hostname" ]] || return 1
    grep -q "127.0.0.1 ${hostname}" "$NETWORK_HOSTS_FILE" || return 1
    grep -q 'net.ipv6.conf.all.disable_ipv6 = 1' "$NETWORK_SYSCTL_CONF" || return 1
    grep -q 'renderer: networkd' "$NETWORK_NETPLAN_FILE" || return 1
    grep -q 'DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4' "$NETWORK_RESOLVED_CONF" || return 1
    grep -q 'DNSSEC=yes' "$NETWORK_RESOLVED_CONF" || return 1
    if [[ ${release} != 2604 ]]; then
      grep -q 'INTERFACES="eth0"' "$NETWORK_IFPLUGD_FILE" || return 1
    fi
  }

  run_cleanup_variant() {
    local cleanup_func=$1
    local variant_root="$TEST_ROOT/${cleanup_func}"
    local log_file

    APT_CONFIG_DIR="$variant_root/etc/apt/apt.conf.d"
    CLOUD_INIT_DIR="$variant_root/etc/cloud"
    HOSTS_FILE="$variant_root/etc/hosts"
    LOG_ROOT="$variant_root/var/log"
    RANDOM_SEED_FILE="$variant_root/var/lib/systemd/random-seed"
    mkdir -p "$APT_CONFIG_DIR" "$CLOUD_INIT_DIR" "$LOG_ROOT/dist-upgrade" "$LOG_ROOT/installer" "$LOG_ROOT/apt" "$(dirname "$RANDOM_SEED_FILE")"
    : > "$APT_CONFIG_DIR/20retries"
    printf 'APT::Periodic::Enable "1";\nold-releases.ubuntu.com\n' > "$APT_CONFIG_DIR/10periodic"
    printf 'old-releases.ubuntu.com\nkeep-me\n' > "$HOSTS_FILE"
    : > "$RANDOM_SEED_FILE"
    for log_file in \
      eipp.log.xz history.log term.log; do
      : > "$LOG_ROOT/apt/$log_file"
    done
    for log_file in \
      cloud-init-output.log cloud-init.log bootstrap.log dmesg.1.gz dmesg.0 dmesg \
      ubuntu-advantage-timer.log ubuntu-advantage.log alternatives.log dpkg.log kern.log syslog; do
      : > "$LOG_ROOT/$log_file"
    done
    dpkg() { return 0; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    systemctl() {
      case "$*" in
        '--quiet list-unit-files '* | '--quiet is-active '* | '--quiet is-enabled '*) return 0 ;;
        'is-enabled apt-news.service' | 'is-enabled apt-daily.service' | 'is-enabled packagekit-offline-update.service' | 'is-enabled snapd.service') printf 'masked\n' ;;
        'is-enabled packagekit.service' | 'is-enabled snapd.socket') printf 'disabled\n' ;;
        'stop '* | 'disable '* | 'mask '* | 'unmask '* | 'enable '*) printf 'systemctl:%s\n' "$*" ;;
      esac
    }
    rm() {
      local -a paths=()
      local path
      for path in "$@"; do
        case "$path" in
          --force | --recursive) ;;
          *) paths+=("$path") ;;
        esac
      done
      command rm -rf "${paths[@]}"
    }
    truncate() {
      [[ "$1" == --size=0 ]] || return 1
      : > "$2"
    }
    stub_portable_sed

    "$cleanup_func" || return 1
    test ! -e "$APT_CONFIG_DIR/20retries" &&
      test ! -d "$CLOUD_INIT_DIR" &&
      test ! -e "$RANDOM_SEED_FILE" &&
      grep -q '^keep-me$' "$HOSTS_FILE" &&
      ! grep -q old-releases.ubuntu.com "$HOSTS_FILE" &&
      grep -q 'APT::Periodic::Enable "1";' "$APT_CONFIG_DIR/10periodic"
  }

  setup() {
    TEST_ROOT=$(mktemp -d)
    MACHINE_ID_DBUS_PATH="$TEST_ROOT/dbus-machine-id"
    MACHINE_ID_ETC_PATH="$TEST_ROOT/etc-machine-id"
    MACHINE_ID_RUN_PATH="$TEST_ROOT/run-machine-id"
    LEASE_NETWORKMANAGER_DIR="$TEST_ROOT/NetworkManager"
    LEASE_DHCLIENT_DIR="$TEST_ROOT/dhclient"
    LEASE_DHCP_DIR="$TEST_ROOT/dhcp"
    LOCALTIME_PATH="$TEST_ROOT/localtime"
    SYSCONFIG_CLOCK_PATH="$TEST_ROOT/sysconfig-clock"
    UTC_ZONEINFO_PATH="$TEST_ROOT/zoneinfo/UTC"
    SSH_HOST_KEY_DIR="$TEST_ROOT/ssh"
    SSH_KEY_CRON_PATH="$TEST_ROOT/cron/keys"
    SSH_KEY_REGENERATE_SCRIPT="$TEST_ROOT/bin/regenerate-ssh-host-keys.sh"
    SSH_KEY_REGENERATE_SERVICE="$TEST_ROOT/systemd/regenerate-ssh-host-keys.service"
    MOTD_PATH="$TEST_ROOT/motd"
    CONSOLE_SETUP_PATH="$TEST_ROOT/console-setup"
    UPSTART_TTY_DIR="$TEST_ROOT/init"
    ZERO_DEVICE=/dev/zero
    ROOT_MOUNT_POINT="$TEST_ROOT/root-mount"
    BOOT_MOUNT_POINT="$TEST_ROOT/boot-mount"
    ROOT_ZERO_FILL_PREFIX="$TEST_ROOT/root-zerofill"
    BOOT_ZERO_FILL_FILE="$TEST_ROOT/boot-zerofill"
    BLKID_CMD="$TEST_ROOT/missing-blkid"
    SWAPOFF_CMD=$(command -v true)
    MKSWAP_CMD=$(command -v true)
    SWAP_UUID_DIR="$TEST_ROOT/uuid"
    DD_CALLS_FILE="$TEST_ROOT/dd-calls"
    ROOT_AVAILABLE=80
    BOOT_AVAILABLE=50
    FLOPPY_MODPROBE_CONFIG="$TEST_ROOT/modprobe/floppy.conf"
    FLOPPY_BOOT_DIR="$TEST_ROOT/boot"
    mkdir -p "$TEST_ROOT/bin" "$LEASE_NETWORKMANAGER_DIR" "$LEASE_DHCLIENT_DIR" "$LEASE_DHCP_DIR" "$(dirname "$UTC_ZONEINFO_PATH")" "$(dirname "$FLOPPY_MODPROBE_CONFIG")" "$FLOPPY_BOOT_DIR" "$UPSTART_TTY_DIR"
    mkdir -p "$SSH_HOST_KEY_DIR" "$(dirname "$SSH_KEY_CRON_PATH")" "$(dirname "$SSH_KEY_REGENERATE_SERVICE")"
    printf 'UTC\n' > "$UTC_ZONEINFO_PATH"
  }

  cleanup() {
    command rm -rf "$TEST_ROOT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'sets a generated root password twice and then locks the account'
    dd() { printf 'random-bytes'; }
    md5sum() { printf 'digest  -\n'; }
    awk() { printf 'fixed-password\n'; }
    passwd() {
      if [[ "$*" == root ]]; then
        local password_lines
        password_lines=$(command cat)
        printf 'passwords:%s\n' "${password_lines//$'\n'/,}"
      else
        printf 'locked:%s\n' "$*"
      fi
    }

    When call lockout_main
    The status should be success
    The output should equal "$(printf '%s\n' 'passwords:fixed-password,fixed-password' 'locked:--lock root')"
  End

  It 'truncates each existing machine ID file'
    printf 'machine-id\n' > "$MACHINE_ID_DBUS_PATH"
    printf 'machine-id\n' > "$MACHINE_ID_ETC_PATH"
    printf 'machine-id\n' > "$MACHINE_ID_RUN_PATH"
    machine_id_sizes() {
      machine_main
      printf '%s %s %s' \
        "$(wc -c < "$MACHINE_ID_DBUS_PATH" | tr -d '[:space:]')" \
        "$(wc -c < "$MACHINE_ID_ETC_PATH" | tr -d '[:space:]')" \
        "$(wc -c < "$MACHINE_ID_RUN_PATH" | tr -d '[:space:]')"
    }

    When call machine_id_sizes
    The status should be success
    The output should equal '0 0 0'
  End

  It 'ignores missing machine ID files'
    When call machine_main
    The status should be success
    The output should equal ''
  End

  It 'removes lease files from all configured directories only'
    printf 'lease\n' > "$LEASE_NETWORKMANAGER_DIR/dhcp.lease"
    printf 'lease\n' > "$LEASE_DHCLIENT_DIR/dhclient.leases"
    printf 'lease\n' > "$LEASE_DHCP_DIR/dhclient.lease"
    printf 'keep\n' > "$LEASE_DHCP_DIR/keep.txt"
    cat > "$TEST_ROOT/bin/rm" <<'EOF'
#!/bin/sh
if [ "$1" = "--force" ]; then
  shift
fi
exec /bin/rm -f "$@"
EOF
    chmod +x "$TEST_ROOT/bin/rm"
    PATH="$TEST_ROOT/bin:$PATH"
    verify_leases_removed() {
      leases_main >/dev/null
      test ! -e "$LEASE_NETWORKMANAGER_DIR/dhcp.lease" &&
        test ! -e "$LEASE_DHCLIENT_DIR/dhclient.leases" &&
        test ! -e "$LEASE_DHCP_DIR/dhclient.lease" &&
        test -f "$LEASE_DHCP_DIR/keep.txt"
    }

    When call verify_leases_removed
    The status should be success
  End

  It 'skips lease directories that do not exist'
    LEASE_NETWORKMANAGER_DIR="$TEST_ROOT/missing-networkmanager"
    LEASE_DHCLIENT_DIR="$TEST_ROOT/missing-dhclient"
    LEASE_DHCP_DIR="$TEST_ROOT/missing-dhcp"

    When call leases_main
    The status should be success
    The output should equal ''
  End

  It 'uses timedatectl and removes a regular localtime file first'
    printf 'local timezone\n' > "$LOCALTIME_PATH"
    timedatectl() { printf 'timedatectl:%s\n' "$*"; }
    remove_localtime_file() {
      localtime_main
      test ! -e "$LOCALTIME_PATH"
    }

    When call remove_localtime_file
    The status should be success
    The output should equal 'timedatectl:set-timezone UTC'
  End

  It 'uses timedatectl when localtime does not exist'
    timedatectl() { printf 'timedatectl:%s\n' "$*"; }

    When call localtime_main
    The status should be success
    The output should equal 'timedatectl:set-timezone UTC'
  End

  It 'uses tzdata-update for legacy sysconfig files'
    printf 'ZONE="OLD"\n' > "$SYSCONFIG_CLOCK_PATH"
    command() {
      if [[ "$1 $2" == '-v timedatectl' ]]; then
        return 1
      fi
      builtin command "$@"
    }
    tzdata-update() { printf 'updated\n'; }
    apply_legacy_timezone() {
      localtime_main
      printf '%s' "$(<"$SYSCONFIG_CLOCK_PATH")"
    }

    When call apply_legacy_timezone
    The status should be success
    The output should equal "$(printf '%s\n' updated 'ZONE="UTC"')"
  End

  It 'updates a localtime symlink from the UTC zoneinfo file'
    ln -s "$TEST_ROOT/old-zone" "$LOCALTIME_PATH"
    command() {
      if [[ "$1 $2" == '-v timedatectl' ]]; then
        return 1
      fi
      builtin command "$@"
    }
    verify_localtime_symlink() {
      localtime_main
      [[ -h "$LOCALTIME_PATH" && $(readlink "$LOCALTIME_PATH") == "$UTC_ZONEINFO_PATH" ]]
    }

    When call verify_localtime_symlink
    The status should be success
  End

  It 'copies zoneinfo into a regular localtime file as a fallback'
    printf 'old timezone\n' > "$LOCALTIME_PATH"
    command() {
      if [[ "$1 $2" == '-v timedatectl' ]]; then
        return 1
      fi
      builtin command "$@"
    }
    verify_zoneinfo_copy() {
      localtime_main
      cmp -s "$UTC_ZONEINFO_PATH" "$LOCALTIME_PATH"
    }

    When call verify_zoneinfo_copy
    The status should be success
  End

  It 'removes stale host keys and writes the systemd regeneration service'
    : > "$SSH_KEY_CRON_PATH"
    : > "$SSH_KEY_REGENERATE_SCRIPT"
    systemctl() { printf 'systemctl:%s\n' "$*"; }
    verify_ssh_key_setup() {
      local host_key
      for host_key in \
        ssh_host_key ssh_host_key.pub \
        ssh_host_dsa_key ssh_host_dsa_key.pub \
        ssh_host_rsa_key ssh_host_rsa_key.pub \
        ssh_host_ecdsa_key ssh_host_ecdsa_key.pub \
        ssh_host_ed25519_key ssh_host_ed25519_key.pub; do
        : > "$SSH_HOST_KEY_DIR/$host_key"
      done
      keys_main
      for host_key in \
        ssh_host_key ssh_host_key.pub \
        ssh_host_dsa_key ssh_host_dsa_key.pub \
        ssh_host_rsa_key ssh_host_rsa_key.pub \
        ssh_host_ecdsa_key ssh_host_ecdsa_key.pub \
        ssh_host_ed25519_key ssh_host_ed25519_key.pub; do
        test ! -e "$SSH_HOST_KEY_DIR/$host_key" || return 1
      done
      test ! -e "$SSH_KEY_CRON_PATH" &&
        test ! -e "$SSH_KEY_REGENERATE_SCRIPT" &&
        grep -q 'ExecStart=/usr/bin/ssh-keygen -A' "$SSH_KEY_REGENERATE_SERVICE"
    }

    When call verify_ssh_key_setup
    The status should be success
    The output should include 'systemctl:daemon-reload'
    The output should include 'systemctl:enable regenerate-ssh-host-keys.service'
  End

  It 'rebuilds initramfs for each configured Ubuntu kernel'
    : > "$FLOPPY_BOOT_DIR/config-6.8.0"
    : > "$FLOPPY_BOOT_DIR/config-6.8.1"
    mkinitramfs() { printf '%s\n' "$*"; }
    rebuild_all_initramfs() {
      floppy2204_main
      floppy2404_main
      floppy2604_main
    }

    When call rebuild_all_initramfs
    The status should be success
    The output should include "-o $FLOPPY_BOOT_DIR/initrd.img-6.8.0.img 6.8.0"
    The output should include "-o $FLOPPY_BOOT_DIR/initrd.img-6.8.1.img 6.8.1"
    The contents of file "$FLOPPY_MODPROBE_CONFIG" should equal 'blacklist floppy'
  End

  It 'returns failure when initramfs generation fails'
    : > "$FLOPPY_BOOT_DIR/config-6.8.0"
    mkinitramfs() { return 1; }

    When call floppy2604_main
    The status should be failure
  End

  It 'clears the configured MOTD file'
    printf 'stale message\n' > "$MOTD_PATH"
    clear_motd() {
      motd_main
      test ! -s "$MOTD_PATH"
    }

    When call clear_motd
    The status should be success
  End

  It 'updates console configuration and removes non-primary tty files'
    printf 'ACTIVE_CONSOLES="/dev/tty[1-6]"\n' > "$CONSOLE_SETUP_PATH"
    : > "$UPSTART_TTY_DIR/tty0.conf"
    : > "$UPSTART_TTY_DIR/tty1.conf"
    : > "$UPSTART_TTY_DIR/ttyS0.conf"
    rm() {
      [[ "$1" != --force ]] || shift
      command rm -f "$@"
    }
    verify_tty_configuration() {
      fixtty2204_main
      fixtty2404_main
      fixtty2604_main
      [[ $(<"$CONSOLE_SETUP_PATH") == 'ACTIVE_CONSOLES="/dev/tty1"' ]] &&
        test ! -e "$UPSTART_TTY_DIR/tty0.conf" &&
        test ! -e "$UPSTART_TTY_DIR/ttyS0.conf" &&
        test -f "$UPSTART_TTY_DIR/tty1.conf"
    }

    When call verify_tty_configuration
    The status should be success
  End

  It 'writes root vim configuration for each Ubuntu version'
    verify_root_profile_variants() {
      local profile_func
      for profile_func in profile2204_main profile2404_main profile2604_main; do
        run_profile_variant "$profile_func" false || return 1
        test "$(<"$PROFILE_ROOT_HOME/.vimrc")" = 'set mouse-=a' || return 1
      done
    }

    When call verify_root_profile_variants
    The status should be success
  End

  It 'configures the optional Vagrant home for each Ubuntu version'
    verify_vagrant_profile_variants() {
      local profile_func
      for profile_func in profile2204_main profile2404_main profile2604_main; do
        run_profile_variant "$profile_func" true || return 1
        test "$(<"$PROFILE_VAGRANT_HOME/.vimrc")" = 'set mouse-=a' || return 1
      done
    }

    When call verify_vagrant_profile_variants
    The status should be success
    The output should include 'chown:vagrant:vagrant'
  End

  It 'provisions the Vagrant user for each Ubuntu version'
    verify_vagrant_provisioners() {
      local provisioner_func
      for provisioner_func in vagrant2204_main vagrant2404_main vagrant2604_main; do
        run_vagrant_variant "$provisioner_func" || return 1
        test -f "$VAGRANT_HOME_DIR/.ssh/authorized_keys" || return 1
        grep -q 'vagrant insecure public key' "$VAGRANT_HOME_DIR/.ssh/authorized_keys" || return 1
        grep -q 'vagrant ALL=(ALL) NOPASSWD: ALL' "$VAGRANT_SUDOERS_FILE" || return 1
        if [[ "$provisioner_func" == vagrant2604_main ]]; then
          ! grep -q requiretty "$VAGRANT_SUDOERS_FILE" || return 1
        else
          grep -q requiretty "$VAGRANT_SUDOERS_FILE" || return 1
        fi
        [[ $(<"$VAGRANT_BUILD_TIME_FILE") == build-time ]] || return 1
      done
    }

    When call verify_vagrant_provisioners
    The status should be success
    The output should include 'useradd:vagrant'
    The output should include 'passwd:vagrant:vagrant,vagrant'
    The output should include 'chmod:0600'
    The output should include 'chown:-R vagrant:vagrant'
  End

  It 'configures MOTD files and timers for each Ubuntu version'
    verify_motd_variants() {
      local provisioner_func
      for provisioner_func in motd2204_main motd2404_main motd2604_main; do
        run_motd_variant "$provisioner_func" || return 1
      done
    }

    When call verify_motd_variants
    The status should be success
    The output should include 'systemctl:stop update-notifier-motd.timer'
    The output should include 'systemctl:stop motd-news.timer'
    The output should include 'systemctl:disable update-notifier-motd.timer'
    The output should include 'systemctl:disable motd-news.timer'
    The output should include 'chown:vagrant:vagrant'
  End

  It 'configures network files and services for each Ubuntu version'
    verify_network_variants() {
      local provisioner_func
      for provisioner_func in network2204_main network2404_main network2604_main; do
        run_network_variant "$provisioner_func" || return 1
      done
    }

    When call verify_network_variants
    The status should be success
    The output should include 'apt-get:--assume-yes install ifplugd'
    The output should include 'systemctl:enable systemd-networkd.service'
    The output should include 'systemctl:enable ifplugd.service'
    The output should include 'netplan:generate'
  End

  It 'cleans APT state and systemd units for each Ubuntu version'
    verify_cleanup_variants() {
      local cleanup_func
      for cleanup_func in cleanup2204_main cleanup2404_main cleanup2604_main; do
        run_cleanup_variant "$cleanup_func" || return 1
      done
    }

    When call verify_cleanup_variants
    The status should be success
    The output should include 'apt-get:--assume-yes purge cloud-init'
    The output should include 'apt-get:--assume-yes autoremove'
    The output should include 'systemctl:stop systemd-random-seed.service'
    The output should include 'systemctl:unmask apt-news.service'
    The output should include 'systemctl:unmask snapd.service'
  End

  It 'fills root and boot when they are on different partitions'
    setup_zerodisk_commands

    When call run_zerodisk_with_dd_count
    The status should be success
    The output should include 'dd-count:5'
    The output should include 'All done.'
  End

  It 'skips the separate boot fill when root and boot share a partition'
    BOOT_AVAILABLE=80
    setup_zerodisk_commands

    When call run_zerodisk_with_dd_count
    The status should be success
    The output should include 'dd-count:4'
  End

  It 'fills an available swap partition'
    cat > "$BLKID_CMD" <<'EOF'
#!/bin/sh
printf 'test-swap-uuid\n'
EOF
    chmod +x "$BLKID_CMD"
    setup_zerodisk_commands
    readlink() { printf '%s\n' "$TEST_ROOT/swap-device"; }
    run_zerodisk_with_swap() {
      zerodisk_main
      printf 'swap-fill:%s\n' "$(grep -c "of=$TEST_ROOT/swap-device" "$DD_CALLS_FILE")"
    }

    When call run_zerodisk_with_swap
    The status should be success
    The output should include 'swap-fill:1'
    The output should include 'All done.'
  End

  It 'suppresses failed zeroing and early sync operations'
    setup_zerodisk_commands
    dd() { return 1; }
    sync_calls=0
    sync() {
      sync_calls=$((sync_calls + 1))
      [[ ${sync_calls} -gt 2 ]]
    }
    When call zerodisk_main
    The status should be success
    The output should include 'dd exit code 1 suppressed'
    The output should include 'sync exit code 1 suppressed'
  End
End
