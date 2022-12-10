const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;


pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var cycles: i32 = 1;

    var regx: i32 = 1;

    var execute_stack = std.ArrayList(i32).init(allocator);
    var crt_display = std.ArrayList(u8).init(allocator);

    while (cycles < 241) : (cycles += 1) {
        var lineopt: ?[]u8 = null;
        if (execute_stack.items.len == 0) {
            lineopt = try in_stream.readUntilDelimiterOrEof(&buf, '\n');
        }
        var line = if (lineopt == null) "noop" else lineopt.?;
        var linesplit = std.mem.split(u8, line, " ");
        var op = linesplit.next().?;

        var crt_x = @mod(cycles-1, 40);
        if (crt_x == 0) {
            try crt_display.append('\n');
        }

        if (std.mem.eql(u8, op, "addx")) {
            var valuestr = linesplit.next().?;
            var value = try std.fmt.parseInt(i32, valuestr, 10);

            try execute_stack.append(value);
        } 

        if (crt_x == regx or crt_x == regx - 1 or crt_x == regx + 1) {
            try crt_display.append('#');
        } else {
            try crt_display.append('.');
        }

        if (!std.mem.eql(u8, op, "addx") and execute_stack.items.len > 0) {
            regx += execute_stack.pop();
        }

    }
    std.log.info("{s}", .{crt_display.items});
}