const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    var allocator = arena_instance.allocator();

    const files = @embedFile("input-1");

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
                if (end_of_num > 0 and (end_of_num > idx or end_of_num == line.len - 1)) continue;
                if (!std.ascii.isDigit(l) and l != '.') {
                    var symbol = Symbol{ .index = idx, .line = i, .symbol = l };
                    symbols.append(symbol) catch @panic("Error while storing symbol");
                } else if (std.ascii.isDigit(l)) {
                    var start = idx;
                    for (line[idx..], 0..) |num, num_i| {
                        end_of_num = idx + num_i;
                        // var str_number = if(end_of_num == line.len - 1) line[idx..] else line[idx..end_of_num];
                        //TODO: refactor duplicate
                        if (!std.ascii.isDigit(num)) {
                            var parsed = std.fmt.parseInt(u32, line[idx..end_of_num], 10) catch @panic("error while parsing to number");
                            var number = allocator.create(Number) catch @panic("error while alloc number");
                            number.* = Number{ .line = i, .start = start, .end = idx + num_i - 1, .number = parsed, .already_sum = false };
                            numbers.append(number) catch @panic("error while trying to store a number");
                            break;
                        } else if (end_of_num == line.len - 1) {
                            var parsed = std.fmt.parseInt(u32, line[idx..], 10) catch @panic("error while parsing to number");
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

    var sum: u64 = 0;
    var gear: u64 = 0;
    for (slice) |s| {
        var slice_sum: u32 = 0;
        var sum_gear: u64 = 0;
        var multiplied_gear: ?u32 = null;
        for (num_slice) |num| {
            if (num.already_sum) continue;
            if (isSameLineAndAdjacent(s, num.*) or isAdjacent(s, num.*)) {
                if (s.symbol == '*' and multiplied_gear == null) {
                    multiplied_gear = num.number;
                    slice_sum = slice_sum + num.number;
                } else if (s.symbol == '*') {
                    sum_gear = multiplied_gear.? * num.number;
                    slice_sum = 0;
                } else {
                    slice_sum = slice_sum + num.number;
                }
                num.already_sum = true;
            }
        }
        sum = sum + slice_sum;
        gear = gear + sum_gear;
    }
    std.debug.print("SUMA: {} SUM_GEAR {}\n", .{ sum, gear });
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

fn isAdjacent(symbol: Symbol, number: Number) bool {
    return isNextLineOrPrevious(symbol, number) and isInRange(symbol, number);
}

fn isInRange(symbol: Symbol, number: Number) bool {
    var start = if (number.start == 0) number.start else number.start - 1;
    return symbol.index >= start and symbol.index <= number.end + 1;
}

fn isNextLineOrPrevious(symbol: Symbol, number: Number) bool {
    return symbol.line == number.line + 1 or (number.line > 0 and symbol.line == number.line - 1);
}

fn isSameLineAndAdjacent(symbol: Symbol, number: Number) bool {
    return isSameLine(symbol, number) and (isNextTo(symbol, number) or isPreviousTo(symbol, number));
}

fn isNextTo(symbol: Symbol, number: Number) bool {
    return symbol.index == number.end + 1;
}

fn isPreviousTo(symbol: Symbol, number: Number) bool {
    return number.start > 0 and symbol.index == number.start - 1;
}

fn isSameLine(symbol: Symbol, number: Number) bool {
    return symbol.line == number.line;
}
