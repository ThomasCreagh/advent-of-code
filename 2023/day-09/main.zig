const input = @embedFile("input.txt");
const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

pub fn solve(line: []const u8) !struct { p1: isize, p2: isize } {
    var list = std.ArrayList(isize).init(allocator);
    defer list.deinit();
    var el = std.mem.tokenizeAny(u8, line, " \n");
    while (el.next()) |nums| {
        const trim_num = std.mem.trim(u8, nums, &[_]u8{ 13 });
        const num = try std.fmt.parseInt(isize, trim_num, 10);
        try list.append(num);
    }

    var sum: isize = 0;
    var i: usize = 0;

    var zeros: bool = true;
    var array = list.items;

    var neg: bool = false;
    var extrapolate_backwards: isize = 0;

    while (true) : (i += 1) {
        sum += array[array.len-1-i];
        if (neg) {
            extrapolate_backwards -= array[0];
            neg = false;
        } else {
            extrapolate_backwards += array[0];
            neg = true;
        }
        for (0..array.len-i-1) |index| {
            array[index] = array[index+1] - array[index];
            if (array[index] != 0) zeros = false;
        }
        array[array.len-i-1] = 0;
        if (zeros) break;
        zeros = true;
    }
    return .{ .p1 = sum, .p2 = extrapolate_backwards };
}


pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n");
    var sum_p1: isize = 0;
    var sum_p2: isize = 0;
    while (it.next()) |line| {
        const r = try solve(line);
        sum_p1 += r.p1;
        sum_p2 += r.p2;
    }
    print("answer p1: {}\n", .{ sum_p1 });
    print("answer p2: {}\n", .{ sum_p2 });
}