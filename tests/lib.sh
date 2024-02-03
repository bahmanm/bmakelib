####################################################################################################
# Copyright © Bahman Movaqar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####################################################################################################

####################################################################################################
# bmakelib.test.cat.error FILENAME LINE_PREFIX
####################################################################################################
function bmakelib.test.cat.error {
  while read -r line; do
    bmakelib.test.echo.error "$2$line"
  done < $1
}

####################################################################################################
# bmakelib.test.cat FILENAME
####################################################################################################
function bmakelib.test.cat {
  cat "$@"
}

####################################################################################################
# bmakelib.test.echo.error MSG
####################################################################################################
function bmakelib.test.echo.error {
  echo -e "$@" >&2
}

####################################################################################################
# echo MSG
####################################################################################################
function bmakelib.test.echo {
  echo -e "$@"
}

####################################################################################################
# bmakelib.test.pushd DIR
####################################################################################################
function bmakelib.test.pushd {
  command pushd "$@" > /dev/null
}

####################################################################################################
# bmakelib.test.popd DIR
####################################################################################################
function bmakelib.test.popd {
  command popd "$@" > /dev/null
}

####################################################################################################
# run_a_test_suite TEST_SUITE
#
# Globals:
#   target_dir
#   root_dir
####################################################################################################
function bmakelib.test.run_test_suite {
  perl -E 'say ">" x 80'

  local test_file="${root_dir}${1}"
  local test_suite_name="$(basename $test_file)"
  local test_dir="${target_dir}/${test_suite_name}"

  bmakelib.test.echo "runner: Running ${test_suite_name} in ${test_dir}..."
  mkdir -p $test_dir || bmakelib.test.echo.error "runner: Could not create ${test_dir}."
  cp $test_file $test_dir || bmakelib.test.echo.error  "runner: Could not find ${test_file}."
  bmakelib.test.pushd $test_dir
  if ! ./${test_suite_name}; then
    bmakelib.test.echo.error "runner: 🔴 ${test_suite_name} failed."
    bmakelib.test.popd
    perl -E 'say "<" x 80'
    return 1
  else
    bmakelib.test.echo "runner: 🟢 ${test_suite_name} passed."
  fi
  bmakelib.test.popd

  perl -E 'say "<" x 80'
}


####################################################################################################
# bmakelib.test.run_test_case TEST_CASE_NAME
####################################################################################################

function bmakelib.test.run_test_case {
  local test_case_name=$1
  perl -E 'say ">" x 40'
  bmakelib.test.echo "${test_suite_name}: running ${test_case_name}..."
  if ${1}; then
    bmakelib.test.echo "${test_suite_name}: ${test_case_name} passed."
    perl -E 'say "<" x 40'
    return 0
  else
    bmakelib.test.echo.error "${test_suite_name}: ERROR: ${test_case_name} failed."
    perl -E 'say "<" x 40'
    return 1
  fi
}

####################################################################################################
# bmakelib.test.assert_matches ACTUAL_VALUE_FILENAME EXPECTED_PATTERN_FILENAME
####################################################################################################

function bmakelib.test.assert_matches {
  local test_case_name=$1
  local actual_value_filename=$2
  local expected_pattern_filename=$3
  local perl_script=$(bmakelib.test.cat <<'EOF'
open my $afh, '<', shift or die $!;
my $actual = do { local $/; <$afh> };
close $afh;

open my $efh, '<', shift or die $!;
my $expected = do { local $/; <$efh> };
close $efh;

exit 1 if $actual !~ /^${expected}$/g;
EOF
        )

  if ! perl -E "$perl_script" $actual_value_filename $expected_pattern_filename; then
    bmakelib.test.echo.error "${test_case_name}: ERROR at $(basename ${BASH_SOURCE[1]}):${BASH_LINENO}"
    bmakelib.test.echo.error "${test_case_name}: actual result does not match the expected pattern."
    bmakelib.test.echo.error "${test_case_name}: Received:"
    bmakelib.test.cat.error $actual_value_filename "    "
    bmakelib.test.echo.error "${test_case_name}: Expected:"
    bmakelib.test.cat.error $expected_pattern_filename "    "
    return 1
  fi
}

####################################################################################################
# bmakelib.test.assert_equals_number ACTUAL_NUMBER EXPECTED_NUMBER
####################################################################################################

function bmakelib.test.assert_equals_number {
  local actual=$1
  local expected=$2

  if [[ $actual -ne $expected ]]; then
    bmakelib.test.echo.error "${test_case_name}: ERROR: value is not equal to the  expected value."
    bmakelib.test.echo.error "${test_case_name}: Received:"
    bmakelib.test.echo.error $actual
    bmakelib.test.echo.error "${test_case_name}: But expected:"
    bmakelib.test.echo.error $expected
    return 1
  fi
}
