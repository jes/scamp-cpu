EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 3
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 9600 2200 0    50   3State ~ 0
D1
Text GLabel 9600 2300 0    50   3State ~ 0
D2
Text GLabel 9600 2400 0    50   3State ~ 0
D3
Text GLabel 9600 2500 0    50   3State ~ 0
D4
Text GLabel 9600 2600 0    50   3State ~ 0
D5
Text GLabel 9600 2700 0    50   3State ~ 0
D6
Text GLabel 9600 2800 0    50   3State ~ 0
D7
Text GLabel 9600 2900 0    50   3State ~ 0
D8
Text GLabel 9600 3000 0    50   3State ~ 0
D9
Text GLabel 9600 3100 0    50   3State ~ 0
D10
Text GLabel 9600 3200 0    50   3State ~ 0
D11
Text GLabel 9600 3300 0    50   3State ~ 0
D12
Text GLabel 9600 3400 0    50   3State ~ 0
D13
Text GLabel 9600 3500 0    50   3State ~ 0
D14
Text GLabel 9600 3600 0    50   3State ~ 0
D15
Text GLabel 10100 5000 2    50   Output ~ 0
GND
Text GLabel 9600 5000 0    50   Output ~ 0
VCC
Text GLabel 9600 2100 0    50   3State ~ 0
D0
NoConn ~ 9600 4700
NoConn ~ 10100 4900
NoConn ~ 10100 4800
NoConn ~ 10100 4700
NoConn ~ 10100 4600
NoConn ~ 10100 4500
NoConn ~ 10100 4400
NoConn ~ 10100 2800
NoConn ~ 10100 3000
NoConn ~ 10100 3100
NoConn ~ 10100 3200
NoConn ~ 10100 3300
NoConn ~ 10100 3400
NoConn ~ 10100 3500
NoConn ~ 10100 3600
NoConn ~ 9600 4400
NoConn ~ 9600 4300
NoConn ~ 9600 4200
Text Label 10100 2800 0    50   ~ 0
A7
Text Label 10100 3000 0    50   ~ 0
A9
Text Label 10100 3100 0    50   ~ 0
A10
Text Label 10100 3200 0    50   ~ 0
A11
Text Label 10100 3300 0    50   ~ 0
A12
Text Label 10100 3400 0    50   ~ 0
A13
Text Label 10100 3500 0    50   ~ 0
A14
Text Label 10100 3600 0    50   ~ 0
A15
Text Label 9600 4200 2    50   ~ 0
~AI~
Text Label 9600 4300 2    50   ~ 0
MO
Text Label 9600 4400 2    50   ~ 0
MI
$Sheet
S 4800 1450 2300 1350
U 60BC0128
F0 "cfcard" 50
F1 "cfcard.sch" 50
F2 "~CS1~" I L 4800 1800 50 
F3 "~CS0~" I L 4800 1700 50 
$EndSheet
Text GLabel 9600 4800 0    50   Input ~ 0
~RESET~
$Comp
L Connector_Generic:Conn_02x30_Counter_Clockwise J1
U 1 1 6023EC4D
P 9800 3500
F 0 "J1" H 9850 5117 50  0000 C CNN
F 1 "Conn_02x30_Counter_Clockwise" H 9850 5026 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x30_P2.54mm_Horizontal" H 9800 3500 50  0001 C CNN
F 3 "~" H 9800 3500 50  0001 C CNN
	1    9800 3500
	1    0    0    -1  
