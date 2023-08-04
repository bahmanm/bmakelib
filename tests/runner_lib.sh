####################################################################################################
# echo.error MSG
####################################################################################################
function echo.error {
  echo "$@" >&2
}

####################################################################################################
# pushd DIR
####################################################################################################
function pushd {
  command pushd "$@" > /dev/null
}

####################################################################################################
# popd DIR
####################################################################################################
function popd {
  command popd "$@" > /dev/null
}

####################################################################################################
# run_a_test_suite TEST_SUITE
#
# Globals:
#   target_dir
#   root_dir
####################################################################################################
function run_a_test_suite {
  perl -E 'say ">" x 80'

  local test_file="${root_dir}${1}"
  local test_name="$(basename $test_file)"
  local test_dir="${target_dir}/${test_name}"

  echo "runner: Running ${test_name} in ${test_dir}..."
  mkdir -p $test_dir || echo.error "runner: Could not create ${test_dir}."
  cp $test_file $test_dir || echo.error  "runner: Could not find ${test_file}."
  pushd $test_dir
  if ! ./${test_name}; then
    echo.error "runner: 🔴 ${test_name} failed."
    popd
    perl -E 'say "<" x 80'
    return 1
  else
    echo.error "runner: 🟢 ${test_name} passed."
  fi
  popd

  perl -E 'say "<" x 80'
}
