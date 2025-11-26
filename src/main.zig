const std = @import("std");
const print = std.debug.print;
const ByteArrayList = std.ArrayList(u8);
const allocator = std.heap.page_allocator;

const ByteArrayListCtx = @import("iter.zig").ByteArrayListCtx;
const Iterator = @import("iter.zig").Iterator;

const Iter = @import("iter.zig").Iter;

fn add_1(a: u8) u8 {
    return a + 1;
}

pub fn main() !void {
    var al: ByteArrayList = ByteArrayList.init(allocator);
    defer al.deinit();

    try al.append(1);
    try al.append(2);
    try al.append(3);
    try al.append(4);

    const iterable = ByteArrayListCtx.init(al);
    const iter = Iter(ByteArrayListCtx).init(iterable);
    var map = iter.map(add_1).map(add_1);

    while (map.next()) |entry| {
        print("{d}", .{entry});
    }
}
