const std = @import("std");
const core = @import("core");

test "bump pointer alloc returns distinct blocks" {}

test "bump pointer respects block header size" {}

test "free list reuse after free" {}

test "thread local chunk exhaustion refills from main pool" {}

test "bounds check on read past block end" {}

test "bounds check on write past block end" {}

test "read/write round trip on local block" {}

test "slice sub-region addresses are correct" {}

test "isLocal returns true for local blocks" {}
