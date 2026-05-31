const std = @import("std");
const core = @import("core");
const net = @import("net");

test "WireHeader is exactly 14 bytes" {
    // The size is 16 bytes since it is round up in runtime due to alignment
    // but we expect it to be 14 bytes in actual bytes before rounding up.
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(net.wire.WireHeader));
    try std.testing.expectEqual(112, @bitSizeOf(net.wire.WireHeader));
}

test "AllocRequest serialise/deserialise round trip" {}

test "AllocResponse serialise/deserialise round trip" {}

test "ReadRequest serialise/deserialise round trip" {}

test "ReadResponse serialise/deserialise round trip" {}

test "WriteRequest serialise/deserialise round trip" {}

test "WriteResponse serialise/deserialise round trip" {}

test "FreeRequest serialise/deserialise round trip" {}

test "BatchPingRequest serialise/deserialise round trip" {}

test "BatchPingResponse serialise/deserialise round trip" {}

test "AllocSlabRequest serialise/deserialise round trip" {}

test "FreeSlabRequest serialise/deserialise round trip" {}

test "unknown msg_type is rejected gracefully" {}

test "truncated header returns error" {}

test "payload shorter than msg_size returns error" {}
