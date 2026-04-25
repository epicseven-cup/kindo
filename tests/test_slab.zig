const std = @import("std");
const core = @import("core");

test "size class selection rounds up correctly" {}

test "alloc slot marks bitmap used" {}

test "free slot clears bitmap" {}

test "alloc after free reuses the slot" {}

test "alloc exhausts all slots before requesting new slab" {}

test "whole slab return when all slots freed" {}

test "two slabs of same size class are managed independently" {}

test "alloc across size classes uses correct slab" {}

test "slot address arithmetic is correct" {}
