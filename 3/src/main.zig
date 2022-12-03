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

    var line_buffer: [3][]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (count = (count + 1) % 3) {
        line_buffer[count] = try allocator.dupe(u8, line);
        if (count == 2) {
            total_part2 += part2(line_buffer);
        }
        total += part1(line);
    }
    
    std.log.info("Part 1: {d}", .{total});
    std.log.info("Part 2: {d}", .{total_part2});
}

pub fn part2(lines: [3][]u8) u32 {

    var char: u8 = 65;

    while (char < 123) : (char += 1) {

        if (char == 91) {
            char = 97;
        }
        if (containsChar(lines[0], char) and containsChar(lines[1], char) and containsChar(lines[2], char)) {
            var char_value = if (char < 91) char-65+27
                             else char-96;
            return char_value;
        }

    }
    return 0;
}

pub fn part1(line: []u8) u32 {
    var firsthalf = line[0..line.len/2];
    var secondhalf = line[line.len/2..];

    var char: u8 = 65;

    while (char < 123) : (char += 1) {

        if (char == 91) {
            char = 97;
        }
        if (containsChar(firsthalf, char) and containsChar(secondhalf, char)) {
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