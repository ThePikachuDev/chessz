const std = @import("std");
const rl = @import("raylib");

const PieceType = enum {
    none,
    pawn,
    rook,
    knight,
    bishop,
    queen,
    king,
};

const PieceColor = enum {
    none,
    white,
    black,
};

const ChessPiece = struct {
    piece_type: PieceType,
    color: PieceColor,
};

// Chess piece textures structure
const ChessPieceTextures = struct {
    b_bishop: rl.Texture2D,
    b_king: rl.Texture2D,
    b_knight: rl.Texture2D,
    b_pawn: rl.Texture2D,
    b_queen: rl.Texture2D,
    b_rook: rl.Texture2D,
    w_bishop: rl.Texture2D,
    w_king: rl.Texture2D,
    w_knight: rl.Texture2D,
    w_pawn: rl.Texture2D,
    w_queen: rl.Texture2D,
    w_rook: rl.Texture2D,

    fn init() !ChessPieceTextures {
        return ChessPieceTextures{
            .b_bishop = try rl.loadTexture("assets/B_Bishop.png"),
            .b_king = try rl.loadTexture("assets/B_King.png"),
            .b_knight = try rl.loadTexture("assets/B_Knight.png"),
            .b_pawn = try rl.loadTexture("assets/B_Pawn.png"),
            .b_queen = try rl.loadTexture("assets/B_Queen.png"),
            .b_rook = try rl.loadTexture("assets/B_Rook.png"),
            .w_bishop = try rl.loadTexture("assets/W_Bishop.png"),
            .w_king = try rl.loadTexture("assets/W_King.png"),
            .w_knight = try rl.loadTexture("assets/W_Knight.png"),
            .w_pawn = try rl.loadTexture("assets/W_Pawn.png"),
            .w_queen = try rl.loadTexture("assets/W_Queen.png"),
            .w_rook = try rl.loadTexture("assets/W_Rook.png"),
        };
    }

    fn deinit(self: *ChessPieceTextures) void {
        rl.unloadTexture(self.b_bishop);
        rl.unloadTexture(self.b_king);
        rl.unloadTexture(self.b_knight);
        rl.unloadTexture(self.b_pawn);
        rl.unloadTexture(self.b_queen);
        rl.unloadTexture(self.b_rook);
        rl.unloadTexture(self.w_bishop);
        rl.unloadTexture(self.w_king);
        rl.unloadTexture(self.w_knight);
        rl.unloadTexture(self.w_pawn);
        rl.unloadTexture(self.w_queen);
        rl.unloadTexture(self.w_rook);
    }

    fn getTexture(self: *const ChessPieceTextures, piece: ChessPiece) ?rl.Texture2D {
        return switch (piece.color) {
            .black => switch (piece.piece_type) {
                .bishop => self.b_bishop,
                .king => self.b_king,
                .knight => self.b_knight,
                .pawn => self.b_pawn,
                .queen => self.b_queen,
                .rook => self.b_rook,
                .none => null,
            },
            .white => switch (piece.piece_type) {
                .bishop => self.w_bishop,
                .king => self.w_king,
                .knight => self.w_knight,
                .pawn => self.w_pawn,
                .queen => self.w_queen,
                .rook => self.w_rook,
                .none => null,
            },
            .none => null,
        };
    }
};

// Initialize chess board with starting position
fn initChessBoard() [8][8]ChessPiece {
    var board: [8][8]ChessPiece = undefined;

    // Initialize empty squares
    for (0..8) |row| {
        for (0..8) |col| {
            board[row][col] = ChessPiece{ .piece_type = .none, .color = .none };
        }
    }

    // Set up black pieces (rows 0 and 1)
    const black_back_row = [_]PieceType{ .rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook };
    for (black_back_row, 0..) |piece_type, col| {
        board[0][col] = ChessPiece{ .piece_type = piece_type, .color = .black };
    }
    for (0..8) |col| {
        board[1][col] = ChessPiece{ .piece_type = .pawn, .color = .black };
    }

    // Set up white pieces (rows 6 and 7)
    for (0..8) |col| {
        board[6][col] = ChessPiece{ .piece_type = .pawn, .color = .white };
    }
    const white_back_row = [_]PieceType{ .rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook };
    for (white_back_row, 0..) |piece_type, col| {
        board[7][col] = ChessPiece{ .piece_type = piece_type, .color = .white };
    }

    return board;
}

