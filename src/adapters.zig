fn CtxElement(Ctx: type) type {
    const next_element_type = @typeInfo(@TypeOf(Ctx.next)).@"fn".return_type.?;
    return @typeInfo(next_element_type).optional.child;
}

fn CtxMappedElement(F: type) type {
    return @typeInfo(@typeInfo(F).pointer.child).@"fn".return_type.?;
}

pub fn Map(ctx_type: type, f_type: type) type {
    return struct {
        ctx: ctx_type,
        apply: f_type,

        pub const Item = CtxMappedElement(f_type);

        pub fn deinit(self: *@This()) void {
            self.ctx.deinit();
        }

        pub fn next(self: *@This()) ?Item {
            const next_element = self.ctx.next() orelse return null;
            return self.apply(next_element);
        }
    };
}

pub fn Take(ctx_type: type) type {
    return struct {
        ctx: ctx_type,
        n: usize,

        pub const Item = CtxElement(ctx_type);

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
