const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const name_starts_with = @import("utils.zig").name_starts_with;

const Iter = @import("iter.zig").Iter;
const ArrayListCtx = @import("base_contexts.zig").ArrayListCtx;

fn BaseCtx(T: type) type {
    const type_name = @typeName(T);

    if (name_starts_with(type_name, "array_list.ArrayListAligned")) return ArrayListCtx(T);
    if (@hasDecl(T, "next") and @hasDecl(T, "Item")) return T;

    @compileError("Type is not supported.");
}

pub fn iter(iterable: anytype) Iter(BaseCtx(@TypeOf(iterable))) {
    const Ctx = BaseCtx(@TypeOf(iterable));
    if (Ctx == @TypeOf(iterable)) {
        return Iter(Ctx).init(iterable);
    } else {
        return Iter(Ctx).init(Ctx.init(iterable));
    }
}

pub fn range(T: type, start: T, stop: T) !Iter(ArrayListCtx(ArrayList(T))) {
    var list: ArrayList(T) = ArrayList(T).init(allocator);
    var counter: T = start;

    while (counter != stop) {
        try list.append(counter);
        if (start < stop) counter += 1 else counter -= 1;
    }

    return .{ .ctx = .{ .data = list } };
}
