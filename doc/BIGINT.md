# Integer operations per second, by type

|     | int   | big32 | big32/int | big64 | big64/int |
| :-- | :---- | :---- | :-------- | :---- | :-------- |
| add | 10000 |  2900 |      1300 |  2100 |      1000 |
| mul |  1500 |    37 |        36 |    17 |        17 |
| div |   680 |    22 |        20 |    11 |        10 |
| cmp |  5700 |  2900 |      1700 |  2200 |      1300 |

 * `mod` throughput is the same as `div` in all cases
 * `cmp` means magnitude comparison (e.g. `<`, or `bigcmp()`)
 * `bigX` means both operands bigint (e.g. `bigadd()`)
 * `bigX/int` means the second operand is native int (e.g. `bigaddw()`)
