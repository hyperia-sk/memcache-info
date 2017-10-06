#!/bin/bash

. tests/assert.sh -v

src="./memcache-info"

assert_raises "$src" 0
assert_contains "$src" "Memcache Stats" 127
assert_contains "$src" "Time info" 127
assert_contains "$src" "Connection info" 127
assert_contains "$src" "Get info" 127
assert_contains "$src" "Delete info" 127
assert_contains "$src" "Memory info" 127
assert_contains "$src -r" "Memory info" 127
assert_contains "$src -p 11211" "Memory info" 127
assert_contains "$src -n localhost" "Memory info" 127
assert_contains "$src -n localhost -p 11211" "Memory info" 127

assert_end