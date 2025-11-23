const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const info = std.log.info;
const debug = std.log.debug;

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
    var hundered_zeros: [100]u8 = undefined;
    for (0..hundered_zeros.len) |i| {
        hundered_zeros[i] = '0';
    }
    const file = @embedFile(filename);
    var lines = tokenizeScalar(u8, file, '\n');
    var output: usize = 0;
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, ": ");
        const answer = try parseInt(usize, numbers.next().?, 10);
        var array = std.ArrayList(usize).init(allocator);
        defer array.deinit();

        while (numbers.next()) |number| {
            try array.append(try parseInt(usize, number, 10));
        }

        for (0..std.math.pow(usize, 3, array.items.len - 1)) |combo| {
            var total_values: usize = array.items[0];
            var str_num: [100]u8 = hundered_zeros;
            const str_size = std.fmt.formatIntBuf(
                &str_num,
                combo,
                3,
                std.fmt.Case.lower,
                std.fmt.FormatOptions{ .fill = @as(u21, '0'), .width = array.items.len - 1 },
            );
            debug("str: {s}", .{str_num[0..str_size]});
            for (0..array.items.len - 1) |mul_index| {
                if (str_num[str_size - mul_index - 1] == '2') {
                    const tens: usize = @as(
                        usize,
                        @intFromFloat(@floor(
                            std.math.log10(@as(f64, @floatFromInt(@abs(array.items[mul_index + 1])))),
                        )),
                    ) + 1;
                    debug("total: {d}, new: {d}, resulting concat: {d}", .{
                        total_values,
                        array.items[mul_index + 1],
                        (total_values * std.math.pow(usize, 10, tens)) + array.items[mul_index + 1],
                    });
                    total_values = (total_values * std.math.pow(usize, 10, tens)) + array.items[mul_index + 1];
                } else if (str_num[str_size - mul_index - 1] == '1') {
                    total_values *= array.items[mul_index + 1];
                } else {
                    total_values += array.items[mul_index + 1];
                }
            }
            debug("TOTAL: {d}", .{total_values});
            if (total_values == answer) {
                output += total_values;
                debug("correct: {d}", .{total_values});
                break;
            }
        }

        debug("answer: {d}, items: {any}", .{ answer, array.items });
    }
    return output;
}
