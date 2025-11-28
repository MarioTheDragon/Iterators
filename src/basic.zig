const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;
const test_utils = @import("test_utils.zig");

const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;
const Iter = @import("iter.zig").Iter;
const range = @import("constructors.zig").range;

test "basic" {
    const r = try range(u8, 1, 5);
    var iter = r.map(test_utils.add_1).map(test_utils.add_2).take(2);
    defer iter.deinit();

    try expect(iter.next().? == 4);
    try expect(iter.next().? == 5);
    try expect(iter.next() == null);
}
