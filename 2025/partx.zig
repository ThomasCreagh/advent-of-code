const std = @import("std");
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const log = std.log;
const info = log.info;
const debug = log.debug;

pub const std_options: std.Options = .{ .log_level = .info };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    info("Sample Answer: {d}", .{try solve("sampleinput.txt", allocator)});
    info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(filename: []const u8, allocator: std.mem.Allocator) !usize {
    const cwd = std.fs.cwd();
    const contents = try cwd.readFileAlloc(allocator, filename, 8 * 1024);
    defer allocator.free(contents);

    var output: usize = 0;

    var lines = tokenizeScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line, " ");
        while (numbers.next()) |number| {
            output += try parseInt(usize, number, 10);
        }
    }
    return output;
}
