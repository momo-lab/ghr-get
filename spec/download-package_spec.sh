Describe 'download-package.sh'
  Include bin/ghr-get
  Include lib/download-package.sh

  # default mocked uname command
  uname() {
    if [[ "${1:-}" == "-m" ]]; then
      echo "x86_64"
    else
      echo "Linux"
    fi
  }

  Describe 'match_patterns function'
    It 'is no match'
      files=$(
        %text
        #|test_darwin_amd64.zip
        #|test_darwin_arm64.zip
        #|test_windows_amd64.zip
        #|test_windows_arm64.zip
      )
      patterns="linux* musl"
      When call match_patterns "$files" "$patterns"
      The output should equal "$files"
    End
    
    It 'is match'
      files=$(
        %text
        #|test_linux_amd64.zip
        #|test_linux_arm64.zip
        #|test_darwin_amd64.zip
        #|test_darwin_arm64.zip
        #|test_windows_amd64.zip
        #|test_windows_arm64.zip
      )
      patterns="linux"
      When call match_patterns "$files" "$patterns"
      The lines of output should equal 2
      The line 1 of output should equal 'test_linux_amd64.zip'
      The line 2 of output should equal 'test_linux_arm64.zip'
    End
  End

  Describe 'match_architecture function'
    Describe 'for go application'
      files=$(
        %text
        #|test_linux_amd64.zip
        #|test_linux_arm64.zip
        #|test_darwin_amd64.zip
        #|test_darwin_arm64.zip
        #|test_windows_amd64.zip
        #|test_windows_arm64.zip
      )
      Example 'is linux64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "Linux"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test_linux_amd64.zip'
      End

      Example 'is mingw64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "MINGW64_NT"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test_windows_amd64.zip'
      End

      Example 'is cygwin64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "CYGWIN"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test_windows_amd64.zip'
      End

      Example 'is mac'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "DARWIN"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test_darwin_amd64.zip'
      End
    End

    Describe 'for rust application'
      files=$(
        %text
        #|test-v1.0-arm-unknown-linux-gnueabihf.tar.gz
        #|test-v1.0-i686-pc-windows-msvc.zip
        #|test-v1.0-x86_64-apple-darwin.tar.gz
        #|test-v1.0-x86_64-pc-windows-gnu.zip
        #|test-v1.0-x86_64-pc-windows-msvc.zip
        #|test-v1.0-x86_64-unknown-linux-musl.tar.gz
        #|test_v1.0_amd64.deb
      )
      Example 'is linux64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "Linux"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test-v1.0-x86_64-unknown-linux-musl.tar.gz'
      End

      Example 'is mingw64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "MINGW64_NT"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test-v1.0-x86_64-pc-windows-msvc.zip'
      End

      Example 'is cygwin64'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "CYGWIN"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test-v1.0-x86_64-pc-windows-msvc.zip'
      End

      Example 'is cygwin32'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "i686"
          else
            echo "CYGWIN"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test-v1.0-i686-pc-windows-msvc.zip'
      End

      Example 'is mac'
        uname() {
          if [[ "${1:-}" == "-m" ]]; then
            echo "x86_64"
          else
            echo "DARWIN"
          fi
        }
        When call match_architecture "$files"
        The output should equal 'test-v1.0-x86_64-apple-darwin.tar.gz'
      End
    End
  End

  Describe 'get_assets function'
    It 'is success'
      site=github.com
      package=x-motemen/ghq
      version=v1.4.1
      When call get_assets "$site" "$package" "$version"
      The status should equal 0
      The lines of output should equal 7
      The line 1 should equal 'ghq_darwin_amd64.zip'
      The line 2 should equal 'ghq_darwin_arm64.zip'
      The line 3 should equal 'ghq_linux_amd64.zip'
      The line 4 should equal 'ghq_linux_arm64.zip'
      The line 5 should equal 'ghq_windows_amd64.zip'
      The line 6 should equal 'ghq_windows_arm64.zip'
      The line 7 should equal 'SHASUMS'
    End
  End

  Describe 'get_release_filepath function'
    It 'is success'
      site=github.com
      package=x-motemen/ghq
      version=v1.4.1
      When call get_release_filepath "$site" "$package" "$version"
      The output should equal 'ghq_linux_amd64.zip'
    End
  End

  Describe 'download_file function'
    package_dir=./tmp

    beforeEach() {
      mkdir -p "$package_dir"
    }

    afterEach() {
      rm -rf "$package_dir"
    }

    BeforeEach beforeEach
    AfterEach afterEach

    It 'is success'
      file=ghq_linux_amd64.zip
      url="https://github.com/x-motemen/ghq/releases/download/v1.4.0/$file"
      When call download_file "$url" "$package_dir"
      The status should equal 0
      The output should equal ""
      The path "$package_dir/$file" should be exist
      The path "$package_dir/$file" should be file
    End

    It 'is not found url'
      file=test.zip
      url="https://github.com/momo-lab/ghr-get/releases/download/unknown/$file"
      When call download_file "$url" "$package_dir"
      The status should equal 1
      The lines of error should equal 2
      The line 1 of error should equal "curl: (22) The requested URL returned error: 404"
      The line 2 of error should equal "Download error: $url"
      The path "$package_dir/$file" should not be exist
    End
  End
End
