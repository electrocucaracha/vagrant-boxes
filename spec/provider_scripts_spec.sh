#!/bin/bash
# shellcheck disable=SC2329,SC2034 # ShellSpec invokes helper stubs dynamically.

Include scripts/ubuntu2404/qemu.sh
Include scripts/ubuntu2404/virtualbox.sh
Include scripts/ubuntu2204/qemu.sh
Include scripts/ubuntu2604/qemu.sh
Include scripts/ubuntu2204/virtualbox.sh
Include scripts/ubuntu2604/virtualbox.sh

Describe 'Ubuntu 24.04 provider scripts'
  stub_non_qemu_host() {
    dmidecode() { [[ "$2" == system-product-name ]] && printf 'Other\n' || printf 'Acme\n'; }
    apt-get() { return 1; }
    systemctl() { return 1; }
  }

  It 'skips installation on a non-QEMU host'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2404-virtualbox-x64
    stub_non_qemu_host

    When call qemu_main
    The status should be success
    The output should equal ''
  End

  It 'installs QEMU tools for the matching UTM Packer build'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2404-utm-arm64
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call qemu_main
    The status should be success
    The output should include 'apt-get:--assume-yes install qemu-guest-agent'
    The output should include 'systemctl:disable open-vm-tools.service'
    The output should include 'apt-get:--assume-yes install haveged'
    The output should include 'systemctl:enable haveged.service'
    The variable DEBIAN_FRONTEND should equal 'noninteractive'
    The variable DEBCONF_NONINTERACTIVE_SEEN should equal 'true'
  End

  It 'installs QEMU tools when DMI identifies a QEMU host'
    TERM=dumb
    unset PACKER_BUILD_NAME
    dmidecode() { [[ "$2" == system-product-name ]] && printf 'Other\n' || printf 'QEMU\n'; }
    apt-get() { :; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call qemu_main
    The status should be success
    The output should include 'Installing the QEMU Tools.'
    The output should include 'systemctl:enable haveged.service'
  End

  It 'stops after ten failed QEMU package installation attempts'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2404-utm-arm64
    which() { printf '/usr/bin/tput\n'; }
    tput() { :; }
    sleep() { :; }
    apt-get() { return 1; }

    When call qemu_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'qemu addons failed to install...'
  End

  It 'skips VirtualBox installation on other hosts'
    TERM=dumb
    dmidecode() { printf 'KVM\n'; }
    apt-get() { return 1; }

    When call virtualbox_main
    The status should be success
    The output should equal ''
  End

  It 'installs VirtualBox tools and removes the downloaded installers'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    cat() { printf '7.1.0\n'; }
    rm() { printf 'rm:%s\n' "$*"; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call virtualbox_main
    The status should be success
    The output should include 'apt-get:--assume-yes install virtualbox-guest-utils'
    The output should include 'rm:-rf /root/VBoxVersion.txt'
    The output should include 'rm:-rf /root/VBoxGuestAdditions.iso'
    The output should include 'apt-get:--assume-yes install haveged'
    The output should include 'systemctl:enable haveged.service'
    The variable VBOXVERSION should equal '7.1.0'
  End

  It 'stops after ten failed VirtualBox package installation attempts'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    which() { return 1; }
    sleep() { :; }
    apt-get() { return 1; }

    When call virtualbox_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'The VirtualBox install failed...'
  End

  It 'stops when removing the Guest Additions ISO fails'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    apt-get() { :; }
    cat() { printf '7.1.0\n'; }
    rm() { [[ "$2" != /root/VBoxGuestAdditions.iso ]]; }
    systemctl() { :; }

    When call virtualbox_main
    The status should be failure
    The output should include 'The VirtualBox install failed...'
  End

  It 'installs QEMU tools for the Ubuntu 22.04 UTM Packer build'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2204-utm-arm64
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call qemu2204_main
    The status should be success
    The output should include 'apt-get:--assume-yes install qemu-guest-agent'
    The output should include 'systemctl:enable haveged.service'
  End

  It 'skips QEMU setup for the Ubuntu 22.04 non-QEMU host'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2204-virtualbox-x64
    stub_non_qemu_host

    When call qemu2204_main
    The status should be success
    The output should equal ''
  End

  It 'reports Ubuntu 22.04 QEMU package retry exhaustion'
    TERM=dumb
    PACKER_BUILD_NAME=generic-ubuntu2204-utm-arm64
    which() { return 1; }
    sleep() { :; }
    apt-get() { return 1; }

    When call qemu2204_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'qemu addons failed to install...'
  End

  It 'installs QEMU tools for the Ubuntu 26.04 QEMU DMI host'
    TERM=dumb
    unset PACKER_BUILD_NAME
    dmidecode() { [[ "$2" == system-product-name ]] && printf 'KVM\n' || printf 'QEMU\n'; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call qemu2604_main
    The status should be success
    The output should include 'apt-get:--assume-yes install qemu-guest-agent'
    The output should include 'systemctl:enable haveged.service'
  End

  It 'skips QEMU setup for the Ubuntu 26.04 non-QEMU host'
    TERM=dumb
    unset PACKER_BUILD_NAME
    dmidecode() { [[ "$2" == system-product-name ]] && printf 'Other\n' || printf 'Acme\n'; }
    apt-get() { return 1; }
    systemctl() { return 1; }

    When call qemu2604_main
    The status should be success
    The output should equal ''
  End

  It 'reports Ubuntu 26.04 QEMU package retry exhaustion'
    TERM=dumb
    unset PACKER_BUILD_NAME
    dmidecode() { [[ "$2" == system-product-name ]] && printf 'Other\n' || printf 'QEMU\n'; }
    which() { return 1; }
    sleep() { :; }
    apt-get() { return 1; }

    When call qemu2604_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'qemu addons failed to install...'
  End

  It 'installs VirtualBox tools for the Ubuntu 22.04 host'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    cat() { printf '7.0.0\n'; }
    rm() { :; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call virtualbox2204_main
    The status should be success
    The output should include 'apt-get:--assume-yes install virtualbox-guest-utils'
    The output should include 'systemctl:enable haveged.service'
    The variable VBOXVERSION should equal '7.0.0'
  End

  It 'skips VirtualBox setup for other Ubuntu 22.04 hosts'
    TERM=dumb
    dmidecode() { printf 'KVM\n'; }
    apt-get() { return 1; }

    When call virtualbox2204_main
    The status should be success
    The output should equal ''
  End

  It 'reports Ubuntu 22.04 VirtualBox package retry exhaustion'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    which() { return 1; }
    sleep() { :; }
    apt-get() { return 1; }

    When call virtualbox2204_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'The VirtualBox install failed...'
  End

  It 'installs VirtualBox tools for the Ubuntu 26.04 host'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    apt-get() { printf 'apt-get:%s\n' "$*"; }
    cat() { printf '7.1.0\n'; }
    rm() { :; }
    systemctl() { printf 'systemctl:%s\n' "$*"; }

    When call virtualbox2604_main
    The status should be success
    The output should include 'apt-get:--assume-yes install virtualbox-guest-utils'
    The output should include 'apt-get:--assume-yes install haveged'
    The output should include 'systemctl:enable haveged.service'
    The variable VBOXVERSION should equal '7.1.0'
  End

  It 'skips VirtualBox setup for other Ubuntu 26.04 hosts'
    TERM=dumb
    dmidecode() { printf 'KVM\n'; }
    apt-get() { return 1; }

    When call virtualbox2604_main
    The status should be success
    The output should equal ''
  End

  It 'reports Ubuntu 26.04 VirtualBox package retry exhaustion'
    TERM=dumb
    dmidecode() { printf 'VirtualBox\n'; }
    which() { return 1; }
    sleep() { :; }
    apt-get() { return 1; }

    When call virtualbox2604_main
    The status should be failure
    The stderr should include 'The command failed 10 times.'
    The output should include 'The VirtualBox install failed...'
  End
End