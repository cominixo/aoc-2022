const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = @import("std").debug.print;

const size: u32 = 99;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;

    var tree_map: [size][size]u8 = undefined;
    var tree_map_invert: [size][size]u8 = undefined;
    var i: usize = 0;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        var heights: [size]u8 = undefined;
        for (line) |char, j| {
            heights[j] = try std.fmt.charToDigit(char, 10);
        }
        tree_map[i] = heights;
    }

    for (tree_map) |_, j| {
        for (tree_map[j]) |item, k| {
            tree_map_invert[k][j] = item;
        }
    }

    var not_visible: u32 = 0;
    var max_score: u32 = 0;
    i = 1;
    while (i < tree_map.len-1) : (i += 1) {
        var j: usize = 1;
        while (j < tree_map.len-1) : (j += 1) {

            var tree_score: u32 = 0;
            var score_left: u32 = 0;
            var score_right: u32 = 0;
            var score_up: u32 = 0;
            var score_down: u32 = 0;

            var trees_blocking: u8 = 0;

            while (score_left < j) {
                score_left += 1;
                if (tree_map[i][j-score_left] >= tree_map[i][j]) {
                    trees_blocking += 1;
                    break;
                }
            }

            for (tree_map[i][j+1..]) |tree_right| {
                score_right += 1;
                if (tree_right >= tree_map[i][j]) {
                    trees_blocking += 1;
                    break;
                }
            }

            while (score_up < i) {
                score_up += 1;
                if (tree_map_invert[j][i-score_up] >= tree_map_invert[j][i]) {
                    trees_blocking += 1;
                    break;
                }
            }

            for (tree_map_invert[j][i+1..]) |tree_down| {
                score_down += 1;
                if (tree_down >= tree_map_invert[j][i]) {
                    trees_blocking += 1;
                    break;
                }
            }

            tree_score = score_left*score_right*score_up*score_down;

            if (tree_score > max_score) {
                max_score = tree_score;
            }

            if (trees_blocking >= 4) {
                not_visible += 1;
            }
        }
    }
    var visible = size*size - not_visible;


    std.log.info("{d} {d}", .{visible, max_score});
}