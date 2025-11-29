const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;

const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;
const Iter = @import("iter.zig").Iter;
const range = @import("constructors.zig").range;

pub fn add_1(a: u8) u16 {
    return a + 1;
}

pub fn add_2(a: u16) u32 {
    return a + 2;
}

test "basic" {
    const r = try range(u8, 1, 5);
    var iter = r.map(add_1).map(add_2).take(2);
    defer iter.deinit();

    try expect(iter.next().? == 4);
    try expect(iter.next().? == 5);
    try expect(iter.next() == null);
}
