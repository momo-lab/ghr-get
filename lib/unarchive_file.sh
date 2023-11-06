set -eu

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
