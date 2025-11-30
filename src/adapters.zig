const utils = @import("utils.zig");
const CtxMappedItem = utils.CtxMappedItem;

pub fn Map(Ctx: type, F: type) type {
    return struct {
        ctx: Ctx,
        apply: F,

        pub const Item = CtxMappedItem(F);

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?Item {
            const next_element = self.ctx.next() orelse return null;
            return self.apply(next_element);
        }
    };
}

pub fn Take(Ctx: type) type {
    return struct {
        ctx: Ctx,
        n: usize,

        pub const Item = Ctx.Item;

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?Item {
            if (self.n == 0) return null;
            self.n -= 1;
            return self.ctx.next();
        }
    };
}

pub fn Filter(Ctx: type, F: type) type {
    return struct {
        ctx: Ctx,
        filter: F,

        pub const Item = Ctx.Item;

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?Item {
            while (true) {
                const next_element = self.ctx.next() orelse return null;
                if (self.filter(next_element)) return next_element;
            }
        }
    };
}
