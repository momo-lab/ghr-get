shellspec_syntax 'shellspec_modifier_md5sum'

shellspec_modifier_md5sum() {
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ -e "${SHELLSPEC_SUBJECT:-}" ]; then
    SHELLSPEC_SUBJECT=$(md5sum "${SHELLSPEC_SUBJECT:-}" | cut -d' ' -f 1)
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
