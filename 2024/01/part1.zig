const std = @import("std");
const tokenizeAny = std.mem.tokenizeAny;
const ArrayList = std.ArrayList;

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
    var array1 = ArrayList(isize).init(allocator);
    defer array1.deinit();
    var array2 = ArrayList(isize).init(allocator);
    defer array2.deinit();

    var lines = tokenizeAny(u8, file, "\n");
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, " ");
        var index: usize = 0;
        while (numbers.next()) |number| {
            if (index == 0) {
                try array1.append(try std.fmt.parseInt(isize, number, 10));
            } else {
                try array2.append(try std.fmt.parseInt(isize, number, 10));
            }
            index += 1;
        }
    }
    std.mem.sort(isize, array1.items, {}, comptime std.sort.asc(isize));
    std.mem.sort(isize, array2.items, {}, comptime std.sort.asc(isize));

    std.log.debug("array1: {any}\nlen: {d}", .{ array1.items, array1.items.len });
    std.log.debug("array2: {any}\nlen: {d}", .{ array2.items, array2.items.len });

    var output: usize = 0;
    for (0..array1.items.len) |index| {
        output += @intCast(@abs(array2.items[index] - array1.items[index]));
    }
    return output;
}
