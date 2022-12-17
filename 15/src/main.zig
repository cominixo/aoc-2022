const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const target_y: i32 = 2000000;

const Range = struct {
    min: i32,
    max: i32,
};

const Point = struct{
    x: i32,
    y: i32,
};

pub fn main() anyerror!void {
    var buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");

    var point_set = std.AutoHashMap(i32, void).init(allocator);
    var rows_covered_per_line = std.AutoHashMap(i32, std.ArrayList(Range)).init(allocator);
    var lines_processed: u32 = 0;
    var i: i32 = 0;
    while (i <= 4000000) : (i += 1) {

        var range_arr = std.ArrayList(Range).init(allocator);
        try rows_covered_per_line.put(i, range_arr);
    }
    while (lines.next()) |line| {
        var line2 = line[12..];
        var coord_iter = std.mem.split(u8, line2, ": closest beacon is at x=");
        var coord1_iter = std.mem.split(u8, coord_iter.next().?, ", y=");
        var coord2_iter = std.mem.split(u8, coord_iter.next().?, ", y=");

        var sensor_x = try std.fmt.parseInt(i32, coord1_iter.next().?, 10);
        var sensor_y = try std.fmt.parseInt(i32, coord1_iter.next().?, 10);

        var beacon_x = try std.fmt.parseInt(i32, coord2_iter.next().?, 10);
        var beacon_y = try std.fmt.parseInt(i32, coord2_iter.next().?, 10);

        var dist_to_beacon = try std.math.absInt(sensor_x - beacon_x) + try std.math.absInt(sensor_y - beacon_y);
        var y_dist_to_target = try std.math.absInt(sensor_y - target_y);

        // part 1
        if (y_dist_to_target <= dist_to_beacon) {

            var min_x_covered = sensor_x - (dist_to_beacon - y_dist_to_target);
            var max_x_covered = sensor_x + (dist_to_beacon - y_dist_to_target);

            var x: i32 = min_x_covered;
            while (x <= max_x_covered) : (x += 1) {
                if (beacon_y != target_y or beacon_x != x)
                    try point_set.put(x, {});
            }

        }

        var y: i32 = 0;
        while (y <= 4000000) : (y += 1) {
            var dist_to_y = try std.math.absInt(sensor_y-y);
            if (dist_to_y <= dist_to_beacon) {

                var min_x_covered = sensor_x - (dist_to_beacon - dist_to_y);
                var max_x_covered = sensor_x + (dist_to_beacon - dist_to_y);

                    
                try rows_covered_per_line.getPtr(y).?.append(Range{
                    .min = min_x_covered,
                    .max = max_x_covered,
                });
  

            }
        }
        lines_processed += 1;
        std.log.info("line {d}", .{lines_processed});

    }
    var iter = rows_covered_per_line.iterator();

    var part2_set = std.AutoHashMap(Point, void).init(allocator);
    var c: u32 = 0;

    while (iter.next()) |entry| {
        for (entry.value_ptr.items) |val| {
            if (val.min > 0 and val.min <= 4000000) {
                var b: bool = false;
                for (entry.value_ptr.items) |val2| {
                    if (((val.min-1) >= val2.min) and (val.min-1) <= val2.max) {
                        b = true;
                    }
                }
                if (!b) {
                    try part2_set.put(Point {
                        .x = val.min-1,
                        .y = entry.key_ptr.*,
                    }, {});
                }
            }
        }
    }
    var it = part2_set.iterator();
    while (it.next()) |entry| {
        std.log.info("{d} {d}", .{entry.key_ptr.*.x, entry.key_ptr.*.y});
    }

    std.log.info("{d}", .{point_set.count()});
}

