# ALU

The ALU comes from Nand2Tetris, with the only change being:

 * the ZX/ZY ("zero x"/"zero y") flags are replaced with EX/EY ("enable x"/"enable y")
   which do the same thing but inverted, so that it can be implemented with an AND gate
   instead of a mux

## Operations

EX/EY enable the X/Y input respectively, instead of leaving them as 0.

NX/NY are bitwise negation of the X/Y input respectively, applied after EX/EY (so
just "NX" without "EX" gives 0xffff for the X input).

NO is bitwise negation of the output.

The "F" bit selects addition instead of AND.

Here is a table of all unique operations:

Note: ~X == -X-1

| EX | NX | EY | NY | F | NO | Result |
| :- | :- | :- | :- | :-| :- | :----- |
|  0 |  1 |  0 |  1 | 1 |  0 | -2
|  0 |  0 |  0 |  0 | 0 |  1 | -1
|  0 |  0 |  0 |  0 | 0 |  0 | 0
|  0 |  1 |  0 |  1 | 1 |  1 | 1
|  1 |  0 |  0 |  1 | 1 |  0 | X-1
|  1 |  0 |  0 |  0 | 1 |  0 | X
|  1 |  1 |  0 |  1 | 1 |  1 | X+1
|  1 |  1 |  0 |  1 | 1 |  0 | -X-2
|  1 |  0 |  0 |  1 | 1 |  1 | -X
|  0 |  1 |  1 |  0 | 1 |  0 | Y-1
|  0 |  0 |  1 |  0 | 1 |  0 | Y
|  0 |  1 |  1 |  1 | 1 |  1 | Y+1
|  0 |  1 |  1 |  1 | 1 |  0 | -Y-2
|  0 |  1 |  1 |  0 | 1 |  1 | -Y
|  1 |  0 |  1 |  0 | 1 |  0 | X+Y
|  1 |  1 |  1 |  1 | 1 |  1 | X+Y+1
|  1 |  0 |  1 |  1 | 1 |  0 | X-Y-1
|  1 |  1 |  1 |  0 | 1 |  1 | X-Y
|  1 |  1 |  1 |  0 | 1 |  0 | Y-X-1
|  1 |  0 |  1 |  1 | 1 |  1 | Y-X
|  1 |  1 |  1 |  1 | 1 |  0 | -X-Y-2
|  1 |  0 |  1 |  0 | 1 |  1 | -X-Y-1
|  1 |  0 |  0 |  0 | 1 |  1 | ~X == -X-1
|  0 |  0 |  1 |  0 | 1 |  1 | ~Y == -Y-1
|  1 |  0 |  1 |  0 | 0 |  0 | X&Y
|  1 |  1 |  1 |  1 | 0 |  1 | X|Y
|  1 |  0 |  1 |  1 | 0 |  0 | X&~Y
|  1 |  1 |  1 |  0 | 0 |  1 | X|~Y
|  1 |  0 |  1 |  1 | 0 |  1 | ~X|Y
|  1 |  1 |  1 |  0 | 0 |  0 | ~X&Y
|  1 |  1 |  1 |  1 | 0 |  0 | ~X&~Y
|  1 |  0 |  1 |  0 | 0 |  1 | ~X|~Y

There are exactly 32 unique operations, which means the 6 control bits could
plausibly be encoded into 5 with no loss of function.

Here is an exhaustive table of all possible inputs:

