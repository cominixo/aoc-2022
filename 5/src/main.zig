const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const part2 = true;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    
    var stack_arr = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var i: usize = 0;

    while (i < 9) : (i += 1) {
        try stack_arr.append(std.ArrayList(u8).init(allocator));
    }

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            break;
        }
        var ind: u32 = 1;

        if (line[1] != '1') {
            while (ind < line.len) {
                if (line[ind] != ' ') {
                    try stack_arr.items[@divFloor(ind,4)].insert(0, line[ind]);
                }
                ind += 4;
            }
        }

        std.log.info("{s}", .{line});
    }
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linesplit = std.mem.split(u8, line, " ");
        _ = linesplit.next();
        
        var times = try std.fmt.parseInt(u8, linesplit.next().?, 10);
        _ = linesplit.next();
        var from = (try std.fmt.parseInt(u8, linesplit.next().?, 10))-1;
        _ = linesplit.next();
        var to = (try std.fmt.parseInt(u8, linesplit.next().?, 10))-1;

        var from_stack = stack_arr.items[from];
        if (part2) {
            var item = from_stack.items[from_stack.items.len-times..from_stack.items.len];
            
            i = from_stack.items.len-times;
            while (i < from_stack.items.len) : (i += 1) {
                _ = stack_arr.items[from].pop();
            }
            
            try stack_arr.items[to].appendSlice(item);
        } else {
            i = 0;
            while (i < times) : (i += 1) {
                
                var item = stack_arr.items[from].pop();
                try stack_arr.items[to].append(item);
            }
        }
    }
    for (stack_arr.items) |stack| {
        print("{c}", .{stack.items[stack.items.len-1]});
    }
    print("\n", .{});
}