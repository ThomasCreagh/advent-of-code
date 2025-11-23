const std = @import("std");
const tokenizeAny = std.mem.tokenizeAny;
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

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !isize {
    const file = @embedFile(filename);
    _ = allocator;
    var lines = tokenizeAny(u8, file, "\n");
    var output: isize = 0;
    lineloop: while (lines.next()) |line| {
        std.log.debug("", .{});
        var numbers = tokenizeAny(u8, line, " ");
        var last_diff: isize = 0;
        var last_number: isize = try parseInt(isize, numbers.next().?, 10);
        while (numbers.next()) |number| {
            const parsed_number = try parseInt(isize, number, 10);
            std.log.debug("nubmer: {d}, last_number: {d}", .{ parsed_number, last_number });
            const diff: isize = parsed_number - last_number;
            if (@abs(diff) < 1 or @abs(diff) > 3 or (last_diff < 0 and diff > 0) or (last_diff > 0 and diff < 0)) {
                continue :lineloop;
            }
            last_diff = diff;
            last_number = parsed_number;
        }
        output += 1;
    }
    return output;
}
