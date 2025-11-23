const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
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
    var rules = std.AutoHashMap(u8, std.ArrayList(u8)).init(allocator);
    defer {
        var iter = rules.valueIterator();
        while (iter.next()) |val| {
            val.deinit();
        }
        rules.deinit();
    }

    var output: usize = 0;
    var sections = tokenizeSequence(u8, file, "\n\n");
    var lines = tokenizeScalar(u8, sections.next().?, '\n');
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, "|");

        const key = try parseInt(u8, numbers.next().?, 10);
        const val = try parseInt(u8, numbers.next().?, 10);

        if (rules.contains(key)) {
            try rules.getPtr(key).?.append(val);
        } else {
            var new_array = std.ArrayList(u8).init(allocator);
            try new_array.append(val);
            try rules.put(key, new_array);
        }
    }
    lines = tokenizeScalar(u8, sections.next().?, '\n');
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, ",");
        var array = std.ArrayList(u8).init(allocator);
        defer array.deinit();
        while (numbers.next()) |number| {
            try array.append(try parseInt(u8, number, 10));
        }
        var is_correct = true;
        for (array.items, 0..) |item, key_index| {
            const value_search = rules.get(item);
            if (value_search) |value| {
                for (value.items) |value_item| {
                    const array_index = std.mem.indexOfScalar(u8, array.items, value_item);
                    if (array_index) |value_index| {
                        if (key_index > value_index) {
                            is_correct = false;
                            break;
                        }
                    }
                }
            }
        }
        if (is_correct) {
            output += array.items[array.items.len >> 1];
            // debug("new correct value: {d}", .{array.items[array.items.len >> 1]});
            // debug("from line: {any}", .{array.items});
        } else {
            debug("false line: {any}", .{array.items});
        }
    }
    return output;
}
