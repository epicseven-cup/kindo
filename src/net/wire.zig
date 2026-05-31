// Wire format — 14-byte packed WireHeader (version, msg_type, msg_id, msg_size) plus typed payload structs;
// msg_size capped at MAX_MSG_SIZE (64mb) before any allocation to prevent DoS via crafted headers

const std = @import("std");
// zig fmt: off

const MAX_MSG_SIZE = 64 * 1024 * 1024; // 64mb max msg size before any allocation to prevent DoS via crafted headers

pub const WireHeader = packed struct {
    version: u8,
    msg_type: u8,
    msg_id: u64,
    msg_size: u32
};

pub const AllocRequest = packed struct {
    size: u64,
    owner_id: u16
};

pub const AllocResponse = packed struct {
    ptr: u64,
    base: u64,
    success: u8
};

pub const AllocSlabRequest = packed struct {
    size_class: u8,
    num_slots: u32,
    owner_id: u16
};

pub const AllocSlabResponse = packed struct {
    base: u64,
    actual_slots: u32,
    success: u8
};

pub const FreeSlabRequest = packed struct {
    base: u64,
    size_class: u8,
    owner_id: u16
};

pub const ReadRequest = packed struct {
    ptr: u64,
    size: u64,
    block_base: u64
};

pub const ReadResponse = packed struct {
    success: u8
};

pub const WriteRequest = packed struct {
    ptr: u64,
    size: u64,
    block_base: u64
};

pub const WriteResponse = packed struct {
    success: u8
};

pub const FreeRequest = packed struct {
    ptr: u64,
    size: u64,
    owner_id: u16
};

pub const PingBlock = packed struct {
    ptr: u64,
    base: u64
};

pub const PingResponse = packed struct {
    exists: u8,
    owner_id: u16
};

const BatchPingRequest = struct {
    count: u32,
    ptrs: []u64
};

const BatchPingResponse = struct {
    count: u32,
    exists: []u8
};

const Message = union(enum) {
    allocRequest: AllocRequest,
    allocResponse: AllocResponse,
    allocSlabRequest: AllocSlabRequest,
    allocSlabResponse: AllocSlabResponse,
    freeSlabRequest: FreeSlabRequest,
    readRequest: ReadRequest,
    readResponse: ReadResponse,
    writeRequest: WriteRequest,
    writeResponse: WriteResponse,
    freeRequest: FreeRequest,
    pingRequest: PingBlock,
    pingResponse: PingResponse,
    batchPingRequest: BatchPingRequest,
    batchPingResponse: BatchPingResponse,
};

const MsgType = enum(u8) {
    allocRequest     = 0,
    allocResponse    = 1,
    allocSlabRequest = 2,
    allocSlabResponse = 3,
    freeSlabRequest  = 4,
    readRequest      = 5,
    readResponse     = 6,
    writeRequest     = 7,
    writeResponse    = 8,
    freeRequest      = 9,
    pingRequest      = 10,
    pingResponse     = 11,
    batchPingRequest = 12,
    batchPingResponse = 13,
    _,
};

const ParseError = error{
    UnknownMsgType,
    InvalidMessageLength,
};

const WireMessage = struct {
    header: WireHeader,
    message: Message
};

// zig fmt: on

pub fn batchPingRequestParser(request: []u8) BatchPingRequest {
    const count: u32 = std.mem.readInt(u32, request[0..@sizeOf(u32)], .little);
    const ptrs = std.mem.bytesAsSlice(u64, request[@sizeOf(u32)..]);
    return .{ .count = count, .ptrs = ptrs };
}

pub fn batchPingResponseParser(response: []u8) BatchPingResponse {
    const count = std.mem.readInt(u32, response[0..@sizeOf(u32)], .little);
    const exists = response[@sizeOf(u32)..];
    return .{
        .count = count,
        .exists = exists,
    };
}

// Why does zig format do this, makes this really hard to read man...
pub fn messageParser(buf: []u8) !WireMessage {
    if (buf.len < @sizeOf(WireHeader)) return error.InvalidMessageLength;
    const header: WireHeader = std.mem.bytesToValue(WireHeader, buf[0..@sizeOf(WireHeader)]);
    const msg_type: MsgType = @enumFromInt(header.msg_type);
    if (buf.len != @sizeOf(WireHeader) + header.msg_size) return error.InvalidMessageLength;
    const payload: []u8 = buf[@sizeOf(WireHeader)..];
    const message: Message = switch (msg_type) {
        .allocRequest => .{ .allocRequest = std.mem.bytesToValue(AllocRequest, payload[0..@sizeOf(AllocRequest)]) },
        .allocResponse => .{ .allocResponse = std.mem.bytesToValue(AllocResponse, payload[0..@sizeOf(AllocResponse)]) },
        .allocSlabRequest => .{ .allocSlabRequest = std.mem.bytesToValue(AllocSlabRequest, payload[0..@sizeOf(AllocSlabRequest)]) },
        .allocSlabResponse => .{ .allocSlabResponse = std.mem.bytesToValue(AllocSlabResponse, payload[0..@sizeOf(AllocSlabResponse)]) },
        .freeSlabRequest => .{ .freeSlabRequest = std.mem.bytesToValue(FreeSlabRequest, payload[0..@sizeOf(FreeSlabRequest)]) },
        .readRequest => .{ .readRequest = std.mem.bytesToValue(ReadRequest, payload[0..@sizeOf(ReadRequest)]) },
        .readResponse => .{ .readResponse = std.mem.bytesToValue(ReadResponse, payload[0..@sizeOf(ReadResponse)]) },
        .writeRequest => .{ .writeRequest = std.mem.bytesToValue(WriteRequest, payload[0..@sizeOf(WriteRequest)]) },
        .writeResponse => .{ .writeResponse = std.mem.bytesToValue(WriteResponse, payload[0..@sizeOf(WriteResponse)]) },
        .freeRequest => .{ .freeRequest = std.mem.bytesToValue(FreeRequest, payload[0..@sizeOf(FreeRequest)]) },
        .pingRequest => .{ .pingRequest = std.mem.bytesToValue(PingBlock, payload[0..@sizeOf(PingBlock)]) },
        .pingResponse => .{ .pingResponse = std.mem.bytesToValue(PingResponse, payload[0..@sizeOf(PingResponse)]) },
        .batchPingRequest => .{ .batchPingRequest = batchPingRequestParser(payload) },
        .batchPingResponse => .{ .batchPingResponse = batchPingResponseParser(payload) },
        _ => return error.UnknownMsgType,
    };

    return WireMessage{
        .header = header,
        .message = message,
    };
}

comptime {
    // @compileLog(@bitSizeOf(WireHeader));
    if (@bitSizeOf(WireHeader) != 112) @compileError("WireHeader size is incorrect");
    if (@sizeOf(WireHeader) != @as(usize, 16)) @compileError("WireHeader after round up size is incorrect");
}
