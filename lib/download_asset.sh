set -eu

source ${LIB_PATH}/download_file.sh
source ${LIB_PATH}/get_asset.sh

function download_asset() {
  local site="$1" package="$2" version="$3"

  local asset_file=$(get_asset "$site" "$package" "$version")

  local package_dir="${PACKAGE_ROOT_PATH}/${site}/${package}/${version}"
  mkdir -p "$package_dir"

  local url="https://${site}/${package}/releases/download/${version}/${asset_file}"
  download_file "$url" "$package_dir"

  echo "${package_dir}"
}

function download_asset_backup() {
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
