const std = @import("std");

const Shape = enum(u2) {
    ROCK=1,
    PAPER=2,
    SCISSORS=3,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();


fn get_shape(char: u8) Shape {
    return switch (char) {
        'A','X' => Shape.ROCK,
        'B','Y' => Shape.PAPER,
        'C','Z' => Shape.SCISSORS,
        else => {
            @panic("aaaaaaaaaaaaa");
        },
    };
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var shape_wins = std.AutoHashMap(Shape, Shape).init(allocator);
    defer shape_wins.deinit();

    try shape_wins.put(Shape.ROCK, Shape.SCISSORS);
    try shape_wins.put(Shape.PAPER, Shape.ROCK);
    try shape_wins.put(Shape.SCISSORS, Shape.PAPER);

    var shape_loses = std.AutoHashMap(Shape, Shape).init(allocator);
    defer shape_loses.deinit();

    try shape_loses.put(Shape.SCISSORS, Shape.ROCK);
    try shape_loses.put(Shape.ROCK, Shape.PAPER);
    try shape_loses.put(Shape.PAPER, Shape.SCISSORS);

    var total_score: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var slices = std.mem.split(u8, line, " ");
        var opponent_shape = get_shape(slices.next().?[0]);
        var code2 = slices.next().?[0];

        // part1
        //var my_shape = get_shape(code2);

        //var outcome: i32 = 3; // default to draw

        //if (shape_wins.get(opponent_shape) == my_shape) {
        //    outcome = 0;
        //}

        //if (shape_wins.get(my_shape) == opponent_shape) {
        //    outcome = 6;
        //}

        // part 2
        var outcome: u8 = 0;
        var my_shape = switch (code2) {
            'X' => shape_wins.get(opponent_shape).?,
            
            'Y' => blk: {
                outcome = 3;
                break :blk opponent_shape;
            },

            'Z' => blk: {
                outcome = 6;
                break :blk shape_loses.get(opponent_shape).?;
            },

            else => {
                @panic("aaaaaaaaa");
            },
        };
        total_score += @enumToInt(my_shape) + outcome;

    }
    std.log.info("{d}", .{total_score});
}