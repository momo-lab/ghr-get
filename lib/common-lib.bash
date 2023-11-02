[ -n "$GHR_GET_DEBUG" ] && set -x

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

LATEST_PAGE_URL='https://github.com/${package}/releases/latest'
