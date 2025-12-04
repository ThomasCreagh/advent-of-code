const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const log = std.log;
const info = log.info;
const debug = log.debug;

pub const std_options: std.Options = .{ .log_level = .debug };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    info("Answer: {d}", .{try solve("input.txt", allocator)});
    info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    info("Tom Answer: {d}", .{try solve("tominput.txt", allocator)});
}

fn solve(filename: []const u8, allocator: std.mem.Allocator) !isize {
    const cwd = std.fs.cwd();
    const contents = try cwd.readFileAlloc(allocator, filename, 256 * 1024);
    defer allocator.free(contents);
    var dial: isize = 50;
    var counter: isize = 0;
    var lines = tokenizeScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const direction = line[0];
        var number = try parseInt(isize, line[1..], 10);
        const left = (direction == 'L');

        while (number > 0) {
            if (left) {
                dial -= 1;
            } else {
                dial += 1;
            }
            if (@abs(dial) == 100) {
                dial = 0;
            }
            if (dial == 0) {
                counter += 1;
            }
            number -= 1;
        }
    }
    debug("dial: {d}", .{dial});
    return counter;
}
