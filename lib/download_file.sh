set -eu

download_file() {
  local url="$1" output_dir="$2"
  local file=${url##*/}

  curl -fsSL -o "$output_dir/$file" "$url"
  if [ $? -ne 0 ]; then
    echo "Download error: $url" >&2
    return 1
  fi
}
