const std = @import("std");
const Allocator = std.mem.Allocator;

const utils = @import("utils.zig");
const name_starts_with = utils.name_starts_with;
const CtxItem = utils.CtxItem;

pub fn collect(iterator: anytype, Collection: type, comptime allocator: ?Allocator) !Collection {
    var iter = iterator;
    defer iter.deinit();

    const type_name = @typeName(Collection);

    if (comptime name_starts_with(type_name, "array_list.ArrayListAligned")) {
        const alloc = allocator orelse @compileError("Arraylist requires an allocator");
        var collection = Collection.init(alloc);
        while (iter.next()) |element| {
            try collection.append(element);
        }
        return collection;
    } else {
        @compileError("Type not supported");
    }
}

pub fn find(iterator: anytype, f: *const fn (@TypeOf(iterator).Item) bool) ?@TypeOf(iterator).Item {
    var iter = iterator;
    defer iter.deinit();

    while (iter.next()) |element| {
        if (f(element)) return element;
    }
    return null;
}

pub fn count(iterator: anytype) usize {
    var iter = iterator;
    defer iter.deinit();

    var counter: usize = 0;
    while (iter.next()) |_| {
        counter += 1;
    }
    return counter;
}
