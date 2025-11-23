const std = @import("std");
const tokenizeAny = std.mem.tokenizeAny;
const Arraylist = std.ArrayList;
const parseInt = std.fmt.parseInt;

pub const std_options = .{ .log_level = .debug };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    std.log.info("Toms Sample Answer: {d}", .{try solve("tomssampleinput.txt", allocator)});
    std.log.info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    std.log.info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !isize {
    const file = @embedFile(filename);
    var lines = tokenizeAny(u8, file, "\n");
    var output: isize = 0;

    var line_array = Arraylist(isize).init(allocator);
    defer line_array.deinit();

    while (lines.next()) |line| { // lineloop:
        var numbers = tokenizeAny(u8, line, " ");
        line_array.clearAndFree();
        while (numbers.next()) |number| {
            try line_array.append(try parseInt(isize, number, 10));
        }
        if (!valid(line_array)) {
            for (0..line_array.items.len) |index| {
                if (try validate_without(line_array, index)) {
                    output += 1;
                    break;
                }
            }
        } else {
            output += 1;
        }
    }
    return output;
}

fn validate_without(array: Arraylist(isize), index: usize) !bool {
    var array_copy = try array.clone();
    defer array_copy.deinit();
    _ = array_copy.orderedRemove(index);

    return valid(array_copy);
}

fn valid(array: Arraylist(isize)) bool {
    var last = array.items[0];
    var last_diff: isize = 0;
    for (1..array.items.len) |index| {
        const diff = last - array.items[index];
        if (@abs(diff) < 1 or @abs(diff) > 3 or (last_diff < 0 and diff > 0) or (last_diff > 0 and diff < 0)) {
            return false;
        }
        last = array.items[index];
        last_diff = diff;
    }
    return true;
}
