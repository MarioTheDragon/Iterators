const ArrayList = @import("std").ArrayList;

pub fn ArrayListCtx(array_list_type: type) type {
    const Inner = @typeInfo(@TypeOf(array_list_type.getLast)).@"fn".return_type.?;

    return struct {
        data: ArrayList(Inner),
        index: usize,

        pub const Item = Inner;

        pub fn init(data: ArrayList(Item)) @This() {
            return .{ .data = data, .index = 0 };
        }

        pub fn next(self: *@This()) ?Item {
            if (self.index == self.data.items.len) return null;
            const ret = self.data.items[self.index];
            self.index += 1;
            return ret;
        }
    };
}
