set -eu

function unarchive_file() {
  local file="$1"
  local output_dir=$(dirname "$file")
  shopt -s nocasematch
  case "$file" in
    *.zip)
      unzip -oq $file -d $output_dir
      ;;
    *.tar.gz|*.tgz)
      tar -xz -C $output_dir -f $file
      ;;
    *)
      echo "Unknown file type: $file" >&2
      return 1
      ;;
  esac
}
