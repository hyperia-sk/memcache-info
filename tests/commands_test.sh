#!/bin/bash

export GREP="grep"
. tests/assert.sh -v

src="./memcache-info"

assert_raises "$src" 0
assert_contains "$src -h" "memcache-info" 
assert_contains "$src" "Memcache Stats" 
assert_contains "$src" "Time info" 
assert_contains "$src" "Connection info" 
assert_contains "$src" "Get info" 
assert_contains "$src" "Delete info" 
assert_contains "$src" "Memory info" 
assert_contains "$src -r" "Memory info" 
assert_contains "$src -p 11211" "Memory info" 
assert_contains "$src -n localhost" "Memory info" 
assert_contains "$src -n localhost -p 11211" "Memory info" 

assert_end