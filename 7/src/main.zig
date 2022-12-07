const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const FilesystemNode = struct {
    prev: ?*FilesystemNode,
    contents: ?std.ArrayList(*FilesystemNode),
    size: u32,
    name: []const u8,
};

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;

    var root = FilesystemNode {
        .prev = null,
        .contents = std.ArrayList(*FilesystemNode).init(allocator),
        .size = 0,
        .name = "/",
    };

    var current = &root;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "$ cd /")) continue; // just ignore the first line since we're already on /
        
        var linesplit = std.mem.split(u8, line, " ");

        if (line[0] == '$') {
            var cmdsplit = std.mem.split(u8, line[2..line.len], " ");
            var cmd = cmdsplit.next().?;

            if (std.mem.eql(u8, cmd, "ls")) {
                continue;
            }

            var arg = cmdsplit.next().?;
            if (std.mem.eql(u8, cmd, "cd")) {
                if (std.mem.eql(u8, arg, "..")) {
                    current = current.prev.?;
                }
                for (current.contents.?.items) |node| {
                    if (std.mem.eql(u8, node.name, arg)) {
                        current = node;
                        break;
                    }
                }
            }
            

        }
        else if (std.ascii.isDigit(line[0])) {
            var sizestr = linesplit.next().?;
            var name = linesplit.next().?;

            var node_alloc = try allocator.create(FilesystemNode);
            var size = try std.fmt.parseInt(u32, sizestr, 10);

            node_alloc.* = FilesystemNode {
                .prev = current,
                .contents = null,
                .size = size,
                .name = try allocator.dupe(u8, name),
            };
            try current.contents.?.append(node_alloc);

        } else {
            _ = linesplit.next().?;
            var dirname = linesplit.next().?;

            var node_alloc = try allocator.create(FilesystemNode);
            node_alloc.* = FilesystemNode {
                .prev = current,
                .contents = std.ArrayList(*FilesystemNode).init(allocator),
                .size = 0,
                .name = try allocator.dupe(u8, dirname),
            };

            try current.contents.?.append(node_alloc);
        }
    }
    var arr = std.ArrayList(u32).init(allocator);
    var root_size = calcSize(&root, &arr);

    var answer: u32 = 0;
    var answer2: u32 = 0;

    for (arr.items) |item| {
        if (item < 100000)
            answer += item;
        if (30000000-(70000000-root_size) < item) {
            if (answer2 == 0 or item < answer2) {
                answer2 = item;
            }
        }
    }
    std.log.info("part 1: {d}", .{answer});
    std.log.info("part 2: {d}", .{answer2});

}

pub fn calcSize(node: *FilesystemNode, sizes: *std.ArrayList(u32)) u32 {

    if (node.contents != null) {
        var total_size: u32 = 0;
        for (node.contents.?.items) |n| {
            var size = calcSize(n, sizes);
            if (n.size == 0) {
                sizes.append(size) catch { // laziest catch ever
                    return 0;
                };
            }
            total_size += size;
        }
        return total_size;
    } else {
        return node.size;
    }
}