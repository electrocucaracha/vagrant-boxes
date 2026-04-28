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
      #|utm
    }

    It 'splits comma and whitespace separated values'
      When call _parse_list "ubuntu2204,ubuntu2404 utm"
      The output should equal "$(result)"
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
      BOX_BASE_URL='https://example.invalid/releases/'

      When call _box_url ubuntu2204 "$box_file"
      The output should equal "https://example.invalid/releases/generic/ubuntu2204/example.box"
    End
  End

  Describe '_deploy_www'
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
      DEPLOY_WWW=true

      mkdir -p "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204"
      mkdir -p "$WWW_ROOT/$BOX_NAMESPACE"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/test.box"
      : > "$OUTPUT_ROOT/$BOX_NAMESPACE/ubuntu2204/metadata.json"
      : > "$WWW_ROOT/$BOX_NAMESPACE/stale.file"

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
  End
End
