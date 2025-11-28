const ByteArrayList = @import("std").ArrayList(u8);

pub const ByteArrayListCtx = struct {
    data: ByteArrayList,
    index: usize,

    const Item = u8;

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
