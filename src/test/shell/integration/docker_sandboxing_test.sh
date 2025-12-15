#!/usr/bin/env bash
#
# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Test sandboxing spawn strategy
#

set -euo pipefail

# Load the test setup defined in the parent directory
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CURRENT_DIR}/../integration_test_setup.sh" \
  || { echo "integration_test_setup.sh not found!" >&2; exit 1; }

function set_up() {
  add_to_bazelrc "build --experimental_enable_docker_sandbox"
  add_to_bazelrc "build --experimental_docker_verbose"
  add_to_bazelrc "build --experimental_docker_sandbox_use_symlinks"
  add_to_bazelrc "build --experimental_docker_image=debian:trixie"
  add_to_bazelrc "build --spawn_strategy=docker"
  add_to_bazelrc "build --genrule_strategy=docker"

  # Enabled in testenv.sh.tmpl, but not in Bazel by default.
  sed -i.bak '/sandbox_tmpfs_path/d' "$bazelrc"
}

function tear_down() {
  bazel clean --expunge
  bazel shutdown
  rm -rf pkg
}

function test_sandbox_local_used_with_proper_strategy() {
  mkdir pkg
  cat >pkg/BUILD <<EOF
genrule(name = "pkg", outs = ["pkg.out"], cmd = "pwd; echo >\$@",
  tags = ["no-sandbox"])
EOF

  local output_base="$(bazel info output_base)"
  local sandbox_base="${output_base}/sandbox"
  rm -rf ${sandbox_base}

  bazel build --genrule_strategy=sandboxed,standalone //pkg \
    >"${TEST_log}" 2>&1 || fail "Expected build to succeed"

  expect_not_log "${output_base}.*/sandbox/"
}

function test_sandboxed_genrule() {
  mkdir -p examples/genrule
  cat << 'EOF' > examples/genrule/a.txt
foo bar bz
EOF
  cat << 'EOF' > examples/genrule/BUILD
genrule(
  name = "works",
  srcs = [ "a.txt" ],
  outs = [ "works.txt" ],
  cmd = "wc $(location :a.txt) > $@",
)
EOF

  output_base=$(bazel info | grep output_base | sed 's/output_base: \(.*\)/\1/g')
  bazel build --sandbox_add_mount_pair=${PWD}:${PWD} --sandbox_add_mount_pair=${output_base}:${output_base} examples/genrule:works &> $TEST_log \
    || fail "Hermetic genrule failed: examples/genrule:works"
  [ -f "bazel-genfiles/examples/genrule/works.txt" ] \
    || fail "Genrule did not produce output: examples/genrule:works"
}

run_suite "sandboxing"
