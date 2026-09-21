const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // init allocator
    const io = init.io;
    const allocator = init.gpa;

    // структура для накопления ответа
    var response_body: std.Io.Writer.Allocating = .init(allocator);
    defer response_body.deinit(); // освобождение памяти после выхода

    // инициализируем клиента
    var client: std.http.Client = .{
        .allocator = allocator,
        .io = io,
    };
    defer client.deinit();

    // парсинг Url
    const uri = try std.Uri.parse("https://colportal.uni-college.ru/rasp/index.php");

    // буффур редиректов
    var redirect_buffer: [8 * 1024]u8 = undefined;

    // Get запрос
    const response = try client.fetch(.{
        .method = .GET,
        .location = .{ .uri = uri },
        .redirect_buffer = &redirect_buffer,
        .response_writer = &response_body.writer,
    });

    if (response.status != .ok) {
        std.debug.print("Ошибка сервера: {d}\n", .{@intFromEnum(response.status)});
    }

    // Ввод скаченного html
    const body = response_body.written();

    // Ввывод
    std.debug.print("Страница скаченна! длинна {d} байт. \n", .{body.len});
    std.debug.print("\t-----НАЧАЛО-----\n {s}\n \t-----КОНЕЦ-----\n", .{body});
}
