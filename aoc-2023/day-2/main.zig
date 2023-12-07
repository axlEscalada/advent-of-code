const std = @import("std");

const map_colors = blk: {
    const KV = struct { []const u8, u16 };
    var kv: [3]KV = [_]KV{ .{ "red", 12 }, .{ "green", 13 }, .{ "blue", 14 } };
    break :blk std.ComptimeStringMap(u16, kv);
};

pub fn main() void {
    const file = @embedFile("input-1");
    // std.debug.print("{s}\n", .{file});
    var lines = std.mem.tokenizeAny(u8, file, "\n");
    var sumGames: usize = 0;
    while (lines.next()) |line| {
        var colon = indexOf(line, ':').?;
        var games = line[0..colon];
        var gameNumber = getNumber(games);
        var cubes = line[colon + 1 ..];
        var red: usize = 0;
        var blue: usize = 0;
        var green: usize = 0;
        var it = std.mem.tokenizeAny(u8, cubes, ";");
        while (it.next()) |colors| {
            var itr = std.mem.tokenizeAny(u8, colors, ",");
            while (itr.next()) |color| {
                var number = getNumber(color);
                if (contains(color, "red") and red < number) {
                    red = number;
                } else if (contains(color, "blue") and blue < number) {
                    blue = number;
                } else if (contains(color, "green") and green < number) {
                    green = number;
                }
            }
        }
        if (map_colors.get("red").? >= red and map_colors.get("blue").? >= blue and
            map_colors.get("green").? >= green)
        {
            // std.debug.print("GAME: {}\n", .{gameNumber});
            sumGames = sumGames + gameNumber;
        }
        // std.debug.print("Blue {} Green {} Red {}\n", .{ blue, green, red });
        // std.debug.print("Games: {s} | cubes: {s}\n", .{ games, cubes });
    }
    std.debug.print("SUM GAMES: {}\n", .{sumGames});
}

fn contains(target: []const u8, match: []const u8) bool {
    for (target, 0..) |t, i| {
        if (t == match[0]) {
            for (match, 0..) |source, idx| {
                if (target[i..].len >= match.len and source != target[i + idx]) return false;
            }
            return true;
        }
    }
    return false;
}

fn getNumber(target: []const u8) u16 {
    for (target, 0..) |t, i| {
        if (std.ascii.isDigit(t)) {
            for (target[i..], 0..) |n, idx| {
                if (i + idx == target.len - 1) {
                    return std.fmt.parseInt(u16, target[i..], 10) catch @panic("error while parsing to int");
                }
                if (!std.ascii.isDigit(n)) {
                    return std.fmt.parseInt(u16, target[i .. i + idx], 10) catch @panic("error while parsing to int");
                }
            }
        }
    }
    unreachable;
}

fn indexOf(target: []const u8, char: u8) ?usize {
    for (target, 0..) |t, i| {
        if (t == char) return i;
    }
    return null;
}

// fn getNumber(line: []const u8) u16 {
//     var start = 0;
//     for (line, 0..) |l, i| {
//         if (std.ascii.isDigit(l)) {
//             start = i;
//             break;
//         }
//     }

//     return std.fmt.parseInt(u8, &line[], 10) catch @panic("error while parsing char");
// }
