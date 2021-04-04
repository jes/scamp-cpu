EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 5
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 10050 2050 0    50   3State ~ 0
D1
Text GLabel 10050 2150 0    50   3State ~ 0
D2
Text GLabel 10050 2250 0    50   3State ~ 0
D3
Text GLabel 10050 2350 0    50   3State ~ 0
D4
Text GLabel 10050 2450 0    50   3State ~ 0
D5
Text GLabel 10050 2550 0    50   3State ~ 0
D6
Text GLabel 10050 2650 0    50   3State ~ 0
D7
Text GLabel 10550 4850 2    50   Output ~ 0
GND
Text GLabel 10050 4850 0    50   Output ~ 0
VCC
Text GLabel 10050 4750 0    50   Output ~ 0
CLK
Text GLabel 10050 1950 0    50   3State ~ 0
D0
NoConn ~ 10550 4750
NoConn ~ 10550 4650
NoConn ~ 10550 4550
NoConn ~ 10550 4450
NoConn ~ 10550 4350
NoConn ~ 10550 4250
NoConn ~ 10550 4150
NoConn ~ 10050 4650
NoConn ~ 10050 4250
NoConn ~ 10050 4150
NoConn ~ 10050 4050
$Comp
L Connector_Generic:Conn_02x30_Counter_Clockwise J1
U 1 1 6023EC4D
P 10250 3350
F 0 "J1" H 10300 4967 50  0000 C CNN
F 1 "Conn_02x30_Counter_Clockwise" H 10300 4876 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x30_P2.54mm_Horizontal" H 10250 3350 50  0001 C CNN
F 3 "~" H 10250 3350 50  0001 C CNN
	1    10250 3350
	1    0    0    -1  
$EndComp
NoConn ~ 10550 3450
NoConn ~ 10550 3350
NoConn ~ 10550 3250
NoConn ~ 10550 3150
NoConn ~ 10550 3050
NoConn ~ 10550 2950
Text Label 10550 3450 0    50   ~ 0
A15
Text Label 10550 3350 0    50   ~ 0
A14
Text Label 10550 3250 0    50   ~ 0
A13
Text Label 10550 3150 0    50   ~ 0
A12
Text Label 10550 3050 0    50   ~ 0
A11
Text Label 10550 2950 0    50   ~ 0
A10
Text Label 10550 2850 0    50   ~ 0
A9
NoConn ~ 10550 2850
NoConn ~ 10550 2750
Text Label 10550 2750 0    50   ~ 0
A8
Text GLabel 10550 1950 2    50   Input ~ 0
A0
Text GLabel 10550 2050 2    50   Input ~ 0
A1
Text GLabel 10550 2150 2    50   Input ~ 0
A2
Text GLabel 10550 2250 2    50   Input ~ 0
A3
Text GLabel 10550 2350 2    50   Input ~ 0
A4
Text GLabel 10550 2450 2    50   Input ~ 0
A5
Text GLabel 10550 2550 2    50   Input ~ 0
A6
Text GLabel 10550 2650 2    50   Input ~ 0
A7
NoConn ~ 10050 2750
NoConn ~ 10050 2850
NoConn ~ 10050 2950
NoConn ~ 10050 3050
NoConn ~ 10050 3150
NoConn ~ 10050 3250
NoConn ~ 10050 3350
NoConn ~ 10050 3450
NoConn ~ 10050 3550
NoConn ~ 10050 3650
NoConn ~ 10050 3750
NoConn ~ 10050 3850
NoConn ~ 10050 3950
Text GLabel 10050 4350 0    50   Input ~ 0
DO
Text GLabel 10050 4450 0    50   Input ~ 0
DI
Text GLabel 10050 4550 0    50   Input ~ 0
~RESET
NoConn ~ 10550 3550
NoConn ~ 10550 3650
NoConn ~ 10550 3750
NoConn ~ 10550 3850
NoConn ~ 10550 3950
NoConn ~ 10550 4050
$Sheet
S 3650 1000 700  450 
U 6069F7D6
F0 "uart8250a" 50
F1 "uart8250.sch" 50
F2 "CS0" I L 3650 1100 50 
F3 "CS1" I L 3650 1200 50 
F4 "~CS2" I L 3650 1300 50 
$EndSheet
$Comp
L 74xx:74LS74 U1
U 1 1 606A05BB
P 2600 4900
F 0 "U1" H 2600 5381 50  0000 C CNN
F 1 "74LS74" H 2600 5290 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2600 4900 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 2600 4900 50  0001 C CNN
	1    2600 4900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS74 U1
