const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const tokenizeScalar = std.mem.tokenizeScalar;
const info = std.log.info;
const debug = std.log.debug;

pub const std_options = .{ .log_level = .info };

const Direction = enum { north, south, east, west };
const Cords = struct { x: u16, y: u16 };

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

    var guard_cords = Cords{ .x = undefined, .y = undefined };

    var lines = tokenizeScalar(u8, file, '\n');
    var y: u16 = 0;
    while (lines.next()) |line| {
        var line_array = ArrayList(u8).init(allocator);
        for (line, 0..) |char, x| {
            if (char == '^') {
                guard_cords = Cords{ .x = @as(u16, @intCast(x)), .y = y };
            }
            try line_array.append(char);
        }
        try map.append(line_array);
        y += 1;
    }

    var output: usize = 0;

    // trying by replacing all the '.' with an item that blocks the guard
    for (0..map.items.len) |row_index| {
        debug("Trying row {d}", .{row_index});
        for (0..map.items[0].items.len) |col_index| {
            debug("\tTrying col {d}, output: {d}", .{ col_index, output });
            if (map.items[row_index].items[col_index] == '.') {
                if (try is_loop(map, Cords{
                    .x = @as(u16, @intCast(col_index)),
                    .y = @as(u16, @intCast(row_index)),
                }, guard_cords, allocator)) {
                    output += 1;
                }
            }
        }
    }

    return output;
}

// this is to check if the guard cycle loops given the cords where the item block would be
fn is_loop(
    map: ArrayList(ArrayList(u8)),
    placement: Cords,
    original_guard_cords: Cords,
    allocator: std.mem.Allocator,
) !bool {
    var guard_cords = original_guard_cords;
    var guard_direction = Direction.north;

    var all_cords = AutoHashMap(Cords, ArrayList(Direction)).init(allocator);
    defer {
        var val_iter = all_cords.valueIterator();
        while (val_iter.next()) |iter| {
            iter.deinit();
        }
        all_cords.deinit();
    }

    while (true) {
        switch (guard_direction) {
            .north => {
                if (guard_cords.y == 0) break;
                if (map.items[guard_cords.y - 1].items[guard_cords.x] == '#') {
                    guard_direction = Direction.east;
                } else if (guard_cords.y - 1 == placement.y and guard_cords.x == placement.x) {
                    guard_direction = Direction.east;
                } else guard_cords.y -= 1;
            },
            .south => {
                if (guard_cords.y == map.items.len - 1) break;
                if (map.items[guard_cords.y + 1].items[guard_cords.x] == '#') {
                    guard_direction = Direction.west;
                } else if (guard_cords.y + 1 == placement.y and guard_cords.x == placement.x) {
                    guard_direction = Direction.west;
                } else guard_cords.y += 1;
            },
            .east => {
                if (guard_cords.x == map.items[0].items.len - 1) break;
                if (map.items[guard_cords.y].items[guard_cords.x + 1] == '#') {
                    guard_direction = Direction.south;
                } else if (guard_cords.y == placement.y and guard_cords.x + 1 == placement.x) {
                    guard_direction = Direction.south;
                } else guard_cords.x += 1;
            },
            .west => {
                if (guard_cords.x == 0) break;
                if (map.items[guard_cords.y].items[guard_cords.x - 1] == '#') {
                    guard_direction = Direction.north;
                } else if (guard_cords.y == placement.y and guard_cords.x - 1 == placement.x) {
                    guard_direction = Direction.north;
                } else guard_cords.x -= 1;
            },
        }
        if (all_cords.contains(guard_cords)) {
            for (all_cords.get(guard_cords).?.items) |dir| {
                if (dir == guard_direction) return true;
            }
            try all_cords.getPtr(guard_cords).?.append(guard_direction);
        } else {
            var new_array = ArrayList(Direction).init(allocator);
            try new_array.append(guard_direction);
            try all_cords.put(guard_cords, new_array);
        }
    }
    return false;
}
