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

function match_patterns() {
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

function match_architecture() {
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

function get_assets() {
  local site="$1" package="$2" version="$3"
  local url=https://$site/$package/releases/expanded_assets/$version
  local html=$(curl -fsSL $url) || abort "Package version '$package@$version' is not found"
  local files=$(echo "$html" |
    grep -o "/$package/releases/download/[^\"]*" |
    awk -F/ '{print $7}')
  echo "$files"
}

function get_release_filepath() {
  local site="$1" package="$2" version="$3"
  local files=$(get_assets "$site" "$package" "$version")
  local file=$(match_architecture "$files")
  [ -z "$file" ] && abort "no target architecture"

  echo "$file"
}

function download_file() {
  local url="$1" package_dir="$2"
  local file=${url##*/}

  curl -fsSL -o "$package_dir/$file" "$url"
  if [ $? -ne 0 ]; then
    echo "Download error: $url" >&2
    return 1
  fi
}

function unarchive_file() {
  local package="$1" package_dir="$2" file="$3"
  shopt -s nocasematch
  case "$file" in
    *.zip)
      unzip -oq $package_dir/$file -d $package_dir
      rm -f $package_dir/$file
      ;;
    *.tar.gz|*.tgz)
      tar -xz -C $package_dir -f $package_dir/$file
      rm -f $package_dir/$file
      ;;
    *)
      if (file $package_dir/$file | grep "executable" > /dev/null ); then
        # execution file
        local newname=${package##*/}
        local ext=${file##*.}
        if [ "$ext" != "$file" ]; then
          newname="$newname.$ext"
        fi
        mv $package_dir/$file $package_dir/$newname
        chmod a+x $package_dir/$newname
      else
        echo "Unknown file type. [$file]." >&2
        return 1
      fi
      ;;
  esac
}

function download-package() {
  site="github.com"
  package="$1"
  version="$2"

  package_dir="$GHR_GET_ROOT/packages/$site/$package/$version"

  [[ -d "$package_dir" ]] && exit 2

  file="$(get_release_filepath "$site" "$package" "$version")"
  if [[ $? != 0 ]]; then
      exit 1
  fi
  url="https://$site/$package/releases/download/$version/$file"
  mkdir -p "$package_dir"
  download_file "$url" "$package_dir" || exit 1
  unarchive_file "$package" "$package_dir" "$file" || exit 1
  echo "$package_dir"
}
