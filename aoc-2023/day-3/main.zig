const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    var allocator = arena_instance.allocator();

    const files = @embedFile("input-1");
    var sum: u64 = 0;

    var lines = std.mem.tokenizeAny(u8, files, "\n");
    var i: usize = 0;
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer symbols.deinit();
    var numbers = std.ArrayList(*Number).init(allocator);
    defer numbers.deinit();
    while (lines.peek() != null) : (i = i + 1) {
        if (lines.next()) |line| {
            var end_of_num: usize = 0;
            for (line, 0..) |l, idx| {
                // std.debug.print("Line: {} IDX:{} num IDX: {}\n", .{ i, idx, end_of_num });
                if (end_of_num > 0 and end_of_num > idx) continue;
                if (!std.ascii.isDigit(l) and l != '.') {
                    var symbol = Symbol{ .index = idx, .line = i, .symbol = l };
                    symbols.append(symbol) catch @panic("Error while storing symbol");
                } else if (std.ascii.isDigit(l)) {
                    var start = idx;
                    for (line[idx..], 0..) |num, num_i| {
                        end_of_num = idx + num_i;
                        if (!std.ascii.isDigit(num) or idx + num_i == line.len) {
                            // std.debug.print("END: {}\n", .{end_of_num});
                            // end_of_num = 0;
                            var parsed = std.fmt.parseInt(u32, line[idx .. idx + num_i], 10) catch @panic("error while parsing to number");
                            var number = allocator.create(Number) catch @panic("error while alloc number");
                            number.* = Number{ .line = i, .start = start, .end = idx + num_i - 1, .number = parsed, .already_sum = false };
                            numbers.append(number) catch @panic("error while trying to store a number");
                            break;
                        }
                    }
                }
            }
        }
    }
    var slice = symbols.toOwnedSlice() catch @panic("error while getting slice");
    defer allocator.free(slice);
    var num_slice = numbers.toOwnedSlice() catch @panic("error while gettin numbers slice");
    defer allocator.free(num_slice);
    // std.debug.print("LEN: {}\n", .{slice.len});

    for (slice) |s| {
        std.debug.print("Symbol {} char {c}\n", .{ s, s.symbol });
        for (num_slice) |num| {
            // std.debug.print("INDEX SYM: {} SYM LINE: {} NUM LINE: {} NUM START: {} NUM END: {} NUM: {}\n", .{ s.index, s.line, num.line, num.start, num.end, num.number });
            // if (!num.already_sum and num.number == 734) {
            //     std.debug.print("sym: {} idx: {} IS 734: {}, is line: {}\n", .{ s.symbol, s.index, s.index == num.start - 1, s.line == num.line });
            // }
            if (!num.already_sum) {
                //should match cases:  100= or =100... or ..100=
                if (s.line == num.line) {
                    // std.debug.print("NUMBNERS INLINE: {} lit {}\n", .{ num, num.number });
                    if (s.index == num.end + 1) {
                        //case -> ...100=
                        std.debug.print("NUMBNERS INLINE: {} lit {}\n", .{ num, num.number });
                        sum = sum + num.number;
                        num.already_sum = true;
                    } else if (num.start > 0 and s.index == num.start - 1) {
                        //case -> =100
                        std.debug.print("NUMBNERS INLINE: {} lit {}\n", .{ num, num.number });
                        sum = sum + num.number;
                        num.already_sum = true;
                    }
                    // else if (num.start == 0 and s.index == num.start) {
                    //     //case ->
                    //     std.debug.print("NUMBNERS INLINE: {} lit {}\n", .{ num, num.number });
                    //     sum = sum + num.number;
                    //     num.already_sum = true;
                    // }
                }
                //should match case:
                // 830...59
                // ...*..*..
                if ((num.start == 0 and s.index >= num.start and s.index <= num.end + 1) or (num.start > 0 and s.index >= num.start - 1 and s.index <= num.end + 1)) {
                    if (s.line == num.line + 1 or (num.line > 0 and s.line == num.line - 1)) {
                        std.debug.print("NUMBNERS: {} lit {}\n", .{ num, num.number });
                        sum = sum + num.number;
                        num.already_sum = true;
                    }
                }
            }
        }
    }
    std.debug.print("NUMBER: {}\n", .{sum});
}

const Symbol = struct {
    index: usize,
    line: usize,
    symbol: u8,
};

const Number = struct {
    line: usize,
    start: usize,
    end: usize,
    number: u32,
    already_sum: bool,
};
