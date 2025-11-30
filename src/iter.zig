const std = @import("std");
const Allocator = std.mem.Allocator;

const adapters = @import("adapters.zig");
const utils = @import("utils.zig");
const name_starts_with = utils.name_starts_with;
const CtxItem = utils.CtxItem;

pub fn Iter(Ctx: type) type {
    return struct {
        ctx: Ctx,

        pub const Item = CtxItem(Ctx);

        pub fn init(data: Ctx) @This() {
            return .{ .ctx = data };
        }

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?Ctx.Item {
            return self.ctx.next();
        }

        pub fn map(self: @This(), f: anytype) Iter(adapters.Map(@TypeOf(self.ctx), *const @TypeOf(f))) {
            return .{ .ctx = .{ .ctx = self.ctx, .apply = f } };
        }

        pub fn take(self: @This(), n: usize) Iter(adapters.Take(@TypeOf(self.ctx))) {
            return .{ .ctx = .{ .ctx = self.ctx, .n = n } };
        }

        pub fn filter(self: @This(), f: *const fn (@This().Item) bool) Iter(adapters.Filter(@TypeOf(self.ctx), @TypeOf(f))) {
            return .{ .ctx = .{ .ctx = self.ctx, .filter = f } };
        }

        pub fn find(self: @This(), f: *const fn (@This().Item) bool) ?@This().Item {
            var iter = self;
            defer iter.deinit();

            while (iter.next()) |element| {
                if (f(element)) return element;
            }
            return null;
        }

        pub fn collect(self: @This(), Collection: type, comptime allocator: ?Allocator) !Collection {
            var iter = self;
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
    };
}
