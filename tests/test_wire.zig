const std = @import("std");
const core = @import("core");

test "WireHeader is exactly 14 bytes" {
   std.testing.expectEqual(@as(usize, 14), @sizeOf(WireHeader);
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