U 2 1 606A0CC2
P 4150 5050
F 0 "U1" H 4150 5531 50  0000 C CNN
F 1 "74LS74" H 4150 5440 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4150 5050 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 4150 5050 50  0001 C CNN
	2    4150 5050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS74 U1
U 3 1 606A1598
P 3300 7100
F 0 "U1" H 3530 7146 50  0000 L CNN
F 1 "74LS74" H 3530 7055 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3300 7100 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 3300 7100 50  0001 C CNN
	3    3300 7100
	1    0    0    -1  
$EndComp
Text GLabel 2300 4800 0    50   Input ~ 0
VCC
Text GLabel 2300 4900 0    50   Input ~ 0
DI
Text GLabel 2600 5200 0    50   Input ~ 0
inv_CLK
Text GLabel 2600 4600 0    50   Input ~ 0
VCC
NoConn ~ 4150 4750
NoConn ~ 3850 4950
NoConn ~ 3850 5050
NoConn ~ 4450 4950
NoConn ~ 4450 5150
NoConn ~ 4150 5350
$Comp
L 74xx:74LS04 U2
U 1 1 606A3470
P 7600 3400
F 0 "U2" H 7600 3717 50  0000 C CNN
F 1 "74LS04" H 7600 3626 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 3400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 3400 50  0001 C CNN
	1    7600 3400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 2 1 606A3CA3
P 7600 3850
F 0 "U2" H 7600 4167 50  0000 C CNN
F 1 "74LS04" H 7600 4076 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 3850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 3850 50  0001 C CNN
	2    7600 3850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 3 1 606A48A9
P 7600 4300
F 0 "U2" H 7600 4617 50  0000 C CNN
F 1 "74LS04" H 7600 4526 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 4300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 4300 50  0001 C CNN
	3    7600 4300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 4 1 606A6AD2
P 7600 4750
F 0 "U2" H 7600 5067 50  0000 C CNN
F 1 "74LS04" H 7600 4976 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 4750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 4750 50  0001 C CNN
	4    7600 4750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 5 1 606A90B5
P 7600 5200
F 0 "U2" H 7600 5517 50  0000 C CNN
F 1 "74LS04" H 7600 5426 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 5200 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 5200 50  0001 C CNN
	5    7600 5200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 6 1 606A9B68
P 7600 5650
F 0 "U2" H 7600 5967 50  0000 C CNN
F 1 "74LS04" H 7600 5876 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 7600 5650 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 7600 5650 50  0001 C CNN
	6    7600 5650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U2
U 7 1 606AA696
P 4050 7100
F 0 "U2" H 4280 7146 50  0000 L CNN
F 1 "74LS04" H 4280 7055 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4050 7100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 4050 7100 50  0001 C CNN
	7    4050 7100
	1    0    0    -1  
