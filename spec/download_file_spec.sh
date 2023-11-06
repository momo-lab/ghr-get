Describe 'download_file.sh'
  Include bin/ghr-get
  Include lib/download_file.sh

  output_dir=./tmp

  beforeEach() {
    mkdir -p "$output_dir"
  }

  afterEach() {
    rm -rf "$output_dir"
  }

  BeforeEach beforeEach
  AfterEach afterEach

  It 'is success'
    file=ghq_linux_amd64.zip
    url="https://github.com/x-motemen/ghq/releases/download/v1.4.0/$file"
    When call download_file "$url" "$output_dir"
    The status should equal 0
    The output should equal ""
    The path "$output_dir/$file" should be exist
    The path "$output_dir/$file" should be file
  End

  It 'is not found url'
    file=test.zip
    url="https://github.com/momo-lab/ghr-get/releases/download/unknown/$file"
    When call download_file "$url" "$output_dir"
    The status should equal 1
    The lines of error should equal 2
    The line 1 of error should equal "curl: (22) The requested URL returned error: 404"
    The line 2 of error should equal "Download error: $url"
    The path "$output_dir/$file" should not be exist
  End
End
