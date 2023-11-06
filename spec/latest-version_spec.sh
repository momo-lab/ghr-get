Describe 'latest-version subcommand'
  Include bin/ghr-get
  Include lib/latest-version.sh

  It 'is no parameter'
    When call latest-version
    The status should equal 0
    The line 1 should equal 'Usage: ghr-get latest-version [options...] [package name]'
  End

  It 'github repository is not found'
    package='momo-lab/not_found'
    When call latest-version $package
    The status should equal 1
    The line 1 of error should equal "curl: (22) The requested URL returned error: 404"
    The line 2 of error should equal "package is not found: $package"
  End

  It 'package is not found'
    package='momo-lab/ghr-get'
    When call latest-version $package
    The status should equal 1
    The line 1 of error should equal "release package is not found: $package"
  End

  It 'package is found'
    package=x-motemen/ghq
    When call latest-version $package
    The status should equal 0
    The output should match pattern "v[0-9].[0-9].[0-9]"
  End
End
