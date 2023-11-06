Describe 'get_asset.sh'
  Include bin/ghr-get
  Include lib/get_asset.sh

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

  Describe 'get_asset function'
    It 'is success'
      site=github.com
      package=x-motemen/ghq
      version=v1.4.1
      When call get_asset "$site" "$package" "$version"
      The output should equal 'ghq_linux_amd64.zip'
    End
  End
End
