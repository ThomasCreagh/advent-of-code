const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const info = std.log.info;
const debug = std.log.debug;

pub const std_options = .{ .log_level = .debug };

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
    _ = allocator;
    var lines = tokenizeScalar(u8, file, '\n');
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, " ");
        while (numbers.next()) |number| {
            _ = try parseInt(usize, number, 10);
        }
    }
    return 0;
}
