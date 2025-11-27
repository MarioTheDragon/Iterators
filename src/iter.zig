const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

fn ctx_element_type(ctx_type: type) type {
    const next_element_type = @typeInfo(@TypeOf(ctx_type.next)).@"fn".return_type.?;
    return @typeInfo(next_element_type).optional.child;
}

fn ctx_mapped_type(f_type: type) type {
    return @typeInfo(@typeInfo(f_type).pointer.child).@"fn".return_type.?;
}

pub const ByteArrayListCtx = struct {
    data: ByteArrayList,
    index: usize,

    const element_type = u8;

    pub fn init(data: ByteArrayList) @This() {
        return .{ .data = data, .index = 0 };
    }

    pub fn next(self: *@This()) ?u8 {
        if (self.index == self.data.items.len) return null;
        const ret = self.data.items[self.index];
        self.index += 1;
        return ret;
    }
};

fn Map(ctx_type: type, f_type: type) type {
    return struct {
        ctx: ctx_type,
        apply: f_type,

        const element_type = ctx_mapped_type(f_type);

        fn next(self: *@This()) ?element_type {
            const next_element = self.ctx.next() orelse return null;
            return self.apply(next_element);
        }
    };
}

fn Take(ctx_type: type) type {
    return struct {
        ctx: ctx_type,
        n: usize,

        const element_type = ctx_element_type(ctx_type);

        fn next(self: *@This()) ?element_type {
            if (self.n == 0) return null;
            self.n -= 1;
            return self.ctx.next();
        }
    };
}

pub fn Iter(ctx_t: type) type {
    return struct {
        ctx: ctx_t,

        pub fn init(data: ByteArrayListCtx) @This() {
            return .{ .ctx = data };
        }

        pub fn next(self: *@This()) ?u8 {
            return self.ctx.next();
        }

        pub fn map(self: @This(), f: *const fn (ctx_t.element_type) u8) Iter(Map(@TypeOf(self.ctx), @TypeOf(f))) {
            return .{ .ctx = .{ .ctx = self.ctx, .apply = f } };
        }

        pub fn take(self: @This(), n: usize) Iter(Take(@TypeOf(self.ctx))) {
            return .{ .ctx = .{ .ctx = self.ctx, .n = n } };
        }
    };
}
