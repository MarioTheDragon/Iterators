const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const Iter = @import("iter.zig").Iter;
const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;

pub fn range(T: type, start: T, stop: T) !Iter(ArrayListCtx(ArrayList(T))) {
    var list: ArrayList(T) = ArrayList(T).init(allocator);
    var counter: T = start;

    while (counter != stop) {
        try list.append(counter);
        if (start < stop) counter += 1 else counter -= 1;
    }

    return Iter(ArrayListCtx(ArrayList(T))).init(ArrayListCtx(ArrayList(T)).init(list));
}
