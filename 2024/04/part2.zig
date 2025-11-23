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
    const size = matrix.items.len;
    for (0..size - 2) |i| {
        for (0..size - 2) |j| {
            if (matrix.items[i + 1].items[j + 1] == 'A') {
                if (@as(u16, @intCast(matrix.items[i].items[j])) + // top left
                    @as(u16, @intCast(matrix.items[i].items[j + 2])) + // top right
                    @as(u16, @intCast(matrix.items[i + 2].items[j])) + // bottom left
                    @as(u16, @intCast(matrix.items[i + 2].items[j + 2])) == // bottom right
                    @as(u16, @intCast(('M' * 2) + ('S' * 2))) and
                    matrix.items[i].items[j] != matrix.items[i + 2].items[j + 2])
                {
                    output += 1;
                }
            }
        }
    }
    return output;
}
