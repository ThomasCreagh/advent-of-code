const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const tokenizeScalar = std.mem.tokenizeScalar;
const info = std.log.info;
const debug = std.log.debug;

pub const std_options = .{ .log_level = .info };

const GuardDirection = enum { north, south, east, west };
const GuardCords = struct { x: u16, y: u16 };

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
    var map = ArrayList(ArrayList(u8)).init(allocator);
    defer {
        for (map.items) |line| {
            line.deinit();
        }
        map.deinit();
    }

    var guard_direction = GuardDirection.north;
    var guard_cords = GuardCords{ .x = undefined, .y = undefined };

    var lines = tokenizeScalar(u8, file, '\n');
    var y: u16 = 0;
    while (lines.next()) |line| {
        var line_array = ArrayList(u8).init(allocator);
        for (line, 0..) |char, x| {
            if (char == '^') {
                guard_cords = GuardCords{ .x = @as(u16, @intCast(x)), .y = y };
            }
            try line_array.append(char);
        }
        try map.append(line_array);
        debug("{s}", .{line_array.items});
        y += 1;
    }

    // cycling the guards movments
    var all_cords = AutoHashMap(u16, void).init(allocator);
    defer all_cords.deinit();
    while (true) {
        // bitwise oring the x and y as they dont go above 8 bits (256) u16[xxxxxxxx yyyyyyyy]
        try all_cords.put((guard_cords.x << 8) | guard_cords.y, {});
        switch (guard_direction) {
            .north => {
                if (guard_cords.y == 0) break;
                if (map.items[guard_cords.y - 1].items[guard_cords.x] == '#') {
                    guard_direction = GuardDirection.east;
                } else guard_cords.y -= 1;
            },
            .south => {
                if (guard_cords.y == map.items.len - 1) break;
                if (map.items[guard_cords.y + 1].items[guard_cords.x] == '#') {
                    guard_direction = GuardDirection.west;
                } else guard_cords.y += 1;
            },
            .east => {
                if (guard_cords.x == map.items[0].items.len - 1) break;
                if (map.items[guard_cords.y].items[guard_cords.x + 1] == '#') {
                    guard_direction = GuardDirection.south;
                } else guard_cords.x += 1;
            },
            .west => {
                if (guard_cords.x == 0) break;
                if (map.items[guard_cords.y].items[guard_cords.x - 1] == '#') {
                    guard_direction = GuardDirection.north;
                } else guard_cords.x -= 1;
            },
        }
    }

    return all_cords.count();
}
