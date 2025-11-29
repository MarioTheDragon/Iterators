fn CtxElement(Ctx: type) type {
    const NextElement = @typeInfo(@TypeOf(Ctx.next)).@"fn".return_type.?;
    return @typeInfo(NextElement).optional.child;
}

fn CtxMappedElement(F: type) type {
    return @typeInfo(@typeInfo(F).pointer.child).@"fn".return_type.?;
}

pub fn Map(Ctx: type, F: type) type {
    return struct {
        ctx: Ctx,
        apply: F,

        pub const Item = CtxMappedElement(F);

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

        pub const Item = CtxElement(Ctx);

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
