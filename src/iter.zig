const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;

const adapters = @import("adapters.zig");

pub fn Iter(ctx_t: type) type {
    return struct {
        ctx: ctx_t,

        pub fn init(data: ctx_t) @This() {
            return .{ .ctx = data };
        }

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?ctx_t.Item {
            return self.ctx.next();
        }

        pub fn map(self: @This(), f: anytype) Iter(adapters.Map(@TypeOf(self.ctx), *const @TypeOf(f))) {
            return .{ .ctx = .{ .ctx = self.ctx, .apply = f } };
        }

        pub fn take(self: @This(), n: usize) Iter(adapters.Take(@TypeOf(self.ctx))) {
            return .{ .ctx = .{ .ctx = self.ctx, .n = n } };
        }
    };
}
