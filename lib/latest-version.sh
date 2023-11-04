set -eu

function parser_definition_latest-version() {
  setup REST help:usage_latest-version abbr:true width:20,20 -- \
      "Usage: ghr-get latest-version [options...] [package name]"
  msg -- '' 'Options:'
  disp :usage_latest-version -h --help    -- "Show help"
}
eval "$(getoptions parser_definition_latest-version parse_latest-version) exit 1"

function latest-version() {
  parse_latest-version "$@"
  eval "set -- $REST"
  if [ $# -ne 1 ]; then
    usage_latest-version
    return 0
  fi

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
