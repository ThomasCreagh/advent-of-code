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

    var counter: isize = 50;
    var output: isize = 0;

    var lines = tokenizeScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        debug("counter: {d}, output: {d}", .{ counter, output });
        const direction = line[0];
        const number = try parseInt(isize, line[1..], 10);

        if (direction == 'L') {
            if (number > counter) {
                output += 1 + @divFloor(number - counter - 1, 100);
            }
            counter = @mod((counter - number + 10000), 100);
        } else {
            counter = @mod(counter + number, 100);
        }
    }
    debug("counter: {d}", .{counter});
    return output;
}
