import std.stdio;
import std.exception;
import std.conv;

enum CellValue : uint {
    NONE,
    X,
    O
}

struct GameBoard(uint dim) {
    CellValue[dim][dim] board_matrix;
    uint num_of_filled_cells;

    void setCell(uint x, uint y, CellValue value) {
        if (board_matrix[x][y] != CellValue.NONE) {
            throw new Exception("Cell already set");
        }

        board_matrix[x][y] = value;
        num_of_filled_cells++;
    }

    void printRow(uint i) {
        foreach (j; 0 .. dim) {
            auto val_to_write = " ";
            if (board_matrix[i][j] != CellValue.NONE) {
                val_to_write = to!string(board_matrix[i][j]);
            }

            write(" ", val_to_write, " ");
            if (j < dim-1) {
               write("|");
            }
        }
    }

    void printBoard() {
        foreach (i; 0 .. dim) {
            printRow(i);

            // no "--- ... ---" after last row
            if (i < dim-1) {
                writeln();
                foreach(k; 0 .. (4*dim)-1) {
                    write("-");
                }
                writeln();
            }
        }

        writeln();
    }

    bool isFull() {
        return num_of_filled_cells == dim*dim;
    }

    bool isOnSecDiagonal(uint x, uint y) {
        return (x + y) == dim-1;
    }

    alias isRowWin = isWin!"[i][j]";
    alias isColumnWin = isWin!"[j][i]";
    alias isMainDiagonalWin = isWinDiag!"[j][j]";
    alias isSecDiagonalWin = isWinDiag!"[j][dim-1-j]";   

    bool isWin(string compare)(uint i, CellValue value) {
        foreach (j; 0..dim) {
            mixin("if (board_matrix" ~ compare ~ " != value) { return false; }");   
        }

        return true;
    }

    bool isWinDiag(string compare)(CellValue value) {
        return isWin!compare(0, value);
    }
}

struct Game(Board, alias player1, alias player2) {
    alias Player = uint[2] function(); 
    static assert(is(typeof(&player1) == Player));
    static assert(is(typeof(&player2) == Player));

    Board board;

    bool playTurnAndIsWin(CellValue value, Player player) {
        auto cell_to_set = player();
        board.setCell(cell_to_set[0], cell_to_set[1], value);

        board.printBoard();

        if (checkWin(cell_to_set[0], cell_to_set[1], value)) {
            writeln(value, " Wins !");
            return true;
        }

        return false;
    }

    void run() {
        while (board.isFull() == false) {
            foreach (symbol, player; [CellValue.X: &player1, CellValue.O: &player2])
            if (playTurnAndIsWin(symbol, player)) {
                return;
            }            
        }
    }

    bool checkWin(uint x, uint y, CellValue value) {
        if (board.isRowWin(x, value)) return true;
        if (board.isColumnWin(x, value)) return true;
        
        if (x == y) {
            if (board.isMainDiagonalWin(value)) return true;
        }

        if (board.isOnSecDiagonal(x, y)) {
            if (board.isSecDiagonalWin(value)) return true;
        }

        return false;
    }
}

alias RegGameBoard = GameBoard!3;

// ############## Players Method ##############

uint[2] stdinPlay() {
    write("Enter Row: ");
    auto x = to!uint(readln()[0..$-1]);

    write("Enter Column: ");
    auto y = to!uint(readln()[0..$-1]);

    return [x, y];
}

uint[2] stdinPlay() {
    write("Enter Row: ");
    auto x = to!uint(readln()[0..$-1]);

    write("Enter Column: ");
    auto y = to!uint(readln()[0..$-1]);

    return [x, y];
}

void main() {
    Game!(RegGameBoard, stdinPlay, stdinPlay) game;
    game.run();
}