pub fn drawBordersOfCell(SelectorRec: rl.Rectangle) void {
    const rec_x: i32 = @intFromFloat(SelectorRec.x);
    const rec_y: i32 = @intFromFloat(SelectorRec.y);
    const rec_width: i32 = @intFromFloat(SelectorRec.width);
    const rec_height: i32 = @intFromFloat(SelectorRec.height);

    const cell_gap: i32 = 4;
    const cell_thickness: i32 = 3;
    const segment_len: i32 = @divTrunc(rec_width, 3);

    const border_color = rl.Color.beige;
    // Top-left corner
    rl.drawRectangle(rec_x - cell_gap, rec_y - cell_gap, segment_len, cell_thickness, border_color);
    rl.drawRectangle(rec_x - cell_gap, rec_y - cell_gap, cell_thickness, segment_len, border_color);

    // Top-right corner
    rl.drawRectangle(rec_x + rec_width - segment_len + cell_gap, rec_y - cell_gap, segment_len, cell_thickness, border_color);
    rl.drawRectangle(rec_x + rec_width + cell_gap - cell_thickness, rec_y - cell_gap, cell_thickness, segment_len, border_color);

    // Bottom-left corner
    rl.drawRectangle(rec_x - cell_gap, rec_y + rec_height + cell_gap - cell_thickness, segment_len, cell_thickness, border_color);
    rl.drawRectangle(rec_x - cell_gap, rec_y + rec_height - segment_len + cell_gap, cell_thickness, segment_len, border_color);

    // Bottom-right corner
    rl.drawRectangle(rec_x + rec_width - segment_len + cell_gap, rec_y + rec_height + cell_gap - cell_thickness, segment_len, cell_thickness, border_color);
    rl.drawRectangle(rec_x + rec_width + cell_gap - cell_thickness, rec_y + rec_height - segment_len + cell_gap, cell_thickness, segment_len, border_color);
}

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 600;

    rl.initWindow(screenWidth, screenHeight, "Chess Grid");
    defer rl.closeWindow();

    // Initialize textures and board AFTER window creation
    var piece_textures = ChessPieceTextures.init() catch |err| {
        std.debug.print("Failed to load textures: {}\n", .{err});
        return;
    };
    defer piece_textures.deinit();

    const chess_board = initChessBoard();

    const rectWidth: f32 = 400;
    const rectHeight: f32 = 400;

    const outerRect = rl.Rectangle{
        .x = @as(f32, @floatFromInt(screenWidth)) / 2 - rectWidth / 2,
        .y = @as(f32, @floatFromInt(screenHeight)) / 2 - rectHeight / 2,
        .width = rectWidth,
        .height = rectHeight,
    };

    const rows = 8;
    const cols = 8;
    const cellWidth = outerRect.width / cols;
    const cellHeight = outerRect.height / rows;

    var RowIdxCell: u16 = 0;
    var ColIdxCell: u16 = 0;

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);

        rl.drawRectangleLinesEx(outerRect, 2.0, rl.Color.white);

        // Handle input
        if (rl.isKeyPressed(.j) and ColIdxCell < 7) {
            ColIdxCell += 1;
        }
        if (rl.isKeyPressed(.k) and ColIdxCell > 0) {
            ColIdxCell -= 1;
        }
        if (rl.isKeyPressed(.h) and RowIdxCell > 0) {
            RowIdxCell -= 1;
        }
        if (rl.isKeyPressed(.l) and RowIdxCell < 7) {
            RowIdxCell += 1;
        }

        const SelectorRec = rl.Rectangle{
            .x = outerRect.x + @as(f32, @floatFromInt(RowIdxCell)) * cellWidth - 2,
            .y = outerRect.y + @as(f32, @floatFromInt(ColIdxCell)) * cellHeight - 2,
            .width = cellWidth + 4,
            .height = cellHeight + 4,
        };

        // Draw chess grid inside the outer rectangle
        var row: usize = 0;
        while (row < rows) : (row += 1) {
            var col: usize = 0;
            while (col < cols) : (col += 1) {
                const x_of_cell = outerRect.x + @as(f32, @floatFromInt(col)) * cellWidth;
                const y_of_cell = outerRect.y + @as(f32, @floatFromInt(row)) * cellHeight;
                const color = if ((row + col) % 2 == 0)
                    rl.Color.ray_white
                else
                    rl.Color.dark_gray;

                // Drawing cell
                rl.drawRectangleRec(rl.Rectangle{
                    .x = x_of_cell,
                    .y = y_of_cell,
                    .width = cellWidth,
                    .height = cellHeight,
                }, color);

                rl.drawRectangleLinesEx(rl.Rectangle{
                    .x = x_of_cell,
                    .y = y_of_cell,
                    .width = cellWidth,
                    .height = cellHeight,
                }, 1, .black);

                // Draw pieces using textures
                const current_piece = chess_board[row][col];
                if (current_piece.piece_type != .none) {
                    if (piece_textures.getTexture(current_piece)) |texture| {
                        const pieceSize = cellWidth * 0.85;
                        // const pieceWidth = 38;
                        // const pieceHeight = 40;
                        const pieceX = x_of_cell + (cellWidth - pieceSize) / 2;
                        const pieceY = y_of_cell + (cellHeight - pieceSize) / 2;

                        rl.drawTexturePro(texture, rl.Rectangle{
                            .x = 0,
                            .y = 0,
                            .width = @floatFromInt(texture.width),
                            .height = @floatFromInt(texture.height),
                        }, rl.Rectangle{
                            .x = pieceX,
                            .y = pieceY,
                            .width = pieceSize,
                            .height = pieceSize,
                        }, rl.Vector2{ .x = 0, .y = 0 }, 0.0, rl.Color.white);
                    }
                }
            }
        }

        // Draw selection rectangle
        rl.drawRectangleLinesEx(SelectorRec, 3, .black);

        drawBordersOfCell(SelectorRec);

        // Draw position indicator
        const allocator = std.heap.page_allocator;
        const positionText = std.fmt.allocPrintZ(allocator, "Row: {}, Col: {}", .{ RowIdxCell, ColIdxCell }) catch "Position: Error";
        defer allocator.free(positionText);
        rl.drawText(positionText, 10, 10, 20, .white);

        rl.endDrawing();
    }
}

