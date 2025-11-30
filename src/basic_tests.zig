const std = @import("std");
const ByteArrayList = std.ArrayList(u8);
const ArrayList = std.ArrayList;

const allocator = std.testing.allocator;
const expect = std.testing.expect;

const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;
const Iter = @import("iter.zig").Iter;
const constructors = @import("constructors.zig");

pub fn add_1(a: u8) u16 {
    return a + 1;
}

pub fn add_2(a: u16) u32 {
    return a + 2;
}

pub fn divisible_by_2(n: u16) bool {
    return n % 2 == 0;
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