const utils = @import("utils.zig");
const CtxMappedItem = utils.CtxMappedItem;

fn default_deinit(iterator: anytype) void {
    iterator.ctx.deinit();
}

pub fn Map(Ctx: type, F: type) type {
    return struct {
        ctx: Ctx,
        apply: F,

        pub const Item = CtxMappedItem(F);
        pub const deinit = default_deinit;

        pub fn clone(self: *@This()) !@This() {
            return .{ .ctx = try self.ctx.clone(), .apply = self.apply };
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
        pub const deinit = default_deinit;

        pub fn clone(self: *@This()) !@This() {
            return .{ .ctx = try self.ctx.clone(), .n = self.n };
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
        pub const deinit = default_deinit;

        pub fn clone(self: *@This()) !@This() {
            return .{ .ctx = try self.ctx.clone(), .filter = self.filter };
        }

        pub fn next(self: *@This()) ?Item {
            while (true) {
                const next_element = self.ctx.next() orelse return null;
                if (self.filter(next_element)) return next_element;
            }
        }
    };
}

pub fn Chain(Ctx: type, ChainCtx: type) type {
    return struct {
        ctx: Ctx,
        chain_ctx: ChainCtx,

        pub const Item = Ctx.Item;

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
            self.chain_ctx.deinit();
        }

        pub fn clone(self: *@This()) !@This() {
            return .{ .ctx = try self.ctx.clone(), .chain_ctx = try self.chain_ctx.clone() };
        }

        pub fn next(self: *@This()) ?Item {
            return self.ctx.next() orelse self.chain_ctx.next();
        }
    };
}
