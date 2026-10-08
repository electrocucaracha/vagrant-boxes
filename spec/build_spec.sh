#!/bin/bash
# shellcheck disable=SC2329,SC2034 # ShellSpec invokes helpers and shares globals dynamically.

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

  call_capturing_exit() {
    exit() { return "$1"; }
    local result
    if "$@"; then
      result=0
    else
      result=$?
    fi
    unset -f exit
    return "$result"
  }

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
      BOX_NAMESPACE=electrocucaracha-boxes

      When call _box_url ubuntu2204 "$box_file"
      The output should equal "https://example.invalid/releases/ubuntu-jammy/example.box"
    End
  End

  Describe '_get_distro_slug'
    It 'returns the Ubuntu 22.04 codename slug'
      When call _get_distro_slug ubuntu2204
      The output should equal 'ubuntu-jammy'
    End

    It 'returns the Ubuntu 24.04 codename slug'
      When call _get_distro_slug ubuntu2404
      The output should equal 'ubuntu-noble'
    End

    It 'returns the Ubuntu 26.04 codename slug'
      When call _get_distro_slug ubuntu2604
      The output should equal 'ubuntu-resolute'
    End
  End

  Describe '_get_box_version'
    It 'returns the Ubuntu 22.04 box version by default'
      VERSION=

      When call _get_box_version ubuntu2204
      The output should equal '22.04.5'
    End

    It 'returns the Ubuntu 24.04 box version by default'
      VERSION=

      When call _get_box_version ubuntu2404
      The output should equal '24.04.3'
    End

    It 'returns the Ubuntu 26.04 box version by default'
      VERSION=

      When call _get_box_version ubuntu2604
      The output should equal '26.04'
    End

    It 'uses VERSION as a global override when set'
      VERSION=99.99.99

      When call _get_box_version ubuntu2404
      The output should equal '99.99.99'
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

  Describe '_validate'
    It 'accepts a clean VirtualBox host with no running VMs'
      PROVIDERS=(virtualbox)
      CLEANUP_ALL_VMS=false
      pgrep() { return 1; }
      VBoxManage() { :; }

      When call _validate
      The status should be success
      The output should equal ''
    End

    It 'accepts a clean libvirt host when the KVM probe times out as expected'
      PROVIDERS=(libvirt)
      CLEANUP_ALL_VMS=false
      KVM_DEVICE="$TEST_ROOT/kvm"
      : > "$KVM_DEVICE"
      pgrep() { return 1; }
      fuser() { return 1; }
      timeout() { return 124; }
      virsh() { :; }

      When call _validate
      The status should be success
      The output should equal ''
    End

    It 'cleans up conflicting VMs when CLEANUP_ALL_VMS is enabled'
      # shellcheck disable=SC2016
      When run bash -c '. ./build.sh; TEST_ROOT=$(mktemp -d); trap "rm -rf \"$TEST_ROOT\"" EXIT; KVM_DEVICE="$TEST_ROOT/kvm"; : > "$KVM_DEVICE"; PROVIDERS=(libvirt); CLEANUP_ALL_VMS=true; vbox_running=1; vbox_processes=1; libvirt_running=1; VBoxManage() { case "$1 $2" in "list runningvms") [ "$vbox_running" -eq 1 ] && printf "\"vm\" {deadbeef}\n" ;; "controlvm deadbeef") [ "$3" = poweroff ] || return 1; vbox_running=0 ;; esac; }; pgrep() { [ "$vbox_processes" -eq 1 ] && printf "123 VBoxHeadless /usr/lib/virtualbox/VBoxHeadless --startvm deadbeef\n"; }; kill() { [ "$1" = "123" ] || return 1; vbox_processes=0; }; virsh() { case "$1 $2 $3" in "list --state-running --name") [ "$libvirt_running" -eq 1 ] && printf "builder-vm\n" ;; esac; if [ "$1" = "destroy" ]; then [ "$2" = "builder-vm" ] || return 1; libvirt_running=0; fi; }; fuser() { :; }; timeout() { shift; return 124; }; _validate'
      The status should be success
      The output should include "Cleaning up running VirtualBox VMs before proceeding"
      The output should include "Cleaning up orphaned VirtualBox processes before proceeding"
      The output should include "Cleaning up running libvirt instances before proceeding"
    End

    It 'fails fast when VirtualBox VM processes are running for libvirt builds'
      # shellcheck disable=SC2016
      When run bash -c '. ./build.sh; TEST_ROOT=$(mktemp -d); trap "rm -rf \"$TEST_ROOT\"" EXIT; KVM_DEVICE="$TEST_ROOT/kvm"; : > "$KVM_DEVICE"; PROVIDERS=(libvirt); pgrep() { printf "1234 VBoxHeadless /usr/lib/virtualbox/VBoxHeadless --startvm deadbeef\n"; }; VBoxManage() { [ "$1 $2" = "list runningvms" ] && return 0; return 1; }; _validate'
      The status should be failure
      The output should include "Running VirtualBox VM process(es) detected"
      The output should include "VBoxHeadless"
      The output should include "After confirming with the user"
      The output should include "for pid in 1234; do kill \"\$pid\"; done"
    End

    It 'fails fast when the KVM device is busy for libvirt builds'
      # shellcheck disable=SC2016
      When run bash -c '. ./build.sh; TEST_ROOT=$(mktemp -d); trap "rm -rf \"$TEST_ROOT\"" EXIT; KVM_DEVICE="$TEST_ROOT/kvm"; : > "$KVM_DEVICE"; PROVIDERS=(libvirt); pgrep() { :; }; fuser() { printf "1234 5678\n"; }; virsh() { :; }; _validate'
      The status should be failure
      The output should include "KVM device"
      The output should include "is busy"
    End

    It 'fails fast when the KVM acceleration probe cannot create a VM'
      # shellcheck disable=SC2016
      When run bash -c '. ./build.sh; TEST_ROOT=$(mktemp -d); trap "rm -rf \"$TEST_ROOT\"" EXIT; KVM_DEVICE="$TEST_ROOT/kvm"; : > "$KVM_DEVICE"; PROVIDERS=(libvirt); pgrep() { :; }; fuser() { :; }; timeout() { shift; "$@"; }; qemu-system-x86_64() { echo "ioctl(KVM_CREATE_VM) failed: 16 Device or resource busy" >&2; echo "qemu-system-x86_64: failed to initialize kvm: Device or resource busy" >&2; return 1; }; virsh() { :; }; _validate'
      The status should be failure
      The output should include "KVM acceleration probe failed"
      The output should include "failed to initialize kvm"
    End
  End

  Describe 'supported build inputs'
    It 'rejects an unsupported distro value'
      When call call_capturing_exit _assert_supported_distro ubuntu9999
      The status should be failure
      The output should include "ERROR: Unsupported distro 'ubuntu9999'"
    End

    It 'rejects an unsupported provider value'
      When call call_capturing_exit _assert_supported_provider xen
      The status should be failure
      The output should include "ERROR: Unsupported provider 'xen'"
    End
  End

  Describe '_validate_kvm'
    validate_kvm_capturing_exit() {
      exit() { return "$1"; }
      local result
      if _validate_kvm; then
        result=0
      else
        result=$?
      fi
      unset -f exit
      return "$result"
    }

    It 'skips optional fuser and timeout probes when those commands are unavailable'
      KVM_DEVICE="$TEST_ROOT/kvm"
      : > "$KVM_DEVICE"
      command() {
        if [[ "$1" == -v && ( "$2" == fuser || "$2" == timeout ) ]]; then
          return 1
        fi
        builtin command "$@"
      }

      When call _validate_kvm
      The status should be success
      The output should equal ''
    End

    It 'passes the KVM probe when timeout returns its expected status'
      KVM_DEVICE="$TEST_ROOT/kvm"
      : > "$KVM_DEVICE"
      fuser() { return 1; }
      timeout() { [[ "$1 $2" == '2s qemu-system-x86_64' ]] && return 124; }

      When call _validate_kvm
      The status should be success
      The output should equal ''
    End

    It 'rejects a failed KVM acceleration probe'
      KVM_DEVICE="$TEST_ROOT/kvm"
      : > "$KVM_DEVICE"
      fuser() { return 1; }
      timeout() { return 1; }

      When call validate_kvm_capturing_exit
      The status should be failure
      The output should include 'KVM acceleration probe failed: unknown error'
    End
  End

  Describe '_build_box'
    build_box_with_distro_version() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      WORK_DIR="$TEST_ROOT/output"
      BOX_NAMESPACE=electrocucaracha-boxes
      VERSION=

      # shellcheck disable=SC2329 # Invoked indirectly by _build_box in the test.
      packer() {
        if [ "$1" = "build" ]; then
          local build_name=${2#-only=}
          mkdir -p "$WORK_DIR"
          : > "$WORK_DIR/${build_name}-${VERSION}.box"
          printf '0123456789abcdef  %s\n' "${build_name}-${VERSION}.box" > "$WORK_DIR/${build_name}-${VERSION}.box.sha256"
          return 0
        fi

        return 1
      }

      _build_box ubuntu2404 virtualbox

      test -f "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-virtualbox-x64-24.04.3.box" &&
        test -f "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-virtualbox-x64-24.04.3.box.sha256"
    }

    It 'publishes a UTM box and records the built artifact'
      build_utm_box() {
        OUTPUT_ROOT="$TEST_ROOT/utm-dist"
        WORK_DIR="$TEST_ROOT/utm-output"
        BOX_NAMESPACE=electrocucaracha-boxes
        VERSION=
        # shellcheck disable=SC2329 # Invoked indirectly by _build_box in the test.
        packer() {
          if [ "$1" = build ]; then
            local build_name=${2#-only=}
            mkdir -p "$WORK_DIR"
            : > "$WORK_DIR/${build_name}-${VERSION}.box"
            printf '0123456789abcdef  %s\n' "${build_name}-${VERSION}.box" > "$WORK_DIR/${build_name}-${VERSION}.box.sha256"
            return 0
          fi
          return 1
        }
        utmctl() { return 1; }

        _build_box ubuntu2204 utm
        test -f "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-jammy/ubuntu-jammy-utm-arm64-22.04.5.box" &&
          [[ $(_get_built_box_path ubuntu2204:utm) == "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-jammy/ubuntu-jammy-utm-arm64-22.04.5.box" ]]
      }

      When call build_utm_box
      The status should be success
    End
  End

  Describe '_write_metadata'
    metadata_for_distro() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=electrocucaracha-boxes
      VERSION=
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      BUILT_KEYS=()
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      BUILT_BOXES=()
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      BUILT_CHECKSUMS=()

      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box"
      printf '0123456789abcdef  %s\n' ubuntu-noble-libvirt-x64-24.04.3.box > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box.sha256"

      _record_built_box \
        "ubuntu2404:libvirt" \
        "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box" \
        "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box.sha256"

      _write_metadata ubuntu2404

      jq -r '[.name, .versions[0].version, .versions[0].providers[0].url] | @tsv' \
        "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu-noble/metadata.json"
    }

    expected_metadata() {
      printf '%s\t%s\tfile://%s' \
        'electrocucaracha-boxes/ubuntu-noble' \
        '24.04.3' \
        "$(realpath "$TEST_ROOT/dist/electrocucaracha-boxes/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box")"
    }

    It 'writes metadata with the distro slug name and box URL'
      When call metadata_for_distro
      The output should equal "$(expected_metadata)"
    End

    It 'marks the amd64 provider as default and skips unbuilt providers'
      OUTPUT_ROOT="$TEST_ROOT/multi-provider-dist"
      BOX_NAMESPACE=electrocucaracha-boxes
      BOX_BASE_URL=
      VERSION=
      PROVIDERS=(utm libvirt virtualbox)
      BUILT_KEYS=()
      BUILT_BOXES=()
      BUILT_CHECKSUMS=()
      write_multi_provider_metadata() {
        local utm_box="$TEST_ROOT/utm.box"
        local libvirt_box="$TEST_ROOT/libvirt.box"
        : > "$utm_box"
        : > "$libvirt_box"
        printf 'utm-checksum  %s\n' "$utm_box" > "$utm_box.sha256"
        printf 'libvirt-checksum  %s\n' "$libvirt_box" > "$libvirt_box.sha256"
        _record_built_box ubuntu2404:utm "$utm_box" "$utm_box.sha256"
        _record_built_box ubuntu2404:libvirt "$libvirt_box" "$libvirt_box.sha256"
        _write_metadata ubuntu2404
        jq -r '.versions[0].providers[] | [.name, .architecture, .default_architecture] | @tsv' \
          "$OUTPUT_ROOT/electrocucaracha-boxes/ubuntu-noble/metadata.json"
      }

      When call write_multi_provider_metadata
      The status should be success
      The output should equal "$(printf 'utm\tarm64\tfalse\nlibvirt\tamd64\ttrue')"
    End

    It 'fails when no built provider exists for the requested distro'
      OUTPUT_ROOT="$TEST_ROOT/empty-dist"
      BOX_NAMESPACE=electrocucaracha-boxes
      PROVIDERS=(libvirt virtualbox)
      BUILT_KEYS=()
      BUILT_BOXES=()
      BUILT_CHECKSUMS=()

      When call _write_metadata ubuntu2404
      The status should be failure
      The output should include 'ERROR: No built boxes found for ubuntu2404'
    End
  End

  Describe '_deploy_www'
    rclone() {
      test "$1" = copy || return 1
      test "$3" = 'Cloudflare R2:electrocucaracha-vagrant-boxes' || return 1
      [[ ${RCLONE_FAIL:-false} != true ]] || return 1
      command cp -R "$2/." "$TEST_ROOT/deployed/"
    }

    prepare_deploy_fixtures() {
      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/metadata.json"
    }

    deploy_www_disabled() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      DEPLOY_WWW=false

      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"

      _deploy_www

      test ! -e "$TEST_ROOT/deployed"
    }

    deploy_www_enabled() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      DEPLOY_WWW=true

      prepare_deploy_fixtures

      _deploy_www

      test -f "$TEST_ROOT/deployed/ubuntu2204/test.box" &&
        test -f "$TEST_ROOT/deployed/ubuntu2204/metadata.json" &&
        test ! -e "$OUTPUT_ROOT/$BOX_NAMESPACE"
    }

    deploy_www_failed_copy_preserves_artifacts() {
      OUTPUT_ROOT="$TEST_ROOT/dist"
      BOX_NAMESPACE=generic
      # shellcheck disable=SC2034 # Used by build.sh helpers loaded via ShellSpec.
      DEPLOY_WWW=true
      RCLONE_FAIL=true

      prepare_deploy_fixtures

      if _deploy_www; then
        return 1
      fi

      test -f "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"
    }

    It 'does nothing by default'
      When call deploy_www_disabled
      The status should be success
    End

    It 'copies published artifacts when enabled'
      When call deploy_www_enabled
      The status should be success
    End

    It 'preserves local artifacts when the upload fails'
      When call deploy_www_failed_copy_preserves_artifacts
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

  Describe 'provider mappings'
    It 'returns distro descriptions and packer templates'
      provider_mappings() {
        printf '%s\n' \
          "$(_get_description ubuntu2204)" \
          "$(_get_description ubuntu2404)" \
          "$(_get_description ubuntu2604)" \
          "$(_get_description unknown)" \
          "$(_get_packer_template libvirt)" \
          "$(_get_packer_template utm)" \
          "$(_get_packer_template virtualbox)"
      }

      When call provider_mappings
      The output should equal "$(printf '%s\n' 'Ubuntu Jammy 22.04' 'Ubuntu Noble 24.04' 'Ubuntu Resolute 26.04' 'Unknown' 'generic-libvirt-x64.json' 'generic-utm-arm64.json' 'generic-virtualbox-x64.json')"
    End

    It 'returns build and metadata architectures for each provider'
      provider_architectures() {
        printf '%s\n' \
          "$(_get_provider_build_arch libvirt)" \
          "$(_get_provider_build_arch utm)" \
          "$(_get_provider_build_arch virtualbox)" \
          "$(_get_provider_metadata_arch libvirt)" \
          "$(_get_provider_metadata_arch utm)" \
          "$(_get_provider_metadata_arch virtualbox)"
      }

      When call provider_architectures
      The output should equal "$(printf '%s\n' x64 arm64 x64 amd64 arm64 amd64)"
    End
  End

  Describe 'built artifact bookkeeping'
    It 'finds, reads, and updates recorded artifacts'
      BUILT_KEYS=()
      BUILT_BOXES=()
      BUILT_CHECKSUMS=()
      record_and_read_artifacts() {
        _record_built_box ubuntu2404:libvirt /tmp/old.box /tmp/old.sha256
        _record_built_box ubuntu2404:libvirt /tmp/new.box /tmp/new.sha256
        printf '%s\n' \
          "$(_find_built_box_index ubuntu2404:libvirt)" \
          "$(_get_built_box_path ubuntu2404:libvirt)" \
          "$(_get_built_checksum_path ubuntu2404:libvirt)" \
          "${BUILT_KEYS[0]}"
      }

      When call record_and_read_artifacts
      The output should equal "$(printf '%s\n' 0 /tmp/new.box /tmp/new.sha256 ubuntu2404:libvirt)"
    End

    It 'returns no index for an unknown build key'
      BUILT_KEYS=(ubuntu2204:libvirt)

      When call _find_built_box_index ubuntu2404:libvirt
      The status should be failure
    End
  End

  Describe '_get_default_architecture'
    It 'prefers amd64 when an amd64 provider has been built'
      PROVIDERS=(utm libvirt)
      BUILT_KEYS=(ubuntu2404:utm ubuntu2404:libvirt)
      BUILT_BOXES=(/tmp/utm.box /tmp/libvirt.box)
      BUILT_CHECKSUMS=(/tmp/utm.sha256 /tmp/libvirt.sha256)

      When call _get_default_architecture ubuntu2404
      The output should equal 'amd64'
    End

    It 'uses the first available architecture when amd64 was not built'
      PROVIDERS=(utm virtualbox)
      BUILT_KEYS=(ubuntu2404:utm)
      BUILT_BOXES=(/tmp/utm.box)
      BUILT_CHECKSUMS=(/tmp/utm.sha256)

      When call _get_default_architecture ubuntu2404
      The output should equal 'arm64'
    End
  End

  Describe '_ensure_packer_plugin'
    It 'installs a missing plugin at the requested version'
      packer() {
        case "$1 $2" in
          'plugins installed') return 0 ;;
          'plugins install') printf 'installed:%s:%s\n' "$3" "$4" ;;
        esac
      }

      When call _ensure_packer_plugin github.com/example/plugin v1.2.3
      The output should include 'Installing missing packer plugin: github.com/example/plugin @ v1.2.3'
      The output should include 'installed:github.com/example/plugin:v1.2.3'
    End
  End

  Describe '_remove_packer_plugin'
    It 'removes an installed conflicting plugin'
      packer() {
        case "$1 $2" in
          'plugins installed') printf 'github.com/example/plugin v1.0.0\n' ;;
          'plugins remove') printf 'removed:%s\n' "$3" ;;
        esac
      }

      When call _remove_packer_plugin github.com/example/plugin
      The output should include 'Removing conflicting packer plugin: github.com/example/plugin'
      The output should include 'removed:github.com/example/plugin'
    End
  End

  Describe '_check_reqs'
    It 'checks requirements and plugins for every supported provider'
      PROVIDERS=(libvirt utm virtualbox)
      DISTROS=(ubuntu2204 ubuntu2404 ubuntu2604)
      jq() { :; }
      packer() {
        case "$1 $2" in
          'plugins installed') printf 'github.com/naveenrajm7/utm v0.0.0\n' ;;
          'plugins remove') printf 'removed:%s\n' "$3" ;;
          'plugins install') printf 'installed:%s\n' "$3" ;;
        esac
      }
      realpath() { :; }
      sha256sum() { :; }
      vagrant() { :; }
      qemu-system-x86_64() { :; }
      virsh() { :; }
      utmctl() { :; }
      VBoxManage() { :; }
      uname() { printf 'Darwin\n'; }

      When call _check_reqs
      The status should be success
      The output should include 'removed:github.com/naveenrajm7/utm'
      The output should include 'installed:github.com/hashicorp/qemu'
      The output should include 'installed:github.com/electrocucaracha/utm'
      The output should include 'installed:github.com/hashicorp/virtualbox'
    End
  End

  Describe 'VirtualBox and libvirt helpers'
    It 'extracts VirtualBox VM identifiers from running VM output'
      VBoxManage() {
        [[ "$1 $2" == 'list runningvms' ]] || return 1
        printf '"first" {abc123}\n\n"second" {def456}\n'
      }

      When call _get_virtualbox_running_vm_ids
      The output should equal "$(printf '%s\n' abc123 def456)"
    End

    It 'extracts process identifiers from VirtualBox process output'
      pgrep() {
        [[ "$1 $2" == '-a -f' && "$3" == 'VBoxHeadless|VirtualBoxVM' ]] || return 1
        printf '123 VBoxHeadless --startvm first\n456 VirtualBoxVM --startvm second\n'
      }

      When call _get_virtualbox_running_process_ids
      The output should equal "$(printf '%s\n' 123 456)"
    End

    It 'powers off every running VirtualBox VM'
      vm_actions=
      VBoxManage() {
        case "$1 $2" in
          'list runningvms') printf '"first" {abc123}\n"second" {def456}\n' ;;
          controlvm\ *) vm_actions="${vm_actions} $2:$3" ;;
        esac
      }
      record_vm_poweroff() {
        _cleanup_running_virtualbox_vms
        printf '%s\n' "${vm_actions# }"
      }

      When call record_vm_poweroff
      The output should include 'Cleaning up running VirtualBox VMs before proceeding.'
      The output should include 'abc123:poweroff'
      The output should include 'def456:poweroff'
    End

    It 'kills every orphaned VirtualBox process'
      killed_processes=
      pgrep() { printf '123 VBoxHeadless --startvm first\n456 VirtualBoxVM --startvm second\n'; }
      kill() { killed_processes="${killed_processes} $1"; }
      record_process_cleanup() {
        _cleanup_virtualbox_processes
        printf '%s\n' "${killed_processes# }"
      }

      When call record_process_cleanup
      The output should include 'Cleaning up orphaned VirtualBox processes before proceeding.'
      The output should include '123 456'
    End

    It 'destroys each running libvirt domain'
      destroyed_domains=
      virsh() {
        if [[ "$1 $2 $3" == 'list --state-running --name' ]]; then
          printf 'first-domain\nsecond-domain\n'
        elif [[ "$1" == destroy ]]; then
          destroyed_domains="${destroyed_domains} $2"
        fi
      }
      record_domain_cleanup() {
        _cleanup_running_libvirt_instances
        printf '%s\n' "${destroyed_domains# }"
      }

      When call record_domain_cleanup
      The output should include 'Cleaning up running libvirt instances before proceeding.'
      The output should include 'first-domain second-domain'
    End

    It 'prefers an actionable VM stop command when VM and process data exist'
      VBoxManage() { [[ "$1 $2" == 'list runningvms' ]] && printf '"vm" {abc123}\n'; }
      pgrep() { printf '123 VBoxHeadless --startvm vm\n'; }

      When call _print_virtualbox_stop_instruction
      # shellcheck disable=SC2016 # Verify the literal command template.
      The output should include 'for vm in abc123; do VBoxManage controlvm "$vm" poweroff; done'
      The output should not include 'for pid in'
    End

    It 'prints a process stop command when no VM identifiers are available'
      VBoxManage() { :; }
      pgrep() { printf '123 VBoxHeadless --startvm vm\n'; }

      When call _print_virtualbox_stop_instruction
      # shellcheck disable=SC2016 # Verify the literal command template.
      The output should include 'for pid in 123; do kill "$pid"; done'
    End

    It 'prints the generic stop command when no VM or process data is available'
      VBoxManage() { :; }
      pgrep() { return 1; }

      When call _print_virtualbox_stop_instruction
      The output should include 'VBoxManage list runningvms'
    End

    It 'checks whether the provider is selected'
      PROVIDERS=(libvirt utm)

      When call _has_provider utm
      The status should be success
    End

    It 'returns failure when the provider is not selected'
      PROVIDERS=(libvirt utm)

      When call _has_provider virtualbox
      The status should be failure
    End
  End

  Describe '_ensure_packer_plugin'
    It 'installs a missing plugin without a version'
      packer() {
        case "$1 $2" in
          'plugins installed') return 0 ;;
          'plugins install') printf 'installed:%s\n' "$3" ;;
        esac
      }

      When call _ensure_packer_plugin github.com/example/plugin
      The output should include 'Installing missing packer plugin: github.com/example/plugin'
      The output should include 'installed:github.com/example/plugin'
    End
  End

  Describe '_cleanup_utm_vm'
    It 'ignores a VM that does not exist'
      utmctl() { return 1; }

      When call _cleanup_utm_vm test-vm
      The status should be success
      The output should equal ''
    End

    It 'deletes a stopped VM without stopping it'
      utm_actions=
      utmctl() {
        case "$1" in
          status) printf 'stopped\n' ;;
          stop | delete) utm_actions="${utm_actions} $1" ;;
        esac
      }
      cleanup_stopped_utm_vm() {
        _cleanup_utm_vm test-vm
        printf '%s\n' "${utm_actions# }"
      }

      When call cleanup_stopped_utm_vm
      The output should include 'Removing existing UTM VM: test-vm'
      The output should include 'delete'
      The output should not include 'stop'
    End

    It 'stops a running VM before deleting it'
      utm_actions=
      utmctl() {
        case "$1" in
          status) printf 'started\n' ;;
          stop | delete) utm_actions="${utm_actions} $1" ;;
        esac
      }
      cleanup_running_utm_vm() {
        _cleanup_utm_vm test-vm
        printf '%s\n' "${utm_actions# }"
      }

      When call cleanup_running_utm_vm
      The output should include 'stop delete'
    End
  End

  Describe '_wait_for_kvm_users'
    It 'returns immediately when there are no KVM users'
      SUDO_CMD=sudo
      sudo() { "$@"; }
      fuser() { return 1; }

      When call _wait_for_kvm_users
      The status should be success
      The output should equal ''
    End

    It 'waits once for users to release KVM'
      SUDO_CMD=sudo
      fuser_calls=0
      sudo() { "$@"; }
      fuser() {
        fuser_calls=$((fuser_calls + 1))
        [[ ${fuser_calls} -lt 2 ]]
      }
      sleep() { printf 'sleep:%s\n' "$1"; }

      When call _wait_for_kvm_users
      The status should be success
      The output should include 'Waiting for users of /dev/kvm to exit... (1/30)'
      The output should include 'sleep:2'
    End

    It 'fails after the maximum wait and reports KVM users'
      SUDO_CMD=sudo
      sudo() { "$@"; }
      fuser() { return 0; }
      sleep() { :; }

      When call _wait_for_kvm_users
      The status should be failure
      The output should include 'ERROR: /dev/kvm is still in use.'
    End
  End
End
