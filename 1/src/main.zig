const std = @import("std");

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var max_calories = [3]u32 {0,0,0};
    var current_calories: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            var i: usize = 0;
            while (i<3) : (i+=1) {
                if (current_calories >= max_calories[i]) {
                    var temp = max_calories[i];
                    max_calories[i] = current_calories;
                    if (i+1 < 3) 
                        max_calories[i+1] = temp;
                    break;
                }
            }
            
            current_calories = 0;
            continue;
        }

        current_calories += try std.fmt.parseInt(u32, line, 10);

    }
    std.log.info("Part 1: {d}", .{max_calories[0]}); // 72718
    std.log.info("Part 2: {d}", .{max_calories[0] + max_calories[1] + max_calories[2]}); // 72718
}