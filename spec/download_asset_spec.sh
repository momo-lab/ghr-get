Describe 'download_asset.sh'
  Include bin/ghr-get
  Include lib/download_asset.sh

  site=github.com

  # default mocked uname command
  uname() {
    if [[ "${1:-}" == "-m" ]]; then
      echo "x86_64"
    else
      echo "Linux"
    fi
  }

  It 'is success'
    site=github.com
    package=x-motemen/ghq
    version=v1.4.1
    file=ghq_linux_amd64.zip
    md5=021f757e5ea19d2bda6e4300a9ccf6cb

    output_dir="$PACKAGE_ROOT_PATH/$site/$package/$version"
    When call download_asset "$site" "$package" "$version"
    The status should equal 0
    The output should equal "$output_dir"
    The path "$output_dir/$file" should be exist
    The path "$output_dir/$file" should be file
    The path "$output_dir/$file" should equal_md5sum "$md5"
  End
End
