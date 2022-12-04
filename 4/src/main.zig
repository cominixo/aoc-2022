const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();


pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var countp1: u32 = 0;
    var countp2: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var sections = std.mem.split(u8, line, ",");
        var section1 = std.mem.split(u8, sections.next().?, "-");
        var section2 = std.mem.split(u8, sections.next().?, "-");

        var lower1 = try std.fmt.parseInt(u32, section1.next().?, 10);
        var upper1 = try std.fmt.parseInt(u32, section1.next().?, 10);
        var lower2 = try std.fmt.parseInt(u32, section2.next().?, 10);
        var upper2 = try std.fmt.parseInt(u32, section2.next().?, 10);

        if ((lower1 <= lower2 and upper1 >= upper2) or 
            (lower2 <= lower1 and upper2 >= upper1)) {
            countp1 += 1;
        }

        if ((upper1 >= lower2) and (lower1 <= upper2)) {
            countp2 += 1;
        }

    }
    std.log.info("{d} {d}", .{countp1, countp2});
}