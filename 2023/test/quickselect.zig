const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const debug = false;

fn getPartition(array: []f32, low: usize, high: usize) usize {
    const pivot = array[high];
    var pivot_loc: usize = low;
    if (debug) print("\n\ngetPartition\nPivLoc: {d:.0}, Piv: {d:.0}, Low: {d:.0}, High: {d:.0}\n\n", .{ pivot_loc, pivot, low, high });
    for (low..high + 1) |i| {
        if (array[i] < pivot) {
            if (debug) print("Array Inside:\n{d:.0}\nPivLoc: {d:.0}, Piv: {d:.0}, Low: {d:.0}, High: {d:.0}\nSwap: {d:.0} and {d:.0}\n\n", .{ array, pivot_loc, pivot, low, high, array[pivot_loc], array[i] });
            const temp = array[i];
            array[i] = array[pivot_loc];
            array[pivot_loc] = temp;
            pivot_loc += 1;
        }
    }
    if (debug) print("Array Inside:\n{d:.0}\nPivLoc: {d:.0}, Piv: {d:.0}, Low: {d:.0}, High: {d:.0}\n\n", .{ array, pivot_loc, pivot, low, high });
    const temp = array[high];
    array[high] = array[pivot_loc];
    array[pivot_loc] = temp;
    if (debug) print("Array Inside:\n{d:.0}\nPivLoc: {d:.0}, Piv: {d:.0}, Low: {d:.0}, High: {d:.0}\n\n", .{ array, pivot_loc, pivot, low, high });

    return pivot_loc;
}

fn getOddValue(array: []f32, low: usize, high: usize, topMedInd: usize) f32 {
    var closest: f32 = undefined;
    for (low - 1..high) |i| {
        if ((array[i] < array[topMedInd] and i != topMedInd) and
            (closest == undefined or array[topMedInd] - array[i] < array[topMedInd] - closest))
        {
            closest = array[i];
        }
    }
    // print("{}", .{closest});
    return closest;
}

fn quickselect(array: []f32, low: usize, high: usize, k: usize) f32 {
    const partition = getPartition(array, low, high);
    if (partition == k - 1) {
        if (debug) print("{d:.0}\n\n", .{array[partition]});
        if (array.len % 2 == 0) {
            return (array[partition] + getOddValue(array, low, high, partition)) / @as(f32, 2);
        }
        return array[partition];
    } else if (partition < k - 1) {
        return quickselect(array, partition + 1, high, k);
    } else {
        return quickselect(array, low, partition - 1, k);
    }
}

fn getMedian(array: []f32) f32 {
    const middle: usize = (array.len >> 1) + 1;
    var median: f32 = undefined;
    median = quickselect(array, 0, array.len - 1, middle);
    return median;
}

pub fn main() void {
    var array = [_]f32{ 22, 44, 21, 31, 32, 13, 16, 28, 8, 27, 43, 9, 7, 35, 36, 24, 32, 2, 15, 19, 24, 38, 3, 39, 27, 3, 43, 21, 33, 23, 42, 43, 10, 7, 44, 30, 23, 23, 48, 5, 15, 18, 44, 7, 24, 9, 36, 5 };
    // var array = [_]f32{ 5, 8, 2, 1, 9, 3 }; //5 is missing
    print("Array Before:\n{d:.0}\n\n", .{array});
    const median = getMedian(&array);
    print("Array After:\n{d:.0}\n\n", .{array});
    print("Median Value:\n{d:.1}\n\n", .{median});
}

test "median list 1" {
    var array = [_]f32{ 20, 2, 3, 4, 5, 6, 7, 8, 1, 10, 11, 12, 11, 11, 4, 5, 8, 6, 11, 26 };
    try expect(getMedian(&array) == 7.5);
}

test "random.org" {
    var array = [_]f32{ 25, 24, 16, 22, 16, 12, 18, 15, 13, 15, 9, 13, 23, 24, 10, 13 };
    try expect(getMedian(&array) == 15.5);
}

test "big list test" {
    var array = [_]f32{ 39, 50, 22, 44, 21, 31, 32, 13, 16, 28, 8, 27, 43, 9, 7, 35, 36, 24, 32, 2, 15, 19, 24, 38, 3, 39, 27, 3, 43, 21, 33, 23, 42, 43, 10, 7, 44, 30, 23, 23, 48, 5, 15, 18, 44, 7, 24, 9, 36, 5 };
    try expect(getMedian(&array) == 24);
}
