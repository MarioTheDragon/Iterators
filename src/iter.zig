const std = @import("std");
const Allocator = std.mem.Allocator;

const adapters = @import("adapters.zig");
const consumers = @import("consumers.zig");
const name_starts_with = @import("utils.zig").name_starts_with;

pub fn Iter(Ctx: type) type {
    return struct {
        ctx: Ctx,

        pub const Item = Ctx.Item;

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
            return consumers.find(self, f);
        }

        pub fn collect(self: @This(), Collection: type, comptime allocator: ?Allocator) !Collection {
            return consumers.collect(self, Collection, allocator);
        }

        pub fn count(self: @This()) usize {
            return consumers.count(self);
        }
    };
}
