const std = @import("std");
const ByteArrayList = std.ArrayList(u8);

pub const ByteArrayListCtx = struct {
    data: ByteArrayList,
    index: usize,

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

fn apply(element: u8) u8 {
    return element;
}

fn Ctx(data_type: type, f_type: type) type {
    return struct {
        data: data_type,
        apply: f_type,

        fn next(self: *@This()) ?u8 {
            const next_element = self.data.next() orelse return null;
            return self.apply(next_element);
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

        pub fn map(self: @This(), f: *const fn (u8) u8) Iter(Ctx(@TypeOf(self.ctx), @TypeOf(f))) {
            return .{ .ctx = .{ .data = self.ctx, .apply = f } };
        }
    };
}
