Describe '.sh'
  Include bin/ghr-get
  Include lib/download_asset.sh

  # default mocked uname command
  uname() {
    if [[ "${1:-}" == "-m" ]]; then
      echo "x86_64"
    else
      echo "Linux"
    fi
  }
End
