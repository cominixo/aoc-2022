const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const Point = struct {
    x: u32,
    y: u32,
};



pub fn main() anyerror!void {
    var buf = @embedFile("input");

    var lists = std.mem.split(u8, buf, "\n");
    var grid = std.AutoHashMap(Point, void).init(allocator);
    var walls = std.ArrayList(std.ArrayList(Point)).init(allocator);

    var biggest_y: u32 = 0;

    while (lists.next()) |line| {
        var splitarrow = std.mem.split(u8, line, " -> ");
        var wall = std.ArrayList(Point).init(allocator);
        while (splitarrow.next()) |point| {
            var pointsplit = std.mem.split(u8, point, ",");
            var xstr = pointsplit.next().?;
            var ystr = pointsplit.next().?;

            var x = try std.fmt.parseInt(u32, xstr, 10);
            var y = try std.fmt.parseInt(u32, ystr, 10);

            if (y > biggest_y) biggest_y = y;


            try wall.append(Point {
                .x = x, 
                .y = y,
            });

        }
        try walls.append(wall);
    }

    for (walls.items) |wall| {
        var i: u32 = 0;
        while (i < wall.items.len-1) : (i += 1) {
            if (wall.items[i].x == wall.items[i+1].x) {

                var max_y = @max(wall.items[i].y, wall.items[i+1].y);
                var min_y = @min(wall.items[i].y, wall.items[i+1].y);

                while (min_y <= max_y) : (min_y += 1) {

                    try grid.put(Point {
                        .x = wall.items[i].x,
                        .y = min_y,
                    }, {});
                }

            }

            if (wall.items[i].y == wall.items[i+1].y) {

                var max_x = @max(wall.items[i].x, wall.items[i+1].x);
                var min_x = @min(wall.items[i].x, wall.items[i+1].x);

                while (min_x <= max_x) : (min_x += 1) {

                    try grid.put(Point {
                        .x = min_x,
                        .y = wall.items[i].y,
                    }, {});
                }

            }
        }
    }

    biggest_y += 2;

    var all_sand = std.ArrayList(Point).init(allocator);

    var start_pos = Point {
        .x = 500,
        .y = 0,
    };

    var zero_pos = Point {
        .x = 0,
        .y = 0,
    };

    outer: while (true) {
        var sand_pos = &start_pos;
        var prev_sand_pos = &zero_pos;

        var new_pos = sand_pos.*;

        while (sand_pos.x != prev_sand_pos.x or sand_pos.y != prev_sand_pos.y) {
            new_pos.y += 1;

            //if (new_pos.y > 200) break :outer; // bad hardcoded part 1
            
            if (is_wall(grid, biggest_y, new_pos)) {
                
                
                new_pos.x -= 1;
                if (is_wall(grid, biggest_y, new_pos)) {

                    new_pos.x += 2;
                    if (is_wall(grid, biggest_y, new_pos)) {
                        new_pos.x -= 1;
                        new_pos.y -= 1;

                        try all_sand.append(new_pos);
                        try grid.put(new_pos, {});
                        prev_sand_pos.* = new_pos;

                        if (new_pos.x == 500 and new_pos.y == 0) {
                            break :outer;
                        }

                        break;
                    }
                }

            }
        }
    }
    std.log.info("{d}", .{all_sand.items.len});
}

fn is_wall(grid: std.AutoHashMap(Point, void), y_limit: u32, point: Point) bool {
    
    if (point.y >= y_limit) {
        return true;
    }
    return grid.contains(point);

}