$EndComp
$Sheet
S 4800 3050 2300 1350
U 60BC913C
F0 "cfcard2" 50
F1 "cfcard.sch" 50
F2 "~CS1~" I L 4800 3400 50 
F3 "~CS0~" I L 4800 3300 50 
$EndSheet
Text GLabel 10100 2100 2    50   Input ~ 0
A0
Text GLabel 10100 2200 2    50   Input ~ 0
A1
Text GLabel 10100 2300 2    50   Input ~ 0
A2
Text GLabel 10100 2400 2    50   Input ~ 0
A3
Text GLabel 10100 2500 2    50   Input ~ 0
A4
Text GLabel 10100 2600 2    50   Input ~ 0
A5
Text GLabel 10100 2700 2    50   Input ~ 0
A6
Text GLabel 10100 2900 2    50   Input ~ 0
A8
Text Label 10100 3700 2    50   ~ 0
EX
Text Label 10100 3800 2    50   ~ 0
NX
Text Label 10100 3900 2    50   ~ 0
EY
Text Label 10100 4000 2    50   ~ 0
NY
Text Label 10100 4100 2    50   ~ 0
F
Text Label 10100 4200 2    50   ~ 0
NO
NoConn ~ 10100 3700
NoConn ~ 10100 3800
NoConn ~ 10100 3900
NoConn ~ 10100 4000
NoConn ~ 10100 4100
NoConn ~ 10100 4200
Text GLabel 9600 4500 0    50   Input ~ 0
DO
NoConn ~ 9600 3700
NoConn ~ 9600 3800
NoConn ~ 9600 3900
NoConn ~ 9600 4000
NoConn ~ 9600 4100
Text Label 9600 3700 0    50   ~ 0
Z
Text Label 9600 3800 0    50   ~ 0
LT
Text Label 9600 3900 0    50   ~ 0
~EO~
Text Label 9600 4000 0    50   ~ 0
~XI~
Text Label 9600 4100 0    50   ~ 0
~YI~
Text Label 9600 4900 0    50   ~ 0
CLK
NoConn ~ 9600 4900
$Comp
L 74xx:7400 U1
U 2 1 60BD3C08
P 1650 3950
F 0 "U1" H 1650 4275 50  0000 C CNN
F 1 "7400" H 1650 4184 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1650 3950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 1650 3950 50  0001 C CNN
	2    1650 3950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U1
U 3 1 60BD47B0
P 1650 4500
F 0 "U1" H 1650 4825 50  0000 C CNN
F 1 "7400" H 1650 4734 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1650 4500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 1650 4500 50  0001 C CNN
	3    1650 4500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U1
U 1 1 60BD5DD8
P 1650 3400
F 0 "U1" H 1650 3725 50  0000 C CNN
F 1 "7400" H 1650 3634 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1650 3400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 1650 3400 50  0001 C CNN
	1    1650 3400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U1
U 4 1 60BD67C6
P 1650 5050
F 0 "U1" H 1650 5375 50  0000 C CNN
F 1 "7400" H 1650 5284 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1650 5050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 1650 5050 50  0001 C CNN
	4    1650 5050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U1
U 5 1 60BD7DE2
P 2550 6800
F 0 "U1" H 2780 6846 50  0000 L CNN
F 1 "7400" H 2780 6755 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2550 6800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 2550 6800 50  0001 C CNN
	5    2550 6800
	1    0    0    -1  
$EndComp
$Comp
L Device:C C1
U 1 1 60BD9CE9
P 2000 6850
F 0 "C1" H 2115 6896 50  0000 L CNN
F 1 "C" H 2115 6805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 2038 6700 50  0001 C CNN
F 3 "~" H 2000 6850 50  0001 C CNN
	1    2000 6850
	1    0    0    -1  
$EndComp
Text Label 9600 4600 0    50   ~ 0
DI
NoConn ~ 9600 4600
Text GLabel 1350 3300 0    50   Input ~ 0
DO
Text GLabel 1350 3500 0    50   Input ~ 0
DO
Text GLabel 1950 3400 2    50   Input ~ 0
~IORDTTL~
Text GLabel 1350 3850 0    50   Input ~ 0
WR
Text GLabel 1350 4050 0    50   Input ~ 0
WR
Text GLabel 1950 3950 2    50   Input ~ 0
~IOWRTTL~
Text GLabel 1350 4400 0    50   Input ~ 0
A3
Text GLabel 1350 4600 0    50   Input ~ 0
A8
Text GLabel 1950 4500 2    50   Input ~ 0
~CS0aTTL~
Text GLabel 1350 4950 0    50   Input ~ 0
A4
Text GLabel 1350 5150 0    50   Input ~ 0
A8
Text GLabel 1950 5050 2    50   Input ~ 0
~CS1aTTL~
Text GLabel 4800 1700 0    50   Input ~ 0
~CS0a~
Text GLabel 4800 1800 0    50   Input ~ 0
~CS1a~
Text GLabel 4800 3300 0    50   Input ~ 0
~CS0b~
Text GLabel 4800 3400 0    50   Input ~ 0
~CS1b~
$Comp
L 74xx:7400 U2
U 1 1 60BE6467
P 3050 3400
F 0 "U2" H 3050 3725 50  0000 C CNN
F 1 "7400" H 3050 3634 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3050 3400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 3050 3400 50  0001 C CNN
	1    3050 3400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U2
