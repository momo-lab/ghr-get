set -eu

abort() {
  {
    if [ "$#" -eq 0 ]; then
      cat -
    else
      echo "ghr-get: $*"
    fi
  } >&2
  exit 1
}

match_patterns() {
  local files="$1" patterns="$2"
  local pat
  for pat in $patterns; do
    pat="[-_\\.]${pat/\*/[^-_\\.]*}\([-_\\.]\|$\)"
    local bufs=$(echo "$files" | grep "$pat")
    if [[ "$bufs" != "" ]]; then
      files="$bufs"
    fi
  done
  echo "$files"
}

match_architecture() {
  local files="$1"
  shopt -s nocasematch

  local os
  case "$(uname)" in
    mingw* | msys* | cygwin* ) os="windows* win* msvc" ;;
    linux*) os="linux* musl" ;;
    darwin) os="darwin osx" ;;
  esac
  files=$(match_patterns "$files" "$os")

  local arch
  case "$(uname -m)" in
    x86_64) arch="amd64 x86_64 *64" ;;
    i686) arch="386 i686 *32" ;;
    # TODO arm not supported
  esac
  files=$(match_patterns "$files" "$arch")

  file=$(echo "$files" | head -1)
  [ -z "$file" ] || echo "$file"
}

get_assets() {
  local site="$1" package="$2" version="$3"
  local url=https://$site/$package/releases/expanded_assets/$version
  local html=$(curl -fsSL $url) || abort "Package version '$package@$version' is not found"
  local files=$(echo "$html" |
    grep -o "/$package/releases/download/[^\"]*" |
    awk -F/ '{print $7}')
  echo "$files"
}

get_asset() {
  local site="$1" package="$2" version="$3"
  local files=$(get_assets "$site" "$package" "$version")
  local file=$(match_architecture "$files")
  [ -z "$file" ] && abort "no target architecture"

  echo "$file"
}
