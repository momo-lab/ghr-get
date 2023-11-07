shellspec_syntax 'shellspec_matcher_equal_md5sum'

shellspec_matcher_equal_md5sum() {
  checksum() {
    md5sum "$1" | cut -d' ' -f -1
  }
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT="$1"
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    [[ _"$(checksum ${SHELLSPEC_SUBJECT})" == _"${SHELLSPEC_EXPECT}" ]] || return 1
    return 0
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "exptected: md5sum $1 is not $2"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "exptected: md5sum $1 is $2"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}

