const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;

const adapters = @import("adapters.zig");

pub fn Iter(Ctx: type) type {
    return struct {
        ctx: Ctx,

        pub const Item = adapters.CtxItem(Ctx);

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
            const ret = while (iter.next()) |element| {
                if (f(element)) break element;
            } else null;

            iter.deinit();
            return ret;
        }
    };
}
