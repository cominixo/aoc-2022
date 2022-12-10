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

    var cycles: i32 = 0;

    var regx: i32 = 1;

    var next_cycle_interrupt: i32 = 20;

    var signal_sum: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linesplit = std.mem.split(u8, line, " ");
        var op = linesplit.next().?;
        if (std.mem.eql(u8, op, "noop")) {
            cycles += 1;
            if (cycles == next_cycle_interrupt) {
                signal_sum += cycles * regx;
                next_cycle_interrupt += 40;
            }
            continue;
        }
        var valuestr = linesplit.next().?;
        var value = try std.fmt.parseInt(i32, valuestr, 10);
        cycles += 2;
        if (cycles >= next_cycle_interrupt) {
            signal_sum += next_cycle_interrupt * regx;
            next_cycle_interrupt += 40;
        } 
        regx += value;

    }
    std.log.info("{d}", .{signal_sum});
}