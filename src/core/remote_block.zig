// RemoteBlock(T) — comptime generic wrapper returned by alloc(); exposes
// read/write/copyInto/copyFrom/slice; ptr encodes machine_id in top 16 bits
// and the absolute header address in the bottom 48 bits

const BlockHeader = @import("block_header.zig").BlockHeader;

pub fn RemoteBlock(comptime T: type) type {
    return struct {
        ptr: u64,    // machine_id (top 16) | header address (bottom 48)
        len: usize,  // number of T elements

        const Self = @This();

        pub fn read(self: Self, index: usize) !T {
            if (index >= self.len) return error.OutOfBounds;
            const addr = self.payloadAddr(index);
            return @as(*const T, @ptrCast(@alignCast(@as([*]u8, @ptrFromInt(addr))))).*;
        }

        pub fn write(self: Self, index: usize, val: T) !void {
            if (index >= self.len) return error.OutOfBounds;
            const addr = self.payloadAddr(index);
            @as(*T, @ptrCast(@alignCast(@as([*]u8, @ptrFromInt(addr))))).* = val;
        }

        pub fn copyInto(self: Self, start: usize, dest: []T) !void {
            for (dest, 0..) |*slot, i| slot.* = try self.read(start + i);
        }

        pub fn copyFrom(self: Self, start: usize, src: []const T) !void {
            for (src, 0..) |val, i| try self.write(start + i, val);
        }

        pub fn slice(self: Self, from: usize, to: usize) Self {
            return .{
                .ptr = self.ptr + @as(u64, from) * @sizeOf(T),
                .len = to - from,
            };
        }

        pub fn isLocal(self: Self) bool {
            return (self.ptr >> 48) == 0;
        }

        pub fn isRemote(self: Self) bool {
            return !self.isLocal();
        }

        // Returns the absolute address of the BlockHeader for this block.
        pub fn headerAddr(self: Self) usize {
            return @as(usize, @intCast(self.ptr & 0x0000_FFFF_FFFF_FFFF));
        }

        fn payloadAddr(self: Self, index: usize) usize {
            return self.headerAddr() + @sizeOf(BlockHeader) + index * @sizeOf(T);
        }
    };
}
