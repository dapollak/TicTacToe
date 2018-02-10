import std.stdio;
import std.exception;
import std.conv;
import std.random;

enum CellValue : uint {
    NONE,
    X,
    O
}

struct GameBoardState(uint dim) {
    const CellValue[dim][dim] matrix;

    CellValue getCell(uint x, uint y) {
        return matrix[x][y];
    }
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

    GameBoardState!dim getState() {
        return GameBoardState!dim(board_matrix);
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

struct Player(uint board_dim, alias play_func) {
    uint[2] play(GameBoardState!board_dim state) {
        return play_func!board_dim(state);
    }
}

struct Game(uint board_dim, alias player1, alias player2) {

    GameBoard!board_dim board;

    void run() {
        while (board.isFull() == false) {
            foreach (symbol; [CellValue.X, CellValue.O]) {
                uint[2] cell_to_set;

                if (symbol == CellValue.X) {
                    cell_to_set = player1.play(board.getState);
                } else {
                    cell_to_set = player2.play(board.getState);
                }

                // play
                //auto cell_to_set = player.play(board.getState);
                board.setCell(cell_to_set[0], cell_to_set[1], symbol);
                board.printBoard();

                // check for win
                if (checkWin(cell_to_set[0], cell_to_set[1], symbol)) {
                    writeln(symbol, " Wins !");
                    return;
                }

                if (board.isFull()) {
                    break;
                }
            }            
        }

        writeln("It's a tie !");
    }

    bool checkWin(uint x, uint y, CellValue value) {
        if (board.isRowWin(x, value)) return true;
        if (board.isColumnWin(y, value)) return true;
        
        if (x == y) {
            if (board.isMainDiagonalWin(value)) return true;
        }

        if (board.isOnSecDiagonal(x, y)) {
            if (board.isSecDiagonalWin(value)) return true;
        }

        return false;
    }
}

// ############## Players Method ##############

uint[2] stdinPlay(uint dim)(GameBoardState!dim state) {
    write("Enter Row: ");
    auto x = to!uint(readln()[0..$-1]);

    write("Enter Column: ");
    auto y = to!uint(readln()[0..$-1]);

    return [x, y];
}

uint[2] randomPlay(uint dim)(GameBoardState!dim state) {
    uint[2] move = [uniform(0, dim), uniform(0, dim)];
    while (state.getCell(move[0], move[1]) != CellValue.NONE) {
        move = [uniform(0, dim), uniform(0, dim)];
    }

    writeln(move);
    return move;
}

void main() {
    Player!(3, randomPlay) p1;
    Player!(3, randomPlay) p2;
    Game!(3, p1, p2) game;
    game.run();
}