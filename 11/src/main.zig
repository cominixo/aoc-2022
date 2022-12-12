const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Monkey = struct {
    items: std.ArrayList(u64),
    operation: ?u8,
    operation_value: ?[]const u8,
    div_test: ?u32,
    monkey_test_true: ?*Monkey,
    monkey_test_false: ?*Monkey,
};

const monkey_total: u32 = 8;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;

    var monkeys: []Monkey = try allocator.alloc(Monkey, monkey_total);
    var monkey_ind: u32 = 0;
    while (monkey_ind < monkey_total) : (monkey_ind += 1) {
        monkeys[monkey_ind] = Monkey {
            .items = std.ArrayList(u64).init(allocator),
            .operation = null,
            .operation_value = null,
            .div_test = null,
            .monkey_test_true = null,
            .monkey_test_false = null,
        };
    }

    var common_multiple: u64 = 1;


    var current_monkey_read: u8 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linesplit = std.mem.split(u8, line, ": ");
        _ = linesplit.next();

        if (std.mem.startsWith(u8, line, "Monkey")) {
            current_monkey_read = try std.fmt.charToDigit(line[line.len-2], 10);
        }

        else if (std.mem.startsWith(u8, line, "  Starting items:")) {
            var items_str = std.mem.split(u8, linesplit.next().?, ",");
            while (items_str.next()) |item| {
                var item_int = try std.fmt.parseInt(u32, std.mem.trim(u8, item, " "), 10);
                try monkeys[current_monkey_read].items.append(item_int);
            } 
        }
        else if (std.mem.startsWith(u8, line, "  Operation:")) {
            var expression = linesplit.next().?;
            var expression_split = std.mem.split(u8, expression, " ");
            _ = expression_split.next();
            _ = expression_split.next();
            _ = expression_split.next(); // i love iterators
            monkeys[current_monkey_read].operation = expression_split.next().?[0];
            var op_value_str = expression_split.next().?;

            var op_value: []u8 = try allocator.alloc(u8, op_value_str.len);
            std.mem.copy(u8, op_value, op_value_str);

            monkeys[current_monkey_read].operation_value = op_value;
        }
        else if (std.mem.startsWith(u8, line, "  Test:")) {
            var split = std.mem.split(u8, linesplit.next().?, " ");
            _ = split.next();
            _ = split.next();
            var divisible_by = try std.fmt.parseInt(u32, split.next().?, 10);

            common_multiple *= divisible_by; // part 2

            monkeys[current_monkey_read].div_test = divisible_by;
        } else if (std.mem.startsWith(u8, line, "    If true:")) {
            var index_to_throw = try std.fmt.charToDigit(line[line.len-1], 10);
            monkeys[current_monkey_read].monkey_test_true = &monkeys[index_to_throw];
        } else if (std.mem.startsWith(u8, line, "    If false:")) {
            var index_to_throw = try std.fmt.charToDigit(line[line.len-1], 10);
            monkeys[current_monkey_read].monkey_test_false = &monkeys[index_to_throw];
        }
    
    }

    var n_rounds: u32 = 0;

    var monkey_inspects: [monkey_total]u32 = .{0}**monkey_total;

    while (n_rounds < 10000) : (n_rounds += 1) {

        for (monkeys) |*monkey, i| {
            for (monkey.items.items) |*item| {
                var op = monkey.operation.?;
                var op_valuestr = monkey.operation_value.?;
                var op_value: u64 = undefined;
                if (std.mem.eql(u8, op_valuestr, "old")) {
                    op_value = item.*;
                } else {
                    op_value = try std.fmt.parseInt(u32, op_valuestr, 10);
                }

                if (op == '*') {
                    item.* = item.* * op_value;
                } else {
                    item.* = item.* + op_value;
                }

                item.* = @mod(item.*, common_multiple);

                if (item.* % monkey.div_test.? == 0) {
                    try monkey.monkey_test_true.?.items.append(item.*);
                } else {
                    try monkey.monkey_test_false.?.items.append(item.*);
                }

                monkey_inspects[i] += 1;

            }
            monkey.items.clearAndFree();
        }
    }

    std.sort.sort(u32, monkey_inspects[0..], {}, comptime std.sort.desc(u32));


    std.log.info("{d} {d}", .{monkey_inspects[0], monkey_inspects[1]}); // i refuse to actually multiply these


}