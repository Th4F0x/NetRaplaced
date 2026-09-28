const std = @import("std");
const zh = @import("html");

// main fnGG
pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    // инициализируем http
    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    // инициализируем буфер по новуму методу
    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    // парсинг Url
    const uri = try std.Uri.parse("https://colportal.uni-college.ru/rasp/index.php");

    // Get запрос
    const res = try client.fetch(.{
        .location = .{ .uri = uri },
        .method = .GET,
        .response_writer = &response_body.writer,
    });

    if (res.status != .ok) {
        std.debug.print("ошибка http {}", .{res.status});
    }

    // записываем в отдельную константу
    const html_str = response_body.written();

    const options: zh.ParseOptions = .{ .non_destructive = true };
    var doc = try options.parse(gpa, html_str);
    defer doc.deinit();

    // CSS селектор направленный на левую колонку групп
    var links = doc.query("body > div#cont > div#left > a.left_group");
    defer links.deinit();

    // счётчик для цикла
    var count: usize = 0;

    while ( try links.next()) |node| {
        count += 1;

        // попытка получения текста с данного селектора
        const text_result = try node.innerTextWithOptions(gpa, .{});
        defer text_result.free(gpa);

        // получаем через value
        const group = text_result.value;

        // получаем ссылки с href
        if (try node.getAttributeValue(gpa, "href")) |href| {
            defer href.free(gpa);

            // ввыводим результат на экран
            std.debug.print("{} - {s} ---> {s}\n", .{ count, group, href.value });
        }

        // выход из цыкла
        if (count >= 35) break;
    }
}
