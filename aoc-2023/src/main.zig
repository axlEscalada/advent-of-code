const std = @import("std");

pub fn main() !void {
    var input = @embedFile("input-1");
    var values: u32 = 0;
    var tokenizer = std.mem.tokenizeAny(u8, input, "\n");
    while (tokenizer.peek() != null) {
        const line = tokenizer.next().?;
        var temp: u32 = 0;
        var nums: [2]u8 = .{};
        var isFirst = true;
        for (line, 0..) |i, idx| {
            temp = 0;
            if (std.ascii.isDigit(i)) {
                if (isFirst) {
                    nums[0] = i;
                    nums[1] = i;
                    isFirst = false;
                } else {
                    nums[1] = i;
                }
            }
            if (idx == line.len - 1) {
                temp = std.fmt.parseInt(u8, &nums, 10) catch @panic("error while parsing char");
                values = values + temp;
            }
        }
    }
    std.debug.print("value: {}\n", .{values});
}

test "simple test" {}