U 2 1 60BE7915
P 3050 3950
F 0 "U2" H 3050 4275 50  0000 C CNN
F 1 "7400" H 3050 4184 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3050 3950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 3050 3950 50  0001 C CNN
	2    3050 3950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U2
U 3 1 60BE9346
P 3050 4500
F 0 "U2" H 3050 4825 50  0000 C CNN
F 1 "7400" H 3050 4734 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3050 4500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 3050 4500 50  0001 C CNN
	3    3050 4500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U2
U 4 1 60BEA7CE
P 3050 5050
F 0 "U2" H 3050 5375 50  0000 C CNN
F 1 "7400" H 3050 5284 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3050 5050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 3050 5050 50  0001 C CNN
	4    3050 5050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:7400 U2
U 5 1 60BEBCDF
P 3900 6800
F 0 "U2" H 4130 6846 50  0000 L CNN
F 1 "7400" H 4130 6755 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3900 6800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn7400" H 3900 6800 50  0001 C CNN
	5    3900 6800
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 60BEE8D3
P 3450 6850
F 0 "C2" H 3565 6896 50  0000 L CNN
F 1 "C" H 3565 6805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 3488 6700 50  0001 C CNN
F 3 "~" H 3450 6850 50  0001 C CNN
	1    3450 6850
	1    0    0    -1  
$EndComp
Text GLabel 2750 3300 0    50   Input ~ 0
A5
Text GLabel 2750 3850 0    50   Input ~ 0
A6
Text GLabel 2750 3500 0    50   Input ~ 0
A8
Text GLabel 2750 4050 0    50   Input ~ 0
A8
Text GLabel 3350 3400 2    50   Input ~ 0
~CS0bTTL~
Text GLabel 3350 3950 2    50   Input ~ 0
~CS1bTTL~
Wire Wire Line
	2000 6700 2000 6300
Wire Wire Line
	2000 6300 2550 6300
Wire Wire Line
	2550 6300 3150 6300
Connection ~ 2550 6300
Wire Wire Line
	3450 6700 3450 6300
Connection ~ 3450 6300
Wire Wire Line
	3450 6300 3900 6300
Wire Wire Line
	2000 7000 2000 7300
Wire Wire Line
	2000 7300 2550 7300
Connection ~ 2550 7300
Wire Wire Line
	2550 7300 3150 7300
Wire Wire Line
	3450 7000 3450 7300
Connection ~ 3450 7300
Wire Wire Line
	3450 7300 3900 7300
Text GLabel 3900 6300 2    50   Input ~ 0
VCC
Text GLabel 3900 7300 2    50   Input ~ 0
GND
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 60BFEF9F
P 2000 6300
F 0 "#FLG0101" H 2000 6375 50  0001 C CNN
F 1 "PWR_FLAG" H 2000 6473 50  0000 C CNN
F 2 "" H 2000 6300 50  0001 C CNN
F 3 "~" H 2000 6300 50  0001 C CNN
	1    2000 6300
	1    0    0    -1  
$EndComp
Connection ~ 2000 6300
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 60BFFC74
P 2000 7300
F 0 "#FLG0102" H 2000 7375 50  0001 C CNN
F 1 "PWR_FLAG" H 2000 7473 50  0000 C CNN
F 2 "" H 2000 7300 50  0001 C CNN
F 3 "~" H 2000 7300 50  0001 C CNN
	1    2000 7300
	-1   0    0    1   
