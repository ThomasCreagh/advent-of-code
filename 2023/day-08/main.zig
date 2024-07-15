const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
const Direction = struct { right: [3]u8, left: [3]u8 };

pub fn string_input(solve_func: *const fn (instructions: []const u8, rl_map: std.AutoHashMap([3]u8, Direction)) usize, input_str: []const u8) !usize {
    var split_str = std.mem.splitAny(u8, input_str, "\n");
    const str_instructions = split_str.first();

    _ = split_str.next();

    var rl_map = std.AutoHashMap([3]u8, Direction).init(
        std.heap.page_allocator,
    );
    defer rl_map.deinit();

    while (split_str.peek() != null) {
        const line = split_str.next().?;
        try rl_map.put(line[0..3].*, .{ .left = line[7..10].*, .right = line[12..15].*, });
    }
    return solve_func(str_instructions, rl_map);
}

pub fn file_input(solve_func: *const fn (instructions: []const u8, rl_map: std.AutoHashMap([3]u8, Direction)) usize) !usize {
    var it = std.mem.tokenize(u8, input, "\n");
    const str_instructions = it.next().?;
    // print("{s}", .{ it.next().? });


    var rl_map = std.AutoHashMap([3]u8, Direction).init(
        std.heap.page_allocator,
    );
    defer rl_map.deinit();

    while (it.next()) |line| {
        try rl_map.put(line[0..3].*, .{ .left = line[7..10].*, .right = line[12..15].*, });
    }
    return solve_func(str_instructions, rl_map);
    // return solve2(str_instructions, rl_map);
}

pub fn solve1(instructions: []const u8, rl_map: std.AutoHashMap([3]u8, Direction)) usize {
    var cur_letters: [3]u8 = "AAA".*;
    var moves: u64 = 0;
    while (cur_letters[0] != 'Z' and cur_letters[1] != 'Z' and cur_letters[2] != 'Z') : (moves += 1) {
        const direction = rl_map.get(cur_letters).?;
        const inst = instructions[moves % instructions.len];
        if (inst == 'R') {
            cur_letters = direction.right;
        } else {
            cur_letters = direction.left;
        }
    }
    
    return moves;
}

pub fn solve2(instructions: []const u8, rl_map: std.AutoHashMap([3]u8, Direction)) usize {
    var count: u64 = 1;
    var it = rl_map.keyIterator();
    while (it.next()) |key| {
        if (std.mem.endsWith(u8, key, "A")) {
            var cur: [3]u8 = key.*;
            var moves: u64 = 0;
            while (!std.mem.endsWith(u8, &cur, "Z")) : (moves += 1) {
                const direction = rl_map.get(cur).?;
                const inst = instructions[moves % instructions.len];
                if (inst == 'R') {
                    cur = direction.right;
                } else {
                    cur = direction.left;
                }               
            }
            count = (count * moves) / std.math.gcd(count, moves);
        }

    }
    return count;
}

const testing = std.testing;
test "small" {
    const ob1 =
        \\RL
        \\
        \\AAA = (BBB, CCC)
        \\BBB = (DDD, EEE)
        \\CCC = (ZZZ, GGG)
        \\DDD = (DDD, DDD)
        \\EEE = (EEE, EEE)
        \\GGG = (GGG, GGG)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    try testing.expect(try string_input(solve1, ob1) == 2);

    const ob2 =
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    try testing.expect(try string_input(solve1, ob2) == 6);

    const ob4 =
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
    ;
    try testing.expect(try string_input(solve2, ob4) == 6);
}

test "large" {
    print("{}\n", .{ try file_input(solve1) });
    print("{}\n", .{ try file_input(solve2) });
}