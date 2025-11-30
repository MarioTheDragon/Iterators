const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.testing.allocator;
const expect = std.testing.expect;

const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;
const constructors = @import("constructors.zig");
const Iter = @import("iter.zig").Iter;

const ByteArrayList = std.ArrayList(u8);
pub fn add_1(a: u8) u16 {
    return a + 1;
}

pub fn add_2(a: u16) u32 {
    return a + 2;
}

pub fn divisible_by_2(n: u16) bool {
    return n % 2 == 0;
}

pub fn greater_than_10(n: u8) bool {
    return n > 10;
}

test "basic" {
    const r = try constructors.range(u8, 1, 5);
    var iter = r.map(add_1).map(add_2).take(2);
    defer iter.deinit();

    try expect(iter.next().? == 4);
    try expect(iter.next().? == 5);
    try expect(iter.next() == null);
}

test "array_list constructor" {
    var list = ByteArrayList.init(allocator);
    try list.appendNTimes(0, 5);

    var iter = constructors.iter(list).map(add_1).map(add_2).take(2);
    defer iter.deinit();

    try expect(iter.next().? == 3);
    try expect(iter.next().? == 3);
    try expect(iter.next() == null);
}

// This test is done to see if the constructor takes the type itself as context, if it has the
// necessary declarations.
test "constructor with range as input" {
    const r = try constructors.range(u8, 1, 5);
    var iter = constructors.iter(r).map(add_1).map(add_2).take(2);
    defer iter.deinit();

    try expect(iter.next().? == 4);
    try expect(iter.next().? == 5);
    try expect(iter.next() == null);
}

test "filter" {
    const r = try constructors.range(u8, 5, 10);
    var iter = r.map(add_1).filter(divisible_by_2).map(add_2);
    defer iter.deinit();

    try expect(iter.next().? == 8);
    try expect(iter.next().? == 10);
    try expect(iter.next().? == 12);
    try expect(iter.next() == null);
}

test "find" {
    const r1 = try constructors.range(u8, 0, 20);
    const element1 = r1.find(greater_than_10);
    try expect(element1.? == 11);

    const r2 = try constructors.range(u8, 0, 10);
    const element2 = r2.find(greater_than_10);
    try expect(element2 == null);
}

test "collect" {
    const r = try constructors.range(u8, 0, 5);
    var collection = try r.collect(ArrayList(u8), allocator);
    defer collection.deinit();

    const expected_values = [_]u8{ 0, 1, 2, 3, 4 };
    var expected = ArrayList(u8).init(allocator);
    defer expected.deinit();
    try expected.appendSlice(expected_values[0..]);

    try expect(collection.items.len == expected.items.len);
    for (0..collection.items.len) |i| {
        try expect(collection.items[i] == expected.items[i]);
    }
}

test "count" {
    const r1 = try constructors.range(u8, 0, 5);
    try expect(r1.count() == 5);
    const r2 = try constructors.range(u8, 0, 20);
    try expect(r2.count() == 20);
}
