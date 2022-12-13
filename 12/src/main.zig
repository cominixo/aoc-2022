
const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const width: u32 = 159;
const height: u32 = 41;

const Node = struct {
    id: u64,
    height: u8,
};

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var map: [height][width]u8 = undefined;
    var i: usize = 0;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        var heights: [width]u8 = undefined;
        for (line) |char, j| {
            if (char == 'S') {
                heights[j] = 0;
            } else if (char == 'E') {
                heights[j] = 25;
            } else {
                heights[j] = char - 'a';
            }
        }
        map[i] = heights;
    }

    var graph = std.ArrayList(std.ArrayList(Node)).init(allocator);
    var lowest_elev = std.ArrayList(u64).init(allocator);

    i = 0;
    while (i < height) : (i += 1) {
        var j: usize = 0;
        while (j < width) : (j += 1) {
            var nodes = std.ArrayList(Node).init(allocator);
            var index = j+i*width;

            if(map[i][j] == 0) {
                try lowest_elev.append(index);
            }

            if (i+1 < height) {
                if (map[i+1][j] <= map[i][j]+1) {
                    try nodes.append(Node {
                        .id = index+width,
                        .height = map[i+1][j],
                    });
                }
            }
            if (j+1 < width) {
                if (map[i][j+1] <= map[i][j]+1) {
                    try nodes.append(Node {
                        .id = index+1,
                        .height = map[i][j+1],
                    });
                }
            }
            if (i > 0) {
                if (map[i-1][j] <= map[i][j]+1) {
                    try nodes.append(Node {
                        .id = index-width,
                        .height = map[i-1][j],
                    });
                }
            }
            if (j > 0) {
                if (map[i][j-1] <= map[i][j]+1) {
                    try nodes.append(Node {
                        .id = index-1,
                        .height = map[i][j-1],
                    });
                }
            }

            try graph.append(nodes);

        }
    }

    var part2_path = try find_path(graph,lowest_elev);
    var part1_path = try find_path(graph,null);
    std.log.info("part 1: {d}", .{part1_path.items.len-1});
    std.log.info("part 2: {d}", .{part2_path.items.len-1});

}

fn containsId(arr: []Node, elem: u64) bool {
    for (arr) |n| {
        if (n.id == elem) return true;
    }
    return false;
}

fn contains(arr: []u64, elem: u64) bool {
    for (arr) |n| {
        if (n == elem) return true;
    }
    return false;
}

// bfs
fn find_path(graph: std.ArrayList(std.ArrayList(Node)), lowest_elev: ?std.ArrayList(u64)) !std.ArrayList(u64) {
    var path_arr = std.ArrayList(std.ArrayList(u64)).init(allocator);
    if (lowest_elev == null) {
        var starting_path = std.ArrayList(u64).init(allocator);
        try starting_path.append(3180); // part 1 hardcoded start position
        try path_arr.append(starting_path);
    } else {
        for (lowest_elev.?.items) |elev| {
            var path = std.ArrayList(u64).init(allocator);
            try path.append(elev);
            try path_arr.append(path);
        }
    }

    var index: u32 = 0;

    var visited = std.ArrayList(u64).init(allocator);

    while (index < path_arr.items.len) : (index += 1) {
        var path: std.ArrayList(u64) = path_arr.items[index];

        var final_node_ind = path.items[path.items.len-1];

        var next_nodes = graph.items[final_node_ind];

        if (containsId(next_nodes.items, 3315)) { // hardcoded end position
            try path.append(3315);
            return path;
        }

        for (next_nodes.items) |node| {
            if (contains(visited.items, node.id)) {
                continue;
            }
            var new_path = try std.ArrayList(u64).initCapacity(allocator, path.items.len);
            new_path.appendSliceAssumeCapacity(path.items);
            try new_path.append(node.id);
            try path_arr.append(new_path);
            try visited.append(node.id);
        }

    }
    unreachable;
}
