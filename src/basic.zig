const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;
const test_utils = @import("test_utils.zig");

const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;
const Iter = @import("iter.zig").Iter;
const range = @import("constructors.zig").range;

test "basic" {
    const iter = try range(u8, 1, 5);
    // var al: ByteArrayList = ByteArrayList.init(allocator);
    // defer al.deinit();
    //
    // try al.append(1);
    // try al.append(2);
    // try al.append(3);
    //
    // const iterable = ArrayListCtx(ByteArrayList).init(al);
    // const iter = Iter(ArrayListCtx(ByteArrayList)).init(iterable);
    var map = iter.map(test_utils.add_1).map(test_utils.add_2).take(2);

    try expect(map.next().? == 4);
    try expect(map.next().? == 5);
    try expect(map.next() == null);
}
