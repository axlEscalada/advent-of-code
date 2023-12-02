const std = @import("std");
const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub const hash_map_numbers = map: {
    const KV = struct { []const u8, u32 };
    var kvs: [numbers.len]KV = .{};
    for (numbers, 0..) |number, i| {
        kvs[i] = .{ number, std.hash.CityHash32.hash(number) };
    }
    break :map std.ComptimeStringMap(u32, kvs);
};

pub const map_string_to_number = map: {
    const KV = struct { []const u8, u8 };
    var kvs: [numbers.len]KV = .{};
    for (numbers, 0..) |number, i| {
        kvs[i] = .{ number, i + 1 };
    }
    break :map std.ComptimeStringMap(u8, kvs);
};

pub fn main() !void {
    var input = @embedFile("input-2");
    var values: u32 = 0;
    var tokenizer = std.mem.tokenizeAny(u8, input, "\n");
    while (tokenizer.peek() != null) {
        const line = tokenizer.next().?;
        var temp: u32 = 0;
        var nums: [2]u8 = .{};
        var isFirst = true;
        std.debug.print("LINE: {s}\n", .{line});
        for (line, 0..) |i, idx| {
            temp = 0;

            // var to_idx = if (line.len - idx >= 3) idx + 3 else idx;
            if (line.len - idx >= 3) {
                for (line[idx .. idx + 3]) |id| {
                    if (std.ascii.isDigit(id)) {
                        if (isFirst) {
                            nums[0] = id;
                            nums[1] = id;
                            isFirst = false;
                        } else {
                            nums[1] = id;
                        }
                    }
                }
            } else {
                if (std.ascii.isDigit(i)) {
                    if (isFirst) {
                        nums[0] = i;
                        nums[1] = i;
                        isFirst = false;
                    } else {
                        nums[1] = i;
                    }
                }
            }
            if (line.len - idx >= 3) {
                var to = if (line.len - idx < 5) line.len - idx else 5;
                if (isStringNumber(line[idx .. idx + to])) |num| {
                    if (isFirst) {
                        nums[0] = num;
                        nums[1] = num;
                        isFirst = false;
                    } else {
                        nums[1] = num;
                    }
                }
            }
            if (idx == line.len - 1) {
                // std.debug.print("Numbers: {c}\n", .{nums});
                temp = std.fmt.parseInt(u8, &nums, 10) catch @panic("error while parsing char");
                values = values + temp;
            }
        }
    }
    std.debug.print("value: {}\n", .{values});
}

fn isStringNumber(line: []const u8) ?u8 {
    var index: usize = 0;
    var result: ?u8 = rs: {
        for (numbers, 0..) |num, i| {
            const hash = hash_map_numbers.get(num);
            _ = i;
            for (line, 0..) |li, j| {
                _ = li;

                var len = num.len;
                if (line[j..].len < len or line[j..].len < 3) break;
                const hashed = std.hash.CityHash32.hash(line[j .. j + len]);
                if (hashed == hash and j >= index) {
                    index = j;
                    var number = map_string_to_number.get(num);
                    var buf: [1]u8 = undefined;
                    var str = std.fmt.bufPrint(&buf, "{?}", .{number}) catch @panic("error while trying to parse int to string");
                    break :rs str[0];
                }
            }
        }
        break :rs null;
    };
    return result;
}

test "simple test" {}
