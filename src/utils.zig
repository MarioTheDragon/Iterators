pub fn name_starts_with(name1: []const u8, name2: []const u8) bool {
    const min = if (name1.len < name2.len) name1.len else name2.len;
    for (0..min) |i| {
        if (name1[i] != name2[i]) return false;
    }
    return true;
}

pub fn CtxItem(Ctx: type) type {
    const NextElement = @typeInfo(@TypeOf(Ctx.next)).@"fn".return_type.?;
    return @typeInfo(NextElement).optional.child;
}

pub fn CtxMappedItem(F: type) type {
    return @typeInfo(@typeInfo(F).pointer.child).@"fn".return_type.?;
}
