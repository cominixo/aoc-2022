const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const n_chars = 14;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4098]u8 = undefined;

    var line = (try in_stream.readUntilDelimiterOrEof(&buf, '\n')).?;
    var char_buf = std.ArrayList(u8).init(allocator);
    var i: u32 = 0;
    while(i < line.len) : (i += 1) {
        var char = line[i];
        if (i > n_chars-1) {
            var items = try allocator.alloc(u8, n_chars);
            std.mem.copy(u8, items, char_buf.items);
            if (hasAllDifferent(items)) {
                break;
            }
        }
        
        try char_buf.insert(0,char);
        if (char_buf.items.len > n_chars)
            _ = char_buf.pop();
        
    }
    std.log.info("{d}", .{i});
}

pub fn hasAllDifferent(items: []u8) bool {
    var i: u32 = 0;
    std.sort.sort(u8, items, {}, comptime std.sort.asc(u8));
    while (i < items.len) : (i+=1) {
        if (i > 0) {
            if (items[i] == items[i-1]) {
                return false;
            }
        }
    }
    std.log.info("{any}", .{items});
    return true;
}