$EndComp
Text GLabel 7300 3400 0    50   Input ~ 0
CLK
Text GLabel 7300 3850 0    50   Input ~ 0
~RESET
Text GLabel 7900 3400 2    50   Input ~ 0
inv_CLK
Text GLabel 7900 3850 2    50   Input ~ 0
inv_~RESET
NoConn ~ 2900 5000
Text GLabel 2900 4800 2    50   Input ~ 0
WR
$Sheet
S 3650 1750 700  450 
U 606BA90E
F0 "uart8250b" 50
F1 "uart8250.sch" 50
F2 "CS0" I L 3650 1850 50 
F3 "CS1" I L 3650 1950 50 
F4 "~CS2" I L 3650 2050 50 
$EndSheet
$Sheet
S 3650 2500 700  450 
U 606BAC52
F0 "uart8250c" 50
F1 "uart8250.sch" 50
F2 "CS0" I L 3650 2600 50 
F3 "CS1" I L 3650 2700 50 
F4 "~CS2" I L 3650 2800 50 
$EndSheet
$Sheet
S 3650 3250 700  450 
U 606BAF9A
F0 "uart8250d" 50
F1 "uart8250.sch" 50
F2 "CS0" I L 3650 3350 50 
F3 "CS1" I L 3650 3450 50 
F4 "~CS2" I L 3650 3550 50 
$EndSheet
Text GLabel 3650 1300 0    50   Input ~ 0
GND
Text GLabel 3650 2050 0    50   Input ~ 0
GND
Text GLabel 3650 2800 0    50   Input ~ 0
GND
Text GLabel 3650 3550 0    50   Input ~ 0
GND
Text GLabel 3650 1100 0    50   Input ~ 0
A7
Text GLabel 3650 1850 0    50   Input ~ 0
A7
Text GLabel 3650 2600 0    50   Input ~ 0
A7
Text GLabel 3650 3350 0    50   Input ~ 0
A7
Text GLabel 3650 1200 0    50   Input ~ 0
A3
Text GLabel 3650 1950 0    50   Input ~ 0
A4
Text GLabel 3650 2700 0    50   Input ~ 0
A5
Text GLabel 3650 3450 0    50   Input ~ 0
A6
NoConn ~ 7300 4300
NoConn ~ 7300 4750
NoConn ~ 7300 5200
NoConn ~ 7300 5650
NoConn ~ 7900 5650
NoConn ~ 7900 5200
NoConn ~ 7900 4750
NoConn ~ 7900 4300
Wire Wire Line
	3300 7500 3300 7600
Wire Wire Line
	3300 7600 3650 7600
Wire Wire Line
	4050 6600 3400 6600
Wire Wire Line
	3300 6600 3300 6700
$Comp
L Device:C C10
U 1 1 606DF07C
P 2800 7100
F 0 "C10" H 2915 7146 50  0000 L CNN
F 1 "C" H 2915 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 2838 6950 50  0001 C CNN
F 3 "~" H 2800 7100 50  0001 C CNN
	1    2800 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C9
U 1 1 606DF562
P 2500 7100
F 0 "C9" H 2615 7146 50  0000 L CNN
F 1 "C" H 2615 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 2538 6950 50  0001 C CNN
F 3 "~" H 2500 7100 50  0001 C CNN
	1    2500 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2500 6950 2500 6600
Wire Wire Line
	2500 6600 2800 6600
Connection ~ 3300 6600
Wire Wire Line
	2800 6950 2800 6600
Connection ~ 2800 6600
Wire Wire Line
	2800 6600 3300 6600
Wire Wire Line
	2800 7250 2800 7600
Connection ~ 3300 7600
Wire Wire Line
	2500 7250 2500 7600
Wire Wire Line
	2500 7600 2800 7600
Connection ~ 2800 7600
Wire Wire Line
	2800 7600 3300 7600
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 606E4361
P 3400 6600
F 0 "#FLG0101" H 3400 6675 50  0001 C CNN
F 1 "PWR_FLAG" H 3400 6773 50  0000 C CNN
F 2 "" H 3400 6600 50  0001 C CNN
F 3 "~" H 3400 6600 50  0001 C CNN
	1    3400 6600
	1    0    0    -1  
$EndComp
Connection ~ 3400 6600
Wire Wire Line
	3400 6600 3300 6600
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 606E4711
P 3650 7600
F 0 "#FLG0102" H 3650 7675 50  0001 C CNN
F 1 "PWR_FLAG" H 3650 7773 50  0000 C CNN
F 2 "" H 3650 7600 50  0001 C CNN
F 3 "~" H 3650 7600 50  0001 C CNN
	1    3650 7600
	1    0    0    -1  
$EndComp
Connection ~ 3650 7600
Wire Wire Line
	3650 7600 4050 7600
Text GLabel 4050 6600 2    50   Input ~ 0
VCC
Text GLabel 4050 7600 2    50   Input ~ 0
GND
$Comp
L Connector:Conn_01x01_Male J10
U 1 1 60759265
P 3000 5500
F 0 "J10" H 3108 5681 50  0000 C CNN
F 1 "Conn_01x01_Male" H 3108 5590 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 3000 5500 50  0001 C CNN
F 3 "~" H 3000 5500 50  0001 C CNN
	1    3000 5500
	1    0    0    -1  
$EndComp
Text GLabel 3200 5500 2    50   Input ~ 0
WR
$EndSCHEMATC