// const std = @import("std");
// const rl = @import("raylib");
//
// var piece_textures = ChessPieceTextures.init();
// var chess_board = initChessBoard();
//
// const PieceType = enum {
//     none,
//     pawn,
//     rook,
//     knight,
//     bishop,
//     queen,
//     king,
// };
//
// const PieceColor = enum {
//     none,
//     white,
//     black,
// };
//
// const ChessPiece = struct {
//     piece_type: PieceType,
//     color: PieceColor,
// };
//
// // Chess piece textures structure
// const ChessPieceTextures = struct {
//     b_bishop: rl.Texture2D,
//     b_king: rl.Texture2D,
//     b_knight: rl.Texture2D,
//     b_pawn: rl.Texture2D,
//     b_queen: rl.Texture2D,
//     b_rook: rl.Texture2D,
//     w_bishop: rl.Texture2D,
//     w_king: rl.Texture2D,
//     w_knight: rl.Texture2D,
//     w_pawn: rl.Texture2D,
//     w_queen: rl.Texture2D,
//     w_rook: rl.Texture2D,
//
//     fn init() ChessPieceTextures {
//         return ChessPieceTextures{
//             .b_bishop = rl.loadTexture("assets/B_Bishop.png"),
//             .b_king = rl.loadTexture("assets/B_King.png"),
//             .b_knight = rl.loadTexture("assets/B_Knight.png"),
//             .b_pawn = rl.loadTexture("assets/B_Pawn.png"),
//             .b_queen = rl.loadTexture("assets/B_Queen.png"),
//             .b_rook = rl.loadTexture("assets/B_Rook.png"),
//             .w_bishop = rl.loadTexture("assets/W_Bishop.png"),
//             .w_king = rl.loadTexture("assets/W_King.png"),
//             .w_knight = rl.loadTexture("assets/W_Knight.png"),
//             .w_pawn = rl.loadTexture("assets/W_Pawn.png"),
//             .w_queen = rl.loadTexture("assets/W_Queen.png"),
//             .w_rook = rl.loadTexture("assets/W_Rook.png"),
//         };
//     }
//
//     fn deinit(self: *ChessPieceTextures) void {
//         rl.unloadTexture(self.b_bishop);
//         rl.unloadTexture(self.b_king);
//         rl.unloadTexture(self.b_knight);
//         rl.unloadTexture(self.b_pawn);
//         rl.unloadTexture(self.b_queen);
//         rl.unloadTexture(self.b_rook);
//         rl.unloadTexture(self.w_bishop);
//         rl.unloadTexture(self.w_king);
//         rl.unloadTexture(self.w_knight);
//         rl.unloadTexture(self.w_pawn);
//         rl.unloadTexture(self.w_queen);
//         rl.unloadTexture(self.w_rook);
//     }
//
//     fn getTexture(self: *const ChessPieceTextures, piece: ChessPiece) ?rl.Texture2D {
//         return switch (piece.color) {
//             .black => switch (piece.piece_type) {
//                 .bishop => self.b_bishop,
//                 .king => self.b_king,
//                 .knight => self.b_knight,
//                 .pawn => self.b_pawn,
//                 .queen => self.b_queen,
//                 .rook => self.b_rook,
//                 .none => null,
//             },
//             .white => switch (piece.piece_type) {
//                 .bishop => self.w_bishop,
//                 .king => self.w_king,
//                 .knight => self.w_knight,
//                 .pawn => self.w_pawn,
//                 .queen => self.w_queen,
//                 .rook => self.w_rook,
//                 .none => null,
//             },
//             .none => null,
//         };
//     }
// };
//
// // Initialize chess board with starting position
// fn initChessBoard() [8][8]ChessPiece {
//     var board: [8][8]ChessPiece = undefined;
//
//     // Initialize empty squares
//     for (0..8) |row| {
//         for (0..8) |col| {
//             board[row][col] = ChessPiece{ .piece_type = .none, .color = .none };
//         }
//     }
//
//     // Set up black pieces (rows 0 and 1)
//     const black_back_row = [_]PieceType{ .rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook };
//     for (black_back_row, 0..) |piece_type, col| {
//         board[0][col] = ChessPiece{ .piece_type = piece_type, .color = .black };
//     }
//     for (0..8) |col| {
//         board[1][col] = ChessPiece{ .piece_type = .pawn, .color = .black };
//     }
//
//     // Set up white pieces (rows 6 and 7)
//     for (0..8) |col| {
//         board[6][col] = ChessPiece{ .piece_type = .pawn, .color = .white };
//     }
//     const white_back_row = [_]PieceType{ .rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook };
//     for (white_back_row, 0..) |piece_type, col| {
//         board[7][col] = ChessPiece{ .piece_type = piece_type, .color = .white };
//     }
//
//     return board;
// }
//
// pub fn drawBordersOfCell(SelectorRec: rl.Rectangle) !void {
//     const rec_x: i32 = @intFromFloat(SelectorRec.x);
//     const rec_y: i32 = @intFromFloat(SelectorRec.y);
//     const rec_width: i32 = @intFromFloat(SelectorRec.width);
//     const rec_height: i32 = @intFromFloat(SelectorRec.height);
//
//     const cell_gap: i32 = 4;
//     const cell_thickness: i32 = 2;
//     const segment_len: i32 = @divTrunc(rec_width, 3); // Adjust this if needed
//
//     const border_color = rl.Color.sky_blue;
//     // Top-left corner
//     rl.drawRectangle(rec_x - cell_gap, rec_y - cell_gap, segment_len, cell_thickness, border_color); // horizontal
//     rl.drawRectangle(rec_x - cell_gap, rec_y - cell_gap, cell_thickness, segment_len, border_color); // vertical
//
//     // Top-right corner
//     rl.drawRectangle(rec_x + rec_width - segment_len + cell_gap, rec_y - cell_gap, segment_len, cell_thickness, border_color); // horizontal
//     rl.drawRectangle(rec_x + rec_width + cell_gap - cell_thickness, rec_y - cell_gap, cell_thickness, segment_len, border_color); // vertical
//
//     // Bottom-left corner
//     rl.drawRectangle(rec_x - cell_gap, rec_y + rec_height + cell_gap - cell_thickness, segment_len, cell_thickness, border_color); // horizontal
//     rl.drawRectangle(rec_x - cell_gap, rec_y + rec_height - segment_len + cell_gap, cell_thickness, segment_len, border_color); // vertical
//
//     // Bottom-right corner
//     rl.drawRectangle(rec_x + rec_width - segment_len + cell_gap, rec_y + rec_height + cell_gap - cell_thickness, segment_len, cell_thickness, border_color); // horizontal
//     rl.drawRectangle(rec_x + rec_width + cell_gap - cell_thickness, rec_y + rec_height - segment_len + cell_gap, cell_thickness, segment_len, border_color); // vertical
//
//     // const x: i32 = @intFromFloat(SelectorRec.x);
//     // const y: i32 = @intFromFloat(SelectorRec.y);
//     // const w: i32 = @intFromFloat(SelectorRec.width);
//     // const h: i32 = @intFromFloat(SelectorRec.height);
//     // const x2 = x + w;
//     // const y2 = y + h;
//     // const len = 15; // corner length
//     // const border_color = rl.Color.blue;
//     //
//     // // Top-left corner
//     // rl.drawLine(x, y, x + len, y, border_color); // horizontal
//     // rl.drawLine(x, y, x, y + len, border_color); // vertical
//     // rl.drawLine(x, y + 1, x + len, y + 1, border_color); // horizontal
//     // rl.drawLine(x + 1, y, x, y + len + 1, border_color); // vertical
//     // rl.drawLine(x, y + 2, x + len, y + 2, border_color); // horizontal
//     // rl.drawLine(x + 2, y, x, y + len + 2, border_color); // vertical
//     //
//     // // Top-right corner
//     // rl.drawLine(x2 - len, y, x2, y, border_color); // horizontal
//     // rl.drawLine(x2, y, x2, y + len, border_color); // vertical
//     //
//     // // Bottom-left corner
//     // rl.drawLine(x, y2, x + len, y2, border_color); // horizontal
//     // rl.drawLine(x, y2 - len, x, y2, border_color); // vertical
//     //
//     // // Bottom-right corner
//     // rl.drawLine(x2 - len, y2, x2, y2, border_color); // horizontal
//     // rl.drawLine(x2, y2 - len, x2, y2, border_color); // vertical
//
// }
//
// pub fn main() void {
//     const screenWidth = 800;
//     const screenHeight = 600;
//
//     rl.initWindow(screenWidth, screenHeight, "Chess Grid");
//     defer rl.closeWindow();
//     const rectWidth: f32 = 400;
//     const rectHeight: f32 = 400;
//
//     const outerRect = rl.Rectangle{
//         .x = @as(f32, @floatFromInt(screenWidth)) / 2 - rectWidth / 2,
//         .y = @as(f32, @floatFromInt(screenHeight)) / 2 - rectHeight / 2,
//         .width = rectWidth,
//         .height = rectHeight,
//     };
//
//     const rows = 8;
//     const cols = 8;
//     const cellWidth = outerRect.width / cols;
//     const cellHeight = outerRect.height / rows;
//
//     var RowIdxCell: u16 = 0;
//     var ColIdxCell: u16 = 0;
//
//     // Add delay for key presses
//
//     while (!rl.windowShouldClose()) {
//         rl.beginDrawing();
//         rl.clearBackground(rl.Color.black);
//
//         rl.drawRectangleLinesEx(outerRect, 2.0, rl.Color.white);
//
//         // Handle input with delay to prevent too fast movement
//         if (rl.isKeyPressed(.j) and ColIdxCell < 7) {
//             ColIdxCell += 1;
//         }
//         if (rl.isKeyPressed(.k) and ColIdxCell > 0) {
//             ColIdxCell -= 1;
//         }
//         if (rl.isKeyPressed(.h) and RowIdxCell > 0) {
//             RowIdxCell -= 1;
//         }
//         if (rl.isKeyPressed(.l) and RowIdxCell < 7) {
//             RowIdxCell += 1;
//         }
//
//         const SelectorRec = rl.Rectangle{
//             .x = outerRect.x + @as(f32, @floatFromInt(RowIdxCell)) * cellWidth - 2,
//             .y = outerRect.y + @as(f32, @floatFromInt(ColIdxCell)) * cellHeight - 2,
//             .width = cellWidth + 4,
//             .height = cellHeight + 4,
//         };
//         // rl.drawRectangleLines(@intFromFloat(SelectorRec.x), @intFromFloat(SelectorRec.y), @intFromFloat(SelectorRec.x + (SelectorRec.width)), 9, .blue);
//
//         // SelectorRec.x , SelectorRec.y , SelectorRec.width/3, 3, blue
//         // rl.drawLine(@intFromFloat(SelectorRec.x), @intFromFloat(SelectorRec.y ), @intFromFloat(SelectorRec.x + (SelectorRec.width)), @intFromFloat(SelectorRec.y), .blue);
//
//         // Draw chess grid inside the outer rectangle
//         var row: usize = 0;
//         while (row < rows) : (row += 1) {
//             var col: usize = 0;
//             while (col < cols) : (col += 1) {
//                 const x_of_cell = outerRect.x + @as(f32, @floatFromInt(col)) * cellWidth;
//                 const y_of_cell = outerRect.y + @as(f32, @floatFromInt(row)) * cellHeight;
//                 const color = if ((row + col) % 2 == 0)
//                     rl.Color.ray_white
//                 else
//                     rl.Color.dark_gray;
//
//                 // Drawing cell
//                 rl.drawRectangleRec(rl.Rectangle{
//                     .x = x_of_cell,
//                     .y = y_of_cell,
//                     .width = cellWidth,
//                     .height = cellHeight,
//                 }, color);
//
//                 rl.drawRectangleLinesEx(rl.Rectangle{
//                     .x = x_of_cell,
//                     .y = y_of_cell,
//                     .width = cellWidth,
//                     .height = cellHeight,
//                 }, 1, .black);
//
//                 // Draw pieces using textures
//                 const current_piece = chess_board[row][col];
//                 if (current_piece.piece_type != .none) {
//                     if (piece_textures.getTexture(current_piece)) |texture| {
//                         const pieceSize = cellWidth * 0.8; // Use 80% of cell size
//                         const pieceX = x_of_cell + (cellWidth - pieceSize) / 2;
//                         const pieceY = y_of_cell + (cellHeight - pieceSize) / 2;
//
//                         rl.drawTexturePro(texture, rl.Rectangle{ // source rectangle (entire texture)
//                             .x = 0,
//                             .y = 0,
//                             .width = @floatFromInt(texture.width),
//                             .height = @floatFromInt(texture.height),
//                         }, rl.Rectangle{ // destination rectangle
//                             .x = pieceX,
//                             .y = pieceY,
//                             .width = pieceSize,
//                             .height = pieceSize,
//                         }, rl.Vector2{ .x = 0, .y = 0 }, // origin
//                             0.0, // rotation
//                             rl.Color.white // tint
//                         );
//                     }
//                 }
//             }
//         }
//         // // Draw chess grid inside the outer rectangle
//         // var row: usize = 0;
//         // while (row < rows) : (row += 1) {
//         //     var col: usize = 0;
//         //     while (col < cols) : (col += 1) {
//         //         const x_of_cell = outerRect.x + @as(f32, @floatFromInt(col)) * cellWidth;
//         //         const y_of_cell = outerRect.y + @as(f32, @floatFromInt(row)) * cellHeight;
//         //
//         //         const color = if ((row + col) % 2 == 0)
//         //             rl.Color.ray_white
//         //         else
//         //             rl.Color.dark_gray;
//         //
//         //         // drawing cell
//         //         rl.drawRectangleRec(rl.Rectangle{
//         //             .x = x_of_cell,
//         //             .y = y_of_cell,
//         //             .width = cellWidth,
//         //             .height = cellHeight,
//         //         }, color);
//         //
//         //         rl.drawRectangleLinesEx(rl.Rectangle{
//         //             .x = x_of_cell,
//         //             .y = y_of_cell,
//         //             .width = cellWidth,
//         //             .height = cellHeight,
//         //         }, 1, .black);
//         //
//         //         // Draw pieces
//         //         const pieceSize = cellWidth / 2.5;
//         //         const pieceX = x_of_cell + (cellWidth - pieceSize) / 2;
//         //         const pieceY = y_of_cell + (cellHeight - pieceSize) / 2;
//         //
//         //         if (row == 0 or row == 1) { // Black pieces
//         //             rl.drawRectangleRec(rl.Rectangle{
//         //                 .x = pieceX,
//         //                 .y = pieceY,
//         //                 .width = pieceSize,
//         //                 .height = pieceSize,
//         //             }, .black);
//         //         } else if (row == 6 or row == 7) { // White pieces
//         //             rl.drawRectangleRec(rl.Rectangle{
//         //                 .x = pieceX,
//         //                 .y = pieceY,
//         //                 .width = pieceSize,
//         //                 .height = pieceSize,
//         //             }, .white);
//         //         }
//         //     }
//         // }
//         //
//         // Draw selection rectangle
//         rl.drawRectangleLinesEx(SelectorRec, 3, .black);
//
//         try drawBordersOfCell(SelectorRec);
//         // Draw position indicator
//         const positionText = std.fmt.allocPrintZ(std.heap.page_allocator, "Row: {}, Col: {}", .{ RowIdxCell, ColIdxCell }) catch unreachable;
//         defer std.heap.page_allocator.free(positionText);
//         rl.drawText(positionText, 10, 10, 20, .white);
//
//         rl.endDrawing();
//         piece_textures.deinit();
//     }
// }

