const std = @import("std");
const tokenizeAny = std.mem.tokenizeAny;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

pub const std_options = .{ .log_level = .info };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    std.log.info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    std.log.info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !usize {
    const file = @embedFile(filename);
    var number_card = AutoHashMap(usize, usize).init(allocator);
    defer number_card.deinit();
    var left_numbers = ArrayList(usize).init(allocator);
    defer left_numbers.deinit();

    var lines = tokenizeAny(u8, file, "\n");
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, " ");
        try left_numbers.append(try parseInt(usize, numbers.next().?, 10));
        const right_number = try parseInt(usize, numbers.next().?, 10);
        try number_card.put(right_number, (number_card.get(right_number) orelse 0) + 1);
    }

    var output: usize = 0;
    for (left_numbers.items) |key| {
        output += key * (number_card.get(key) orelse 0);
    }

    return output;
}
