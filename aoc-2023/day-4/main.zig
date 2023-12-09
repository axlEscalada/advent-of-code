const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    const file = @embedFile("input-1");
    var it = std.mem.tokenizeAny(u8, file, "\n");
    var sum: u32 = 0;
    while (it.next()) |line| {
        var total_winnings: u8 = 0;
        print("{s}\n", .{line});
        var start = indexOf(line, ':').?;
        var idx = indexOf(line, '|').?;
        var buffer_winnings: [10]u8 = [_]u8{0} ** 10;
        var winning_numbers = parseNumbers(line[start..idx], &buffer_winnings);
        var my_buffer: [30]u8 = [_]u8{0} ** 30;
        var my_numbers = parseNumbers(line[idx..], &my_buffer);
        for (winning_numbers) |w| {
            // print("WINNINGS: {}\n", .{w});
            for (my_numbers) |m| {
                // print("MYNUM {}\n", .{m});
                if (m == w) {
                    print("NUM EQL: {} {}\n", .{ m, w });
                    total_winnings = total_winnings + 1;
                }
            }
        }
        var total = sumWinnings(total_winnings, 1);
        print("TOTAL: {}\n", .{total});
        sum = sum + total;
    }
    print("SUM: {}\n", .{sum});
}

fn sumWinnings(winnings: u8, total: u32) u32 {
    // print("TOTAL: {} SUM: {}\n", .{ winnings, total });
    if (winnings == 0) return winnings;
    if (winnings == 1) return total;
    return sumWinnings(winnings - 1, total * 2);
}

fn parseNumbers(source: []const u8, buffer: []u8) []u8 {
    // print("SOURCE: {s}\n", .{source});
    var size: usize = 0;
    var skip_to: usize = 0;

    for (source, 0..) |s, i| {
        if (skip_to >= i) continue;
        if (std.ascii.isDigit(s)) {
            for (source[i..], 0..) |num, idx| {
                _ = num;
                var num_idx = i + idx + 1;
                if (i + idx == source.len - 1 or !std.ascii.isDigit(source[num_idx])) {
                    // print("NUM {s}\n", .{source[i .. i + idx + 1]});
                    var number = std.fmt.parseInt(u8, source[i..num_idx], 10) catch @panic("error while parsing");
                    buffer[size] = number;
                    size = size + 1;
                    skip_to = i + idx;
                    break;
                }
            }
        }
    }
    return buffer[0..size];
}

fn indexOf(target: []const u8, char: u8) ?usize {
    for (target, 0..) |t, i| {
        if (t == char) return i;
    }
    return null;
}