$EndComp
Connection ~ 2000 7300
NoConn ~ 2750 4400
NoConn ~ 2750 4600
NoConn ~ 2750 4950
NoConn ~ 2750 5150
NoConn ~ 3350 5050
NoConn ~ 3350 4500
$Comp
L Connector_Generic:Conn_02x08_Counter_Clockwise U3
U 1 1 60C09966
P 5950 5500
F 0 "U3" H 6000 6017 50  0000 C CNN
F 1 "Conn_02x08_Counter_Clockwise" H 6000 5926 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket" H 5950 5500 50  0001 C CNN
F 3 "~" H 5950 5500 50  0001 C CNN
	1    5950 5500
	1    0    0    -1  
$EndComp
Text GLabel 5750 5200 0    50   Input ~ 0
VCC
Text GLabel 6250 5200 2    50   Input ~ 0
VCC
Text GLabel 5750 5900 0    50   Input ~ 0
GND
Text GLabel 5750 5400 0    50   Input ~ 0
~IORDTTL~
Text GLabel 5750 5300 0    50   Input ~ 0
~IORD~
Text GLabel 5750 5500 0    50   Input ~ 0
~IOWR~
Text GLabel 5750 5600 0    50   Input ~ 0
~IOWRTTL~
Text GLabel 5750 5700 0    50   Input ~ 0
~CS0a~
Text GLabel 5750 5800 0    50   Input ~ 0
~CS0aTTL~
Text GLabel 6250 5800 2    50   Input ~ 0
~CS1a~
Text GLabel 6250 5900 2    50   Input ~ 0
~CS1aTTL~
Text GLabel 6250 5700 2    50   Input ~ 0
~CS0bTTL~
Text GLabel 6250 5600 2    50   Input ~ 0
~CS0b~
Text GLabel 6250 5400 2    50   Input ~ 0
~CS1bTTL~
Text GLabel 6250 5300 2    50   Input ~ 0
~CS1b~
Text GLabel 6250 5500 2    50   Input ~ 0
VCC
$Comp
L Device:C C3
U 1 1 60C1E1E1
P 3150 6850
F 0 "C3" H 3265 6896 50  0000 L CNN
F 1 "C" H 3265 6805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 3188 6700 50  0001 C CNN
F 3 "~" H 3150 6850 50  0001 C CNN
	1    3150 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3150 6700 3150 6300
Connection ~ 3150 6300
Wire Wire Line
	3150 6300 3450 6300
Wire Wire Line
	3150 7000 3150 7300
Connection ~ 3150 7300
Wire Wire Line
	3150 7300 3450 7300
Text GLabel 10100 4300 2    50   Input ~ 0
WR
$Comp
L Connector_Generic:Conn_01x03 J6
U 1 1 60C409E1
P 2750 1500
F 0 "J6" H 2830 1542 50  0000 L CNN
F 1 "Conn_01x03" H 2830 1451 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 2750 1500 50  0001 C CNN
F 3 "~" H 2750 1500 50  0001 C CNN
	1    2750 1500
	1    0    0    -1  
$EndComp
Text GLabel 2550 1400 0    50   Input ~ 0
GND
$Comp
L Device:R R1
U 1 1 60C52E56
P 2400 1500
F 0 "R1" V 2193 1500 50  0000 C CNN
F 1 "R" V 2284 1500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 2330 1500 50  0001 C CNN
F 3 "~" H 2400 1500 50  0001 C CNN
	1    2400 1500
	0    1    1    0   
$EndComp
$Comp
L Device:R R2
U 1 1 60C5383C
P 2400 1600
F 0 "R2" V 2193 1600 50  0000 C CNN
F 1 "R" V 2284 1600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 2330 1600 50  0001 C CNN
F 3 "~" H 2400 1600 50  0001 C CNN
	1    2400 1600
	0    1    1    0   
$EndComp
$Comp
L Connector_Generic:Conn_01x02 J7
U 1 1 60C55150
P 2050 1600
F 0 "J7" H 1968 1275 50  0000 C CNN
F 1 "Conn_01x02" H 1968 1366 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 2050 1600 50  0001 C CNN
F 3 "~" H 2050 1600 50  0001 C CNN
	1    2050 1600
	-1   0    0    1   
$EndComp
$EndSCHEMATC
