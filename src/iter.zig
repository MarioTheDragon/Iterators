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

fn Map(data_type: type, f_type: type) type {
    return struct {
        data: data_type,
        apply: f_type,

        fn next(self: *@This()) ?u8 {
            const next_element = self.data.next() orelse return null;
            return self.apply(next_element);
        }
    };
}

fn Take(data_type: type) type {
    return struct {
        data: data_type,
        current_idx: usize = 0,
        n: usize,

        fn next(self: *@This()) ?u8 {
            if (self.current_idx == self.n) return null;
            self.current_idx += 1;
            return self.data.next();
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

        pub fn map(self: @This(), f: *const fn (u8) u8) Iter(Map(@TypeOf(self.ctx), @TypeOf(f))) {
            return .{ .ctx = .{ .data = self.ctx, .apply = f } };
        }

        pub fn take(self: @This(), n: usize) Iter(Take(@TypeOf(self.ctx))) {
            return .{ .ctx = .{ .data = self.ctx, .n = n } };
        }
    };
}
