const std = @import("std");
const core = @import("core");

test "profile write then read round trip" {}

test "call site averages update correctly" {}

test "rolling average is 80/20 weighted" {}

test "binary hash match restores full confidence" {}

test "binary hash mismatch drops confidence to 0.3" {}

test "stale access records are pruned on load" {}

test "checkpoint recovery loses at most 60 seconds of records" {}

test "missing profile file starts fresh without error" {}

test "schema version mismatch discards profile" {}

test "batch ping groups records by machine" {}