| EX | NX | EY | NY | F | NO | Result |
| :- | :- | :- | :- | :-| :- | :----- |
|  0 |  0 |  0 |  0 | 0 |  0 | 0
|  0 |  0 |  0 |  0 | 0 |  1 | -1
|  0 |  0 |  0 |  0 | 1 |  0 | 0
|  0 |  0 |  0 |  0 | 1 |  1 | -1
|  0 |  0 |  0 |  1 | 0 |  0 | 0
|  0 |  0 |  0 |  1 | 0 |  1 | -1
|  0 |  0 |  0 |  1 | 1 |  0 | -1
|  0 |  0 |  0 |  1 | 1 |  1 | 0
|  0 |  0 |  1 |  0 | 0 |  0 | 0
|  0 |  0 |  1 |  0 | 0 |  1 | -1
|  0 |  0 |  1 |  0 | 1 |  0 | Y
|  0 |  0 |  1 |  0 | 1 |  1 | ~Y
|  0 |  0 |  1 |  1 | 0 |  0 | 0
|  0 |  0 |  1 |  1 | 0 |  1 | -1
|  0 |  0 |  1 |  1 | 1 |  0 | ~Y
|  0 |  0 |  1 |  1 | 1 |  1 | Y
| **EX** | **NX** | **EY** | **NY** | **F** | **NO** | **Result** |
|  0 |  1 |  0 |  0 | 0 |  0 | 0
|  0 |  1 |  0 |  0 | 0 |  1 | -1
|  0 |  1 |  0 |  0 | 1 |  0 | -1
|  0 |  1 |  0 |  0 | 1 |  1 | 0
|  0 |  1 |  0 |  1 | 0 |  0 | -1
|  0 |  1 |  0 |  1 | 0 |  1 | 0
|  0 |  1 |  0 |  1 | 1 |  0 | -2
|  0 |  1 |  0 |  1 | 1 |  1 | 1
|  0 |  1 |  1 |  0 | 0 |  0 | Y
|  0 |  1 |  1 |  0 | 0 |  1 | ~Y
|  0 |  1 |  1 |  0 | 1 |  0 | Y-1
|  0 |  1 |  1 |  0 | 1 |  1 | -Y
|  0 |  1 |  1 |  1 | 0 |  0 | ~Y
|  0 |  1 |  1 |  1 | 0 |  1 | Y
|  0 |  1 |  1 |  1 | 1 |  0 | -Y-2
|  0 |  1 |  1 |  1 | 1 |  1 | Y+1
| **EX** | **NX** | **EY** | **NY** | **F** | **NO** | **Result** |
|  1 |  0 |  0 |  0 | 0 |  0 | 0
|  1 |  0 |  0 |  0 | 0 |  1 | -1
|  1 |  0 |  0 |  0 | 1 |  0 | X
|  1 |  0 |  0 |  0 | 1 |  1 | ~X
|  1 |  0 |  0 |  1 | 0 |  0 | X
|  1 |  0 |  0 |  1 | 0 |  1 | ~X
|  1 |  0 |  0 |  1 | 1 |  0 | X-1
|  1 |  0 |  0 |  1 | 1 |  1 | -X
|  1 |  0 |  1 |  0 | 0 |  0 | X&Y
|  1 |  0 |  1 |  0 | 0 |  1 | ~X|~Y
|  1 |  0 |  1 |  0 | 1 |  0 | X+Y
|  1 |  0 |  1 |  0 | 1 |  1 | -X-Y-1
|  1 |  0 |  1 |  1 | 0 |  0 | X&~Y
|  1 |  0 |  1 |  1 | 0 |  1 | ~X|Y
|  1 |  0 |  1 |  1 | 1 |  0 | X-Y-1
|  1 |  0 |  1 |  1 | 1 |  1 | Y-X
| **EX** | **NX** | **EY** | **NY** | **F** | **NO** | **Result** |
|  1 |  1 |  0 |  0 | 0 |  0 | 0
|  1 |  1 |  0 |  0 | 0 |  1 | -1
|  1 |  1 |  0 |  0 | 1 |  0 | ~X
|  1 |  1 |  0 |  0 | 1 |  1 | X
|  1 |  1 |  0 |  1 | 0 |  0 | ~X
|  1 |  1 |  0 |  1 | 0 |  1 | X
|  1 |  1 |  0 |  1 | 1 |  0 | -X-2
|  1 |  1 |  0 |  1 | 1 |  1 | X+1
|  1 |  1 |  1 |  0 | 0 |  0 | ~X&Y
|  1 |  1 |  1 |  0 | 0 |  1 | X|~Y
|  1 |  1 |  1 |  0 | 1 |  0 | Y-X-1
|  1 |  1 |  1 |  0 | 1 |  1 | X-Y
|  1 |  1 |  1 |  1 | 0 |  0 | ~X&~Y
|  1 |  1 |  1 |  1 | 0 |  1 | X|Y
|  1 |  1 |  1 |  1 | 1 |  0 | -X-Y-2
|  1 |  1 |  1 |  1 | 1 |  1 | X+Y+1
| **EX** | **NX** | **EY** | **NY** | **F** | **NO** | **Result** |
