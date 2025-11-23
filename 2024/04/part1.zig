const std = @import("std");
const tookenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const info = std.log.info;
const debug = std.log.debug;
const count = std.mem.count;

pub const std_options = .{ .log_level = .info };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !usize {
    const file = @embedFile(filename);
    var matrix = ArrayList(ArrayList(u8)).init(allocator);
    defer {
        for (matrix.items) |list| {
            list.deinit();
        }
        matrix.deinit();
    }
    var lines = tookenizeScalar(u8, file, '\n');
    while (lines.next()) |line| {
        var new_line = ArrayList(u8).init(allocator);
        try new_line.appendSlice(line);
        try matrix.append(new_line);
    }
    var output: usize = 0;
    // horizontal
    for (matrix.items) |list| {
        output += amount(list);
    }
    debug("after hor: {d}", .{output});
    // vertical
    for (0..matrix.items[0].items.len) |index| {
        var temp_list = ArrayList(u8).init(allocator);
        defer temp_list.deinit();
        for (matrix.items) |list| {
            try temp_list.append(list.items[index]);
        }
        output += amount(temp_list);
    }
    debug("after ver: {d}", .{output});
    // diagonal
    const size = matrix.items.len;

    for (0..size) |loop_amount| {
        var temp_list_1 = ArrayList(u8).init(allocator);
        defer temp_list_1.deinit();

        var temp_list_2 = ArrayList(u8).init(allocator);
        defer temp_list_2.deinit();

        for (0..loop_amount + 1) |index| {
            try temp_list_1.append(matrix.items[index].items[loop_amount - index]);
            try temp_list_2.append(matrix.items[index].items[(size - loop_amount - 1) + index]);
        }
        output += amount(temp_list_1);
        output += amount(temp_list_2);
    }

    for (1..size) |loop_neg| {
        const loop_amount = size - loop_neg - 1;
        var temp_list_1 = ArrayList(u8).init(allocator);
        defer temp_list_1.deinit();

        var temp_list_2 = ArrayList(u8).init(allocator);
        defer temp_list_2.deinit();

        for (0..loop_amount + 1) |index| {
            try temp_list_1.append(matrix.items[(size - loop_amount - 1) + index].items[(size - 1) - index]);
            try temp_list_2.append(matrix.items[(size - loop_amount - 1) + index].items[index]);
        }
        output += amount(temp_list_1);
        output += amount(temp_list_2);
    }
    debug("after dig: {d}", .{output});
    return output;
}

fn amount(array: ArrayList(u8)) usize {
    return count(u8, array.items, "XMAS") + count(u8, array.items, "SAMX");
}
