const std = @import("std");
const tookenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
const parseInt = std.fmt.parseInt;

pub const std_options = .{ .log_level = .info };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    std.log.info("Sample Answer (161): {d}", .{try solve("sampleinput.txt", allocator)});
    std.log.info("Toms Sample Answer (48): {d}", .{try solve("tomssampleinput.txt", allocator)});
    std.log.info("Answer: {d}", .{try solve("input.txt", allocator)});
}

fn solve(comptime filename: []const u8, allocator: std.mem.Allocator) !usize {
    const file = @embedFile(filename);
    _ = allocator;
    var output: usize = 0;

    var dont_it = tokenizeSequence(u8, file, "don't()");
    {
        std.log.debug("dont: {s}", .{dont_it.peek().?});
        var mul_it = tokenizeSequence(u8, dont_it.next().?, "mul(");
        while (mul_it.next()) |mul| {
            var comma_it = tookenizeScalar(u8, mul, ',');
            const number1 = parseInt(usize, comma_it.next() orelse "", 10);
            if (number1) |first_num| {
                var bracket_it = tookenizeScalar(u8, comma_it.next() orelse "", ')');
                const number2 = parseInt(usize, bracket_it.next() orelse "", 10);
                if (number2) |second_num| {
                    output += first_num * second_num;
                    std.log.debug("output: {d}", .{output});
                } else |_| continue;
            } else |_| continue;
        }
    }

    while (dont_it.next()) |dont| {
        std.log.debug("dont: {s}", .{dont});
        var do_it = tokenizeSequence(u8, dont, "do()");
        _ = do_it.next() orelse "";
        while (do_it.next()) |do| {
            var mul_it = tokenizeSequence(u8, do, "mul(");
            while (mul_it.next()) |mul| {
                var comma_it = tookenizeScalar(u8, mul, ',');
                const number1 = parseInt(usize, comma_it.next() orelse "", 10);
                if (number1) |first_num| {
                    var bracket_it = tookenizeScalar(u8, comma_it.next() orelse "", ')');
                    const number2 = parseInt(usize, bracket_it.next() orelse "", 10);
                    if (number2) |second_num| {
                        output += first_num * second_num;
                        std.log.debug("output: {d}", .{output});
                    } else |_| continue;
                } else |_| continue;
            }
        }
    }
    return output;
}
