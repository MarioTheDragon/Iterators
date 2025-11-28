const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

const allocator = std.testing.allocator;
const expect = std.testing.expect;
const test_utils = @import("test_utils.zig");

fn CtxElement(ctx_type: type) type {
    const next_element_type = @typeInfo(@TypeOf(ctx_type.next)).@"fn".return_type.?;
    return @typeInfo(next_element_type).optional.child;
}

fn CtxMappedElement(f_type: type) type {
    return @typeInfo(@typeInfo(f_type).pointer.child).@"fn".return_type.?;
}

fn Map(ctx_type: type, f_type: type) type {
    return struct {
        ctx: ctx_type,
        apply: f_type,

        const Item = CtxMappedElement(f_type);

        fn next(self: *@This()) ?Item {
            const next_element = self.ctx.next() orelse return null;
            return self.apply(next_element);
        }
    };
}

fn Take(ctx_type: type) type {
    return struct {
        ctx: ctx_type,
        n: usize,

        const Item = CtxElement(ctx_type);

        fn next(self: *@This()) ?Item {
            if (self.n == 0) return null;
            self.n -= 1;
            return self.ctx.next();
        }
    };
}

pub fn Iter(ctx_t: type) type {
    return struct {
        ctx: ctx_t,

        pub fn init(data: ctx_t) @This() {
            return .{ .ctx = data };
        }

        pub fn next(self: *@This()) ?ctx_t.Item {
            return self.ctx.next();
        }

        pub fn map(self: @This(), f: anytype) Iter(Map(@TypeOf(self.ctx), *const @TypeOf(f))) {
            return .{ .ctx = .{ .ctx = self.ctx, .apply = f } };
        }

        pub fn take(self: @This(), n: usize) Iter(Take(@TypeOf(self.ctx))) {
            return .{ .ctx = .{ .ctx = self.ctx, .n = n } };
        }
    };
}
