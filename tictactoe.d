import std.stdio;
import std.exception;
import std.conv;

enum CellValue : uint {
    NONE,
    X,
    O
}

enum CellGroup : uint {
    ROW,
    COLUMN,
    DIAGONAL
}

struct GameBoard(uint dim) {
    CellValue[dim][dim] board_matrix;

    void setCell(uint x, uint y, CellValue value) {
        if (board_matrix[x][y] != CellValue.NONE) {
            throw new Exception("Cell already set");
        }

        board_matrix[x][y] = value;
    }

    void printBoard() {
        foreach (i; 0 .. dim) {
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

    bool isWin(string compare)(uint i, CellValue value) {
        foreach (j; 0..dim) {
            mixin("if (board_matrix" ~ compare ~ " != value) { return false; }");   
        }

        return true;
    }

    bool isWinDiag(string compare)(CellValue value) {
        return isWin!compare(0, value);
    }

    alias isRowWin = isWin!"[i][j]";
    alias isColumnWin = isWin!"[j][i]";
    alias isMainDiagonalWin = isWinDiag!"[j][j]";
    alias isSecDiagonalWin = isWinDiag!"[j][dim-1-j]";   
}

alias RegGameBoard = GameBoard!3;

void main() {
    RegGameBoard board;
    board.setCell(2, 0, CellValue.O);
    board.setCell(1, 1, CellValue.O);
    board.setCell(0, 2, CellValue.O);
    board.printBoard();
    writeln(board.isSecDiagonalWin(CellValue.O));
}