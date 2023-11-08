Describe 'unarchive_file.sh'
  Include bin/ghr-get
  Include lib/unarchive_file.sh

  Describe 'supported file type'
    Parameters
      "test.zip"
      "test.tar.gz"
      "test.tgz"
    End

    It "is success of $1"
      file="$1"
      cp spec/data/$file $PACKAGE_ROOT_PATH/
      When call unarchive_file "$PACKAGE_ROOT_PATH/$file"
      The status should equal 0
      The output should equal ""
      The contents of path "$PACKAGE_ROOT_PATH/a.txt" should equal "aaaaa"
      The contents of path "$PACKAGE_ROOT_PATH/b.txt" should equal "bbbbb"
      The contents of path "$PACKAGE_ROOT_PATH/subdir/c.txt" should equal "ccccc"
    End
  End

  It 'is unsupported file type'
    file="test.txt"
    When call unarchive_file "$PACKAGE_ROOT_PATH/$file"
    The status should equal 1
    The error should equal "Unknown file type: $PACKAGE_ROOT_PATH/$file"
  End
End