// const std = @import("std");
// const rl = @import("raylib");
//
// pub fn main() void {
//     const screenWidth = 800;
//     const screenHeight = 600;
//
//     rl.initWindow(screenWidth, screenHeight, "Chess Grid");
//     defer rl.closeWindow();
//     const rectWidth: f32 = 400;
//     const rectHeight: f32 = 400;
//
//     const outerRect = rl.Rectangle{
//         .x = @as(f32, @floatFromInt(screenWidth)) / 2 - rectWidth / 2,
//         .y = @as(f32, @floatFromInt(screenHeight)) / 2 - rectHeight / 2,
//         .width = rectWidth,
//         .height = rectHeight,
//     };
//
//     const rows = 8;
//     const cols = 8;
//     const cellWidth = outerRect.width / cols;
//     const cellHeight = outerRect.height / rows;
//
//     var RowIdxCell: u16 = 0;
//     var ColIdxCell: u16 = 0;
//     while (!rl.windowShouldClose()) {
//         rl.beginDrawing();
//         rl.clearBackground(rl.Color.black);
//
//         rl.drawRectangleLinesEx(outerRect, 2.0, rl.Color.black);
//
//         if (rl.isKeyDown(.j) and ColIdxCell < 7) {
//             rl.drawText("J pressed", 10, 10, 35, .white);
//             ColIdxCell += 1;
//         }
//         if (rl.isKeyDown(.k) and ColIdxCell > 0) {
//             ColIdxCell -= 1;
//             rl.drawText("K pressed", 10, 10, 35, .white);
//         }
//         if (rl.isKeyDown(.h) and RowIdxCell > 0) {
//             RowIdxCell -= 1;
//             rl.drawText("H pressed", 10, 10, 35, .white);
//         }
//         if (rl.isKeyDown(.l) and RowIdxCell < 7) {
//             RowIdxCell += 1;
//             rl.drawText("L pressed", 10, 10, 35, .white);
//         }
//
//         const SelectorRec = rl.Rectangle{
//             .x = outerRect.x + @as(f32, @floatFromInt(RowIdxCell)) * cellWidth,
//             // .x =
//             // .x = 0,
//             // .y = 0,
//             .y = outerRect.y + @as(f32, @floatFromInt(ColIdxCell)) * cellHeight,
//             .height = cellHeight + 4,
//             .width = cellWidth + 4,
//         };
//         // Draw chess grid inside the outer rectangle
//         var row: usize = 0;
//         while (row < rows) : (row += 1) {
//             var col: usize = 0;
//             while (col < cols) : (col += 1) {
//                 // x , y  = outerRect.x,y + 4,0 + cellWidht
//                 // colIdxCell , RowIdxCell
//                 //
//                 //
//                 const x_of_cell = outerRect.x + @as(f32, @floatFromInt(col)) * cellWidth;
//                 const y_of_cell = outerRect.y + @as(f32, @floatFromInt(row)) * cellHeight;
//
//                 const color = if ((row + col) % 2 == 0)
//                     rl.Color.light_gray
//                 else
//                     rl.Color.dark_gray;
//
//                 // drawing cell
//                 rl.drawRectangleRec(rl.Rectangle{
//                     .x = x_of_cell,
//                     .y = y_of_cell,
//                     .width = cellWidth,
//                     .height = cellHeight,
//                 }, color);
//
//                 // rl.drawRectangleLinesEx(SelectorRec, lineThick: f32, color: Color)
//
//                 rl.drawRectangleLinesEx(rl.Rectangle{
//                     .x = x_of_cell,
//                     .y = y_of_cell,
//                     .width = cellWidth,
//                     .height = cellHeight,
//                 }, 1, .black);
//                 // draws elem inside cell
//                 const innerCellX = x_of_cell + (cellWidth / 4);
//
//                 const innerCellY = y_of_cell + (cellHeight / 4);
//
//                 // Convert integer to string and get the slice
//
//                 // Null-terminate it manually for C compatibility
//
//                 if (row <= 1) {
//                     rl.drawRectangleRec(rl.Rectangle{
//                         .x = innerCellX,
//                         .y = innerCellY,
//                         .width = cellWidth / 2,
//                         .height = cellHeight / 2,
//                     }, .black);
//                 } else if (row >= 6) {
//                     rl.drawRectangleRec(rl.Rectangle{
//                         .x = innerCellX,
//                         .y = innerCellY,
//                         .width = cellWidth / 2,
//                         .height = cellHeight / 2,
//                     }, .white);
//                 }
//             }
//         }
//         // loop ends here
//
//         rl.drawRectangleRec(SelectorRec, .pink);
//         rl.endDrawing();
//     }
// }
//
// const rl = @import("raylib");
//
// pub fn main() anyerror!void {
//     const screenWidth = 800;
//     const screenHeight = 400;
//
//     rl.initWindow(screenWidth, screenHeight, "My Sweet Bullshit");
//     defer rl.closeWindow();
//
//     rl.setTargetFPS(60);
//
//     var recPositoin = rl.Vector2.init(screenWidth / 2, screenHeight / 2);
//
//     while (!rl.windowShouldClose()) {
//         rl.beginDrawing();
//         defer rl.endDrawing();
//
//         rl.clearBackground(.ray_white);
//
//         if (rl.isKeyPressed(.j) or rl.isKeyDown(.j)) {
//             recPositoin.x -= 10.0;
//         }
//         if (rl.isKeyPressed(.k) or rl.isKeyDown(.k)) {
//             recPositoin.y -= 10.0;
//         }
//         if (rl.isKeyPressed(.l) or rl.isKeyDown(.l)) {
//             recPositoin.y += 10.0;
//         }
//         if (rl.isKeyPressed(.semicolon) or rl.isKeyDown(.semicolon)) {
//             recPositoin.x += 10.0;
//         }
//
//         const myRec = rl.Rectangle{
//             .x = recPositoin.x,
//             .y = recPositoin.y,
//             .height = 50,
//             .width = 50,
//         };
//         rl.drawRectangleRec(myRec, .sky_blue);
//         rl.drawRectangleLinesEx(myRec, 3.0, .black);
//     }
// }
//
// const rl = @import("raylib");
//
// pub fn main() anyerror!void {
//     const screenWidth = 800;
//     const screenHeight = 450;
//
//     rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
//     defer rl.closeWindow(); // Close window and OpenGL context
//
//     rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
//
//     while (!rl.windowShouldClose()) { // Detect window close button or ESC key
//
//         rl.beginDrawing();
//         defer rl.endDrawing();
//
//         rl.clearBackground(.white);
//
//         rl.drawRectangle(190, 200, 10.0, 200, .sky_blue);
//         rl.drawText("Kida Fer ?? ! less goooooooo", 190, 200, 30, .ray_white);
//     }
// }
