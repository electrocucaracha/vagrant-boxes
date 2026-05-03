#!/bin/bash

Describe 'build.sh'
  Include build.sh

  setup() {
    TEST_ROOT=$(mktemp -d)
  }

  cleanup() {
    rm -rf "$TEST_ROOT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe '_parse_list'
    result() { %text
      #|ubuntu2204
      #|ubuntu2404
      #|ubuntu2604
      #|utm
    }

    It 'splits comma and whitespace separated values'
      When call _parse_list "ubuntu2204,ubuntu2404 ubuntu2604,utm"
      The output should equal "$(result)"
    End

    It 'preserves DISTROS and PROVIDERS environment overrides when sourcing build.sh'
      expected() { %text
        #|providers=utm
        #|distros=ubuntu2604
      }

      # shellcheck disable=SC2016
      When run bash -c 'export PROVIDERS=utm DISTROS=ubuntu2604; . ./build.sh; printf "providers=%s\ndistros=%s\n" "${PROVIDERS[*]}" "${DISTROS[*]}"'
      The status should be success
      The output should equal "$(expected)"
    End
  End

  Describe '_box_url'
    It 'builds local file URLs when BOX_BASE_URL is unset'
      box_file="$TEST_ROOT/example.box"
      : > "$box_file"
      BOX_BASE_URL=

      When call _box_url ubuntu2204 "$box_file"
      The output should equal "file://$(realpath "$box_file")"
    End

    It 'builds hosted URLs when BOX_BASE_URL is set'
      box_file="$TEST_ROOT/example.box"
      : > "$box_file"
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      BOX_BASE_URL='https://example.invalid/releases/'

      When call _box_url ubuntu2204 "$box_file"
      The output should equal "https://example.invalid/releases/generic/ubuntu2204/example.box"
    End
  End

  Describe '_ensure_packer_plugin'
    It 'does not reinstall a plugin when the requested v-prefixed version is already installed'
      packer() {
        case "$1 $2" in
          "plugins installed")
            echo "/tmp/github.com/electrocucaracha/utm/packer-plugin-utm_v4.0.3_x5.0_darwin_arm64"
            ;;
          "plugins install")
            echo "unexpected install"
            return 1
            ;;
        esac
      }

      When call _ensure_packer_plugin github.com/electrocucaracha/utm v4.0.3
      The status should be success
      The output should equal ""
    End
  End

  Describe '_deploy_www'
    prepare_deploy_fixtures() {
      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204"
      mkdir -p "$WWW_ROOT/$BOX_NAMESPACE"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/metadata.json"
      : > "$WWW_ROOT/$BOX_NAMESPACE/stale.file"
    }

    deploy_www_disabled() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      WWW_ROOT="$TEST_ROOT/www"
      DEPLOY_WWW=false

      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"

      _deploy_www

      test ! -e "$WWW_ROOT/$BOX_NAMESPACE"
    }

    deploy_www_enabled() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      WWW_ROOT="$TEST_ROOT/www"
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      DEPLOY_WWW=true

      prepare_deploy_fixtures

      _deploy_www

      test -f "$WWW_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box" &&
        test -f "$WWW_ROOT/$BOX_NAMESPACE/ubuntu2204/metadata.json" &&
        test ! -e "$WWW_ROOT/$BOX_NAMESPACE/stale.file"
    }

    deploy_www_enabled_with_sudo() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      WWW_ROOT="$TEST_ROOT/www"
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      DEPLOY_WWW=true
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      SUDO_CMD=sudo

      # shellcheck disable=SC2329 # Invoked indirectly via SUDO_CMD in build.sh.
      sudo() {
        "$@"
      }

      prepare_deploy_fixtures

      _deploy_www

      test -f "$WWW_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box" &&
        test -f "$WWW_ROOT/$BOX_NAMESPACE/ubuntu2204/metadata.json" &&
        test ! -e "$WWW_ROOT/$BOX_NAMESPACE/stale.file"
    }

    It 'does nothing by default'
      When call deploy_www_disabled
      The status should be success
    End

    It 'copies published artifacts when enabled'
      When call deploy_www_enabled
      The status should be success
    End

    It 'uses SUDO_CMD for deployment when configured'
      When call deploy_www_enabled_with_sudo
      The status should be success
    End
  End

  Describe 'Packer autoinstall sources'
    builder_boot_command() {
      local template_path=${1:?template is required}
      local builder_name=${2:?builder name is required}

      jq -r \
        --arg builder_name "$builder_name" \
        '.builders[] | select(.name == $builder_name) | .boot_command | join("")' \
        "$template_path"
    }

    It 'uses distro-specific NoCloud data for the Ubuntu 22.04 VirtualBox build'
      When call builder_boot_command generic-virtualbox-x64.json generic-ubuntu2204-virtualbox-x64
      The output should include 'ds=nocloud-net\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2204/'
    End

    It 'uses distro-specific NoCloud data for the Ubuntu 24.04 VirtualBox build'
      When call builder_boot_command generic-virtualbox-x64.json generic-ubuntu2404-virtualbox-x64
      The output should include 'ds=nocloud-net\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2404/'
    End

    It 'uses distro-specific NoCloud data for the Ubuntu 26.04 VirtualBox build'
      When call builder_boot_command generic-virtualbox-x64.json generic-ubuntu2604-virtualbox-x64
      The output should include 'ds=nocloud-net\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2604/'
    End

    It 'uses the updated kernel arguments for the Ubuntu 26.04 VirtualBox build'
      When call builder_boot_command generic-virtualbox-x64.json generic-ubuntu2604-virtualbox-x64
      The output should include 'autoinstall quiet fsck.mode=skip noprompt'
    End

    It 'uses distro-specific NoCloud data for the Ubuntu 22.04 libvirt build'
      When call builder_boot_command generic-libvirt-x64.json generic-ubuntu2204-libvirt-x64
      The output should include 'ds=nocloud-net\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2204/'
    End

    It 'uses distro-specific NoCloud data for the Ubuntu 24.04 libvirt build'
      When call builder_boot_command generic-libvirt-x64.json generic-ubuntu2404-libvirt-x64
      The output should include 'ds=nocloud-net\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2404/'
    End

    It 'uses distro-specific NoCloud data for the Ubuntu 26.04 libvirt build'
      When call builder_boot_command generic-libvirt-x64.json generic-ubuntu2604-libvirt-x64
      The output should include 'ds="nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu2604/"'
    End

    It 'uses the newer GRUB kernel arguments for the Ubuntu 26.04 libvirt build'
      When call builder_boot_command generic-libvirt-x64.json generic-ubuntu2604-libvirt-x64
      The output should include 'autoinstall quiet fsck.mode=skip noprompt'
    End
  End

  Describe 'UTM cloud image sources'
    builder_field() {
      local template_path=${1:?template is required}
      local builder_name=${2:?builder name is required}
      local field_name=${3:?field name is required}

      jq -r \
        --arg builder_name "$builder_name" \
        --arg field_name "$field_name" \
        '.builders[] | select(.name == $builder_name) | .[$field_name]' \
        "$template_path"
    }

    builder_cd_files() {
      local template_path=${1:?template is required}
      local builder_name=${2:?builder name is required}

      jq -r \
        --arg builder_name "$builder_name" \
        '.builders[] | select(.name == $builder_name) | .cd_files | join(",")' \
        "$template_path"
    }

    It 'attaches the Ubuntu 22.04 cloud-init seed media for the UTM build'
      When call builder_cd_files generic-utm-arm64.json generic-ubuntu2204-utm-arm64
      The output should equal 'http/ubuntu2204-utm/user-data,http/ubuntu2204-utm/meta-data,http/ubuntu2204-utm/network-config'
    End

    It 'uses the cloud builder for the Ubuntu 22.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2204-utm-arm64 type
      The output should equal 'utm-cloud'
    End

    It 'uses the Jammy arm64 cloud image for the Ubuntu 22.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2204-utm-arm64 iso_url
      The output should equal 'https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64.img'
    End

    It 'uses the cloud builder for the Ubuntu 24.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2404-utm-arm64 type
      The output should equal 'utm-cloud'
    End

    It 'uses the Noble arm64 cloud image for the Ubuntu 24.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2404-utm-arm64 iso_url
      The output should equal 'https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img'
    End

    It 'attaches the Ubuntu 24.04 cloud-init seed media for the UTM build'
      When call builder_cd_files generic-utm-arm64.json generic-ubuntu2404-utm-arm64
      The output should equal 'http/ubuntu2404-utm/user-data,http/ubuntu2404-utm/meta-data,http/ubuntu2404-utm/network-config'
    End

    It 'uses the cloud builder for the Ubuntu 26.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2604-utm-arm64 type
      The output should equal 'utm-cloud'
    End

    It 'uses the Resolute arm64 cloud image for the Ubuntu 26.04 UTM build'
      When call builder_field generic-utm-arm64.json generic-ubuntu2604-utm-arm64 iso_url
      The output should equal 'https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-arm64.img'
    End

    It 'attaches the Ubuntu 26.04 cloud-init seed media for the UTM build'
      When call builder_cd_files generic-utm-arm64.json generic-ubuntu2604-utm-arm64
      The output should equal 'http/ubuntu2604-utm/user-data,http/ubuntu2604-utm/meta-data,http/ubuntu2604-utm/network-config'
    End
  End

  Describe 'UTM cloud-init seeds'
    It 'unlocks root for the Ubuntu 22.04 UTM seed'
      When run grep -Eq '^users:|^  - name: root$|^    lock_passwd: false$' http/ubuntu2204-utm/user-data
      The status should be success
    End

    It 'sets a plaintext root password for the Ubuntu 22.04 UTM seed'
      When run grep -Eq '^chpasswd:|^  users:$|^    - name: root$|^      password: vagrant$|^      type: text$' http/ubuntu2204-utm/user-data
      The status should be success
    End

    It 'provides separate NoCloud network config for Ubuntu 22.04 UTM'
      When run grep -Eq '^version: 2$|name: \"en\\*\"|name: \"eth\\*\"|dhcp4: true' http/ubuntu2204-utm/network-config
      The status should be success
    End

    It 'unlocks root for the Ubuntu 24.04 UTM seed'
      When run grep -Eq '^users:|^  - name: root$|^    lock_passwd: false$' http/ubuntu2404-utm/user-data
      The status should be success
    End

    It 'sets a plaintext root password for the Ubuntu 24.04 UTM seed'
      When run grep -Eq '^chpasswd:|^  users:$|^    - name: root$|^      password: vagrant$|^      type: text$' http/ubuntu2404-utm/user-data
      The status should be success
    End

    It 'provides separate NoCloud network config for Ubuntu 24.04 UTM'
      When run grep -Eq '^version: 2$|name: \"en\\*\"|name: \"eth\\*\"|dhcp4: true' http/ubuntu2404-utm/network-config
      The status should be success
    End

    It 'unlocks root for the Ubuntu 26.04 UTM seed'
      When run grep -Eq '^users:|^  - name: root$|^    lock_passwd: false$' http/ubuntu2604-utm/user-data
      The status should be success
    End

    It 'sets a plaintext root password for the Ubuntu 26.04 UTM seed'
      When run grep -Eq '^chpasswd:|^  users:$|^    - name: root$|^      password: vagrant$|^      type: text$' http/ubuntu2604-utm/user-data
      The status should be success
    End

    It 'provides separate NoCloud network config for Ubuntu 26.04 UTM'
      When run grep -Eq '^version: 2$|name: \"en\\*\"|name: \"eth\\*\"|dhcp4: true' http/ubuntu2604-utm/network-config
      The status should be success
    End
  End

  Describe 'Ubuntu 26.04 autoinstall identity'
    It 'uses a non-root identity user for the Ubuntu 26.04 ISO installer'
      When run grep -Eq '^  identity:$|^      username: vagrant$' http/ubuntu2604/user-data
      The status should be success
    End

    It 'still enables root SSH access for the Ubuntu 26.04 ISO installer'
      When run sh -c "grep -Fq -- \"- printf 'PermitRootLogin yes\\\\nPasswordAuthentication yes\\\\n' > /target/etc/ssh/sshd_config.d/99-packer.conf\" http/ubuntu2604/user-data && grep -Fq -- \"- curtin in-target --target=/target -- /bin/bash -c \\\"echo 'root:vagrant' | chpasswd\\\"\" http/ubuntu2604/user-data"
      The status should be success
    End
  End

  Describe 'Ubuntu 26.04 provisioning scripts'
    It 'does not depend on ifplugd in the Ubuntu 26.04 network script'
      When run grep -q 'ifplugd' scripts/ubuntu2604/network.sh
      The status should be failure
    End

    It 'does not use the removed requiretty sudoers setting in the Ubuntu 26.04 vagrant script'
      When run grep -q 'requiretty' scripts/ubuntu2604/vagrant.sh
      The status should be failure
    End
  End
End
