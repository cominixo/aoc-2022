const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;


pub fn main() anyerror!void {
    var buf = @embedFile("input");

    var lists = std.mem.split(u8, buf, "\n\n");

    var sum: u32 = 0;
    var index: u32 = 0;

    while (lists.next()) |lines| {
        index += 1;
        var lists_split = std.mem.split(u8, lines, "\n");
        var list1 = lists_split.next().?;
        var list2 = lists_split.next().?;

        var comp = try compare(list1, list2);


        if (comp.?) {
            sum += index;
        }
    }
    var newbuf = try allocator.alloc(u8, buf.len);
    _ = std.mem.replace(u8, buf, "\n\n", "\n", newbuf);

    var lines = std.mem.split(u8, newbuf, "\n");
    var all_lines = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |line| {
        try all_lines.append(line);
    }

    try all_lines.append("[[2]]");
    try all_lines.append("[[6]]");

    var lines_slice = try all_lines.toOwnedSlice();

    std.sort.sort([]const u8, lines_slice, {}, lessthan);

    std.log.info("{d}", .{sum});
    var index_p2: u32 = 0;

    var p2: u32 = 1;

    for(lines_slice) |line| {
        index_p2 += 1;
        if (std.mem.eql(u8,line,"[[2]]") or std.mem.eql(u8,line,"[[6]]")) {
            p2 *= index_p2;
        }
    }
    std.log.info("{d}", .{p2});
}

fn compare(left: []const u8, right: []const u8) !?bool {

    var parsed_left = try parse_list(left);
    var parsed_right = try parse_list(right);

    if (parsed_left.items.len == 1 and parsed_right.items.len == 1) {
        if (std.fmt.parseInt(u32, parsed_left.items[0], 10)) |leftint| {
            if (std.fmt.parseInt(u32, parsed_right.items[0], 10)) |rightint| {
                if (leftint == rightint) {
                    return null;
                } else {
                    return leftint < rightint;  
                }
            } else |_| {}
        } else |_| {}
    }

    var index: usize = 0;
    while (index < std.mem.max(usize, &.{parsed_left.items.len,parsed_right.items.len})) : (index += 1){
        if (index >= parsed_left.items.len) return true;
        if (index >= parsed_right.items.len) return false;
        
        var value = try compare(parsed_left.items[index], parsed_right.items[index]);
        if (value != null) {
            return value;
        } 
    }

    return null;
}

fn lessthan(context: void, left: []const u8, right: []const u8) bool {
    _ = context;
    return (compare(left, right) catch unreachable).?;
}

fn isInt(string: []u8) bool {
    for (string) |char| {
        if (!std.ascii.isDigit(char)) return false;
    }
    return true;
}

fn parse_list(list: []const u8) !std.ArrayList([]u8) {

    var stack = std.ArrayList(u8).init(allocator);

    var parsed_list = std.ArrayList([]u8).init(allocator);

    if (list.len == 0) {
        return parsed_list;
    }

    if (std.ascii.isDigit(list[0])) {
        var slice = try allocator.alloc(u8, list.len);
        std.mem.copy(u8, slice, list);
        try parsed_list.append(slice);
        return parsed_list;
    }

    var current_item = std.ArrayList(u8).init(allocator);

    for (list) |char| {
        if (stack.items.len > 0 and ((char != ']' and char != ',') or stack.items.len > 1)) {
            try current_item.append(char);
        }

        if (char == ',' and stack.items.len == 1) {
            var cloned = try allocator.alloc(u8, current_item.items.len);
            std.mem.copy(u8, cloned, current_item.items);
            try parsed_list.append(cloned);
            current_item.clearAndFree();
        }

        if (char == '[') {
            try stack.append(char);
        } else if (char == ']') {
            _ = stack.pop();
            if (stack.items.len == 0) {
                var cloned = try allocator.alloc(u8, current_item.items.len);
                std.mem.copy(u8, cloned, current_item.items);
                try parsed_list.append(cloned);
                current_item.clearAndFree();
            }
        }


    }
    return parsed_list;
}