set -eu

function get_latest_version() {
  local -r package="$1"
  local -r url=https://github.com/${package}/releases/latest
  local -r headers=$(curl -IfsS ${url} 2>&1)
  if [[ "${headers%%:*}" == "curl" ]]; then
    echo "${headers}" | head -1 >&2
    echo "package is not found: ${package}" >&2
    return 1
  fi

  local -r version=$(echo "$headers" | awk -F/ -v RS='\r\n' '/^location: / {print $8}')
  if [[ "${version}" == "" ]]; then
    echo "release package is not found: ${package}" >&2
    return 1
  fi
  echo -n ${version}
}
