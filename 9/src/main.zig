const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const Point = struct {x: i32, y: i32};

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var rope: []*Point = try allocator.alloc(*Point, 10);
    var count: usize = 0;
    while (count < rope.len) : (count += 1) {
        rope[count] = try allocator.create(Point);
        rope[count].x = 0;
        rope[count].y = 0;
    }

    var tiles_visited = std.AutoHashMap(Point, void).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linesplit = std.mem.split(u8, line, " ");
        var direction = linesplit.next().?[0];
        var amount = try std.fmt.parseInt(u8, linesplit.next().?, 10);

        var i: usize = 0;


        while (i < amount) : (i += 1){
            switch (direction) {
                'R' => {
                    rope[0].x += 1;
                },
                'L' => {
                    rope[0].x -= 1;
                },
                'U' => {
                    rope[0].y += 1;
                },
                'D' => {
                    rope[0].y -= 1;
                },
                else => unreachable,
            }

            for (rope[1..]) |knot, j| {
                var xdiff = rope[j].x - knot.x;
                var ydiff = rope[j].y - knot.y;

                var absxdiff = try std.math.absInt(xdiff);
                var absydiff = try std.math.absInt(ydiff);

                if (absxdiff == 0 or absydiff == 0) {
                    if (absxdiff > 1) rope[j+1].x += @divFloor(xdiff,absxdiff);
                    if (absydiff > 1) rope[j+1].y += @divFloor(ydiff,absydiff);
                } else if(absxdiff > 1 or absydiff > 1) {
                    rope[j+1].x += @divFloor(xdiff,absxdiff);
                    rope[j+1].y += @divFloor(ydiff,absydiff);
                }
            }

            try tiles_visited.put(rope[rope.len-1].*, {});

        }
    }
    std.log.info("{d}", .{tiles_visited.count()});
}