const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();


pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var total: u32 = 0;
    var total_part2: u32 = 0;

    var count: u32 = 0;

    var part2_arr = std.ArrayList([]u8).init(allocator);
    defer part2_arr.deinit();

    var part1_arr = std.ArrayList([]u8).init(allocator);
    defer part1_arr.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (count = (count + 1) % 3) {
        try part2_arr.append(try allocator.dupe(u8, line));
        if (count == 2) {
            total_part2 += getCommonChar(part2_arr);
            part2_arr.clearAndFree();
        }
        try part1_arr.insertSlice(0, &.{line[0..line.len/2], line[line.len/2..]});
        total += getCommonChar(part1_arr);
        part1_arr.clearAndFree();
    }
    
    std.log.info("Part 1: {d}", .{total});
    std.log.info("Part 2: {d}", .{total_part2});
}

pub fn getCommonChar(lines: std.ArrayList([]u8)) u32 {
    var char: u8 = 65;

    while (char < 123) : (char += 1) {

        if (char == 91) {
            char = 97;
        }
        var lines_matching: u32 = 0;
        for (lines.items) |line| {
            if (containsChar(line, char))
                lines_matching += 1;
        }

        if (lines_matching == lines.items.len) {
            var char_value = if (char < 91) char-65+27
                             else char-96;
            return char_value;
        }
    }
    return 0;
}

pub fn containsChar(haystack: []u8, needle: u8) bool {
    for (haystack) |c| {
        if (c == needle)
            return true;
    }
    return false;
}