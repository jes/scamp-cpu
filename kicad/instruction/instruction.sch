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
Text GLabel 10100 3450 0    50   3State ~ 0
D1
Text GLabel 10100 3550 0    50   3State ~ 0
D2
Text GLabel 10100 3650 0    50   3State ~ 0
D3
Text GLabel 10100 3750 0    50   3State ~ 0
D4
Text GLabel 10100 3850 0    50   3State ~ 0
D5
Text GLabel 10100 3950 0    50   3State ~ 0
D6
Text GLabel 10100 4050 0    50   3State ~ 0
D7
Text GLabel 10100 4150 0    50   3State ~ 0
D8
Text GLabel 10100 4250 0    50   3State ~ 0
D9
Text GLabel 10100 4350 0    50   3State ~ 0
D10
Text GLabel 10100 4450 0    50   3State ~ 0
D11
Text GLabel 10100 4550 0    50   3State ~ 0
D12
Text GLabel 10100 4650 0    50   3State ~ 0
D13
Text GLabel 10100 4750 0    50   3State ~ 0
D14
Text GLabel 10100 4850 0    50   3State ~ 0
D15
Text GLabel 10600 6250 2    50   Output ~ 0
GND
Text GLabel 10100 6250 0    50   Output ~ 0
VCC
Text GLabel 10100 6150 0    50   Output ~ 0
CLK
Text GLabel 10100 3350 0    50   3State ~ 0
D0
Text GLabel 10100 5050 0    50   Input ~ 0
LT
Text GLabel 10100 5150 0    50   Output ~ 0
~EO~
Text GLabel 10100 5250 0    50   Output ~ 0
~XI~
Text GLabel 10100 5350 0    50   Output ~ 0
~YI~
Text GLabel 10600 4950 2    50   Output ~ 0
EX
Text GLabel 10600 5050 2    50   Output ~ 0
NX
Text GLabel 10600 5150 2    50   Output ~ 0
EY
Text GLabel 10600 5250 2    50   Output ~ 0
NY
Text GLabel 10600 5350 2    50   Output ~ 0
F
Text GLabel 10600 5450 2    50   Output ~ 0
NO
Text GLabel 10100 4950 0    50   Input ~ 0
Z
NoConn ~ 10600 3350
NoConn ~ 10600 3450
NoConn ~ 10600 3550
NoConn ~ 10600 3650
NoConn ~ 10600 3750
NoConn ~ 10600 3850
NoConn ~ 10600 3950
NoConn ~ 10600 4050
NoConn ~ 10600 4150
NoConn ~ 10600 4250
NoConn ~ 10600 4350
NoConn ~ 10600 4450
NoConn ~ 10600 4550
NoConn ~ 10600 4650
NoConn ~ 10600 4750
NoConn ~ 10600 4850
Text Label 10600 3350 0    50   ~ 0
A0
Text Label 10600 3450 0    50   ~ 0
A1
Text Label 10600 3550 0    50   ~ 0
A2
Text Label 10600 3650 0    50   ~ 0
A3
Text Label 10600 3750 0    50   ~ 0
A4
Text Label 10600 3850 0    50   ~ 0
A5
Text Label 10600 3950 0    50   ~ 0
A6
Text Label 10600 4050 0    50   ~ 0
A7
Text Label 10600 4150 0    50   ~ 0
A8
Text Label 10600 4250 0    50   ~ 0
A9
Text Label 10600 4350 0    50   ~ 0
A10
Text Label 10600 4450 0    50   ~ 0
A11
Text Label 10600 4550 0    50   ~ 0
A12
Text Label 10600 4650 0    50   ~ 0
A13
Text Label 10600 4750 0    50   ~ 0
A14
Text Label 10600 4850 0    50   ~ 0
A15
Text GLabel 10100 5450 0    50   Input ~ 0
~AI~
Text GLabel 10100 5550 0    50   Input ~ 0
MO
Text GLabel 10100 5650 0    50   Input ~ 0
MI
Text GLabel 10100 5750 0    50   Input ~ 0
DO
Text GLabel 10100 5850 0    50   Input ~ 0
DI
Text GLabel 10100 6050 0    50   Input ~ 0
~RESET~
$Comp
L Connector_Generic:Conn_02x30_Counter_Clockwise J1
U 1 1 6023EC4D
P 10300 4750
F 0 "J1" H 10350 6367 50  0000 C CNN
F 1 "Conn_02x30_Counter_Clockwise" H 10350 6276 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x30_P2.54mm_Horizontal" H 10300 4750 50  0001 C CNN
F 3 "~" H 10300 4750 50  0001 C CNN
	1    10300 4750
	1    0    0    -1  
$EndComp
Text Notes 8250 7500 2    50   ~ 0
SCAMP Instruction Card
$Comp
L scamp:28C16 U1
U 1 1 60832780
P 1350 2050
F 0 "U1" H 1350 3331 50  0000 C CNN
F 1 "28C16" H 1350 3240 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 1350 2050 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 1350 2050 50  0001 C CNN
	1    1350 2050
	1    0    0    -1  
$EndComp
$Comp
L scamp:28C16 U2
U 1 1 608342E2
P 1350 4650
F 0 "U2" H 1350 5931 50  0000 C CNN
F 1 "28C16" H 1350 5840 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 1350 4650 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 1350 4650 50  0001 C CNN
	1    1350 4650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U3
U 1 1 608352E5
P 4800 4300
F 0 "U3" H 4800 4617 50  0000 C CNN
F 1 "74LS04" H 4800 4526 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4800 4300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 4800 4300 50  0001 C CNN
	1    4800 4300
	1    0    0    -1  
$EndComp
Text GLabel 5100 4300 2    50   Input ~ 0
GT
$Comp
L 74xx:74LS04 U3
U 2 1 60837D86
P 2850 1400
F 0 "U3" H 2850 1717 50  0000 C CNN
F 1 "74LS04" H 2850 1626 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 1400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 2850 1400 50  0001 C CNN
	2    2850 1400
	1    0    0    -1  
$EndComp
Text GLabel 2550 1400 0    50   Input ~ 0
JMP
Text GLabel 3150 1400 2    50   Input ~ 0
~JMP~
$Comp
L 74xx:74LS04 U3
U 3 1 6083822C
P 2850 1900
F 0 "U3" H 2850 2217 50  0000 C CNN
F 1 "74LS04" H 2850 2126 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 1900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 2850 1900 50  0001 C CNN
	3    2850 1900
	1    0    0    -1  
$EndComp
Text GLabel 2550 1900 0    50   Input ~ 0
inv_MO
Text GLabel 3150 1900 2    50   Input ~ 0
MO
$Comp
L 74xx:74LS04 U3
U 4 1 60838F5B
P 2850 2400
F 0 "U3" H 2850 2717 50  0000 C CNN
F 1 "74LS04" H 2850 2626 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 2400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 2850 2400 50  0001 C CNN
	4    2850 2400
	1    0    0    -1  
$EndComp
Text GLabel 2550 2400 0    50   Input ~ 0
inv_DO
Text GLabel 3150 2400 2    50   Input ~ 0
DO
$Comp
L 74xx:74LS04 U3
U 5 1 60839D72
P 2850 2900
F 0 "U3" H 2850 3217 50  0000 C CNN
F 1 "74LS04" H 2850 3126 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 2900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 2850 2900 50  0001 C CNN
	5    2850 2900
	1    0    0    -1  
$EndComp
Text GLabel 2550 2900 0    50   Input ~ 0
inv_MI
Text GLabel 3150 2900 2    50   Input ~ 0
MI
$Comp
L 74xx:74LS04 U3
U 6 1 6083A85B
P 2850 3400
F 0 "U3" H 2850 3717 50  0000 C CNN
F 1 "74LS04" H 2850 3626 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 3400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 2850 3400 50  0001 C CNN
	6    2850 3400
	1    0    0    -1  
$EndComp
Text GLabel 2550 3400 0    50   Input ~ 0
inv_DI
Text GLabel 3150 3400 2    50   Input ~ 0
DI
$Comp
L 74xx:74LS04 U3
U 7 1 6083C67A
P 6300 7150
F 0 "U3" H 6530 7196 50  0000 L CNN
F 1 "74LS04" H 6530 7105 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6300 7150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 6300 7150 50  0001 C CNN
	7    6300 7150
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS138 U8
U 1 1 6084615D
P 4450 1400
F 0 "U8" H 4450 2181 50  0000 C CNN
F 1 "74LS138" H 4450 2090 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket" H 4450 1400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS138" H 4450 1400 50  0001 C CNN
	1    4450 1400
	1    0    0    -1  
$EndComp
Text GLabel 3950 1100 0    50   Input ~ 0
U12
Text GLabel 3950 1200 0    50   Input ~ 0
U13
Text GLabel 3950 1300 0    50   Input ~ 0
U14
Text GLabel 4950 1100 2    50   Input ~ 0
~PO~
Text GLabel 4950 1200 2    50   Input ~ 0
~IOH~
Text GLabel 4950 1300 2    50   Input ~ 0
~IOL~
Text GLabel 4950 1400 2    50   Input ~ 0
inv_MO
Text GLabel 4950 1700 2    50   Input ~ 0
inv_DO
$Comp
L 74xx:74LS138 U9
U 1 1 6084D1B7
P 4450 3050
F 0 "U9" H 4450 3831 50  0000 C CNN
F 1 "74LS138" H 4450 3740 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket" H 4450 3050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS138" H 4450 3050 50  0001 C CNN
	1    4450 3050
	1    0    0    -1  
$EndComp
Text GLabel 3950 2750 0    50   Input ~ 0
U5
Text GLabel 3950 2850 0    50   Input ~ 0
U6
Text GLabel 3950 2950 0    50   Input ~ 0
U7
Text GLabel 3950 1600 0    50   Input ~ 0
~EO~
NoConn ~ 4950 2750
Text GLabel 4950 2850 2    50   Input ~ 0
~AI~
Text GLabel 4950 2950 2    50   Input ~ 0
~II~
Text GLabel 4950 3050 2    50   Input ~ 0
inv_MI
Text GLabel 4950 3150 2    50   Input ~ 0
~XI~
Text GLabel 4950 3250 2    50   Input ~ 0
~YI~
Text GLabel 4950 3350 2    50   Input ~ 0
inv_DI
Text GLabel 1750 1150 2    50   Input ~ 0
U0
Text GLabel 1750 1250 2    50   Input ~ 0
U1
Text GLabel 1750 1450 2    50   Input ~ 0
U3
Text GLabel 1750 1350 2    50   Input ~ 0
U2
Text GLabel 1750 1550 2    50   Input ~ 0
U4
Text GLabel 1750 1650 2    50   Input ~ 0
U5
Text GLabel 1750 1750 2    50   Input ~ 0
U6
Text GLabel 1750 1850 2    50   Input ~ 0
U7
Text GLabel 1750 3750 2    50   Input ~ 0
U8
Text GLabel 1750 3850 2    50   Input ~ 0
U9
Text GLabel 1750 3950 2    50   Input ~ 0
U10
Text GLabel 1750 4050 2    50   Input ~ 0
U11
Text GLabel 1750 4150 2    50   Input ~ 0
U12
Text GLabel 1750 4250 2    50   Input ~ 0
U13
Text GLabel 1750 4350 2    50   Input ~ 0
U14
Text GLabel 1750 4450 2    50   Input ~ 0
U15
Text GLabel 950  1450 0    50   Input ~ 0
I8
Text GLabel 950  1550 0    50   Input ~ 0
I9
Text GLabel 950  1650 0    50   Input ~ 0
I10
Text GLabel 950  1750 0    50   Input ~ 0
I11
Text GLabel 950  1850 0    50   Input ~ 0
I12
Text GLabel 950  1950 0    50   Input ~ 0
I13
Text GLabel 950  2050 0    50   Input ~ 0
I14
Text GLabel 950  2150 0    50   Input ~ 0
I15
Text GLabel 950  1150 0    50   Input ~ 0
T0
Text GLabel 950  1250 0    50   Input ~ 0
T1
Text GLabel 950  1350 0    50   Input ~ 0
T2
Text GLabel 950  3750 0    50   Input ~ 0
T0
Text GLabel 950  3850 0    50   Input ~ 0
T1
Text GLabel 950  3950 0    50   Input ~ 0
T2
$Comp
L 74xx:74LS08 U4
U 1 1 608685AE
P 1200 6300
F 0 "U4" H 1200 6625 50  0000 C CNN
F 1 "74LS08" H 1200 6534 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1200 6300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 1200 6300 50  0001 C CNN
	1    1200 6300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U4
U 2 1 60869A67
P 1200 6850
F 0 "U4" H 1200 7175 50  0000 C CNN
F 1 "74LS08" H 1200 7084 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1200 6850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 1200 6850 50  0001 C CNN
	2    1200 6850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U4
U 3 1 6086BE03
P 1200 7400
F 0 "U4" H 1200 7725 50  0000 C CNN
F 1 "74LS08" H 1200 7634 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1200 7400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 1200 7400 50  0001 C CNN
	3    1200 7400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U4
U 4 1 6086D5E6
P 2050 6300
F 0 "U4" H 2050 6625 50  0000 C CNN
F 1 "74LS08" H 2050 6534 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2050 6300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 2050 6300 50  0001 C CNN
	4    2050 6300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U6
U 5 1 6086EAFC
P 5400 7150
F 0 "U6" H 5630 7196 50  0000 L CNN
F 1 "74LS08" H 5630 7105 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5400 7150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 5400 7150 50  0001 C CNN
	5    5400 7150
	1    0    0    -1  
$EndComp
Text GLabel 900  6200 0    50   Input ~ 0
~EO~
Text GLabel 900  6750 0    50   Input ~ 0
~EO~
Text GLabel 900  6400 0    50   Input ~ 0
U11
Text GLabel 900  6950 0    50   Input ~ 0
U10
Text GLabel 1500 6300 2    50   Input ~ 0
RT
Text GLabel 1500 6850 2    50   Input ~ 0
PP
NoConn ~ 900  7300
NoConn ~ 900  7500
NoConn ~ 1750 6200
NoConn ~ 1750 6400
NoConn ~ 2350 6300
NoConn ~ 1500 7400
$Comp
L 74xx:74LS08 U6
U 1 1 6087B330
P 2900 4100
F 0 "U6" H 2900 4425 50  0000 C CNN
F 1 "74LS08" H 2900 4334 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2900 4100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 2900 4100 50  0001 C CNN
	1    2900 4100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U6
U 2 1 6087D090
P 2900 4650
F 0 "U6" H 2900 4975 50  0000 C CNN
F 1 "74LS08" H 2900 4884 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2900 4650 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 2900 4650 50  0001 C CNN
	2    2900 4650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U6
U 3 1 6087EC61
P 2900 5200
F 0 "U6" H 2900 5525 50  0000 C CNN
F 1 "74LS08" H 2900 5434 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2900 5200 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 2900 5200 50  0001 C CNN
	3    2900 5200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U6
U 4 1 6088068F
P 2900 5750
F 0 "U6" H 2900 6075 50  0000 C CNN
F 1 "74LS08" H 2900 5984 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2900 5750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 2900 5750 50  0001 C CNN
	4    2900 5750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U4
U 5 1 608824D3
P 4500 7150
F 0 "U4" H 4730 7196 50  0000 L CNN
F 1 "74LS08" H 4730 7105 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4500 7150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS08" H 4500 7150 50  0001 C CNN
	5    4500 7150
	1    0    0    -1  
$EndComp
Text GLabel 2600 4000 0    50   Input ~ 0
JZ
Text GLabel 2600 4550 0    50   Input ~ 0
JLT
Text GLabel 2600 5100 0    50   Input ~ 0
JGT
Text GLabel 2600 4200 0    50   Input ~ 0
Z
Text GLabel 2600 4750 0    50   Input ~ 0
LT
Text GLabel 2600 5300 0    50   Input ~ 0
GT
Text GLabel 3200 4100 2    50   Input ~ 0
JZ_Z
Text GLabel 3200 4650 2    50   Input ~ 0
JLT_LT
Text GLabel 3200 5200 2    50   Input ~ 0
JGT_GT
NoConn ~ 2600 5650
NoConn ~ 2600 5850
NoConn ~ 3200 5750
$Comp
L 74xx:74LS32 U7
U 1 1 608BF258
P 4200 4300
F 0 "U7" H 4200 4625 50  0000 C CNN
F 1 "74LS32" H 4200 4534 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 4300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4200 4300 50  0001 C CNN
	1    4200 4300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U7
U 2 1 608C12EF
P 4200 4850
F 0 "U7" H 4200 5175 50  0000 C CNN
F 1 "74LS32" H 4200 5084 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 4850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4200 4850 50  0001 C CNN
	2    4200 4850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U7
U 3 1 608C3373
P 4800 4950
F 0 "U7" H 4800 5275 50  0000 C CNN
F 1 "74LS32" H 4800 5184 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4800 4950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4800 4950 50  0001 C CNN
	3    4800 4950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U7
U 4 1 608C572E
P 4200 5400
F 0 "U7" H 4200 5725 50  0000 C CNN
F 1 "74LS32" H 4200 5634 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 5400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4200 5400 50  0001 C CNN
	4    4200 5400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U7
U 5 1 608C7A20
P 3600 7150
F 0 "U7" H 3830 7196 50  0000 L CNN
F 1 "74LS32" H 3830 7105 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 3600 7150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 3600 7150 50  0001 C CNN
	5    3600 7150
	1    0    0    -1  
$EndComp
NoConn ~ 3900 5500
NoConn ~ 3900 5300
NoConn ~ 4500 5400
Text GLabel 3900 4200 0    50   Input ~ 0
Z
Text GLabel 3900 4750 0    50   Input ~ 0
JZ_Z
Text GLabel 4500 5050 0    50   Input ~ 0
JLT_LT
Text GLabel 3900 4400 0    50   Input ~ 0
LT
Text GLabel 3900 4950 0    50   Input ~ 0
JGT_GT
Text GLabel 5100 4950 2    50   Input ~ 0
JMP
$Comp
L 74xx:74LS00 U5
U 1 1 6093EE07
P 5900 900
F 0 "U5" H 5900 1225 50  0000 C CNN
F 1 "74LS00" H 5900 1134 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5900 900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 5900 900 50  0001 C CNN
	1    5900 900 
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U5
U 2 1 60940AA0
P 5900 1450
F 0 "U5" H 5900 1775 50  0000 C CNN
F 1 "74LS00" H 5900 1684 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5900 1450 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 5900 1450 50  0001 C CNN
	2    5900 1450
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U5
U 3 1 6094E49A
P 5900 2000
F 0 "U5" H 5900 2325 50  0000 C CNN
F 1 "74LS00" H 5900 2234 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5900 2000 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 5900 2000 50  0001 C CNN
	3    5900 2000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U5
U 4 1 60950A8B
P 6500 2100
F 0 "U5" H 6500 2425 50  0000 C CNN
F 1 "74LS00" H 6500 2334 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6500 2100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 6500 2100 50  0001 C CNN
	4    6500 2100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U5
U 5 1 60953346
P 2700 7150
F 0 "U5" H 2930 7196 50  0000 L CNN
F 1 "74LS00" H 2930 7105 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2700 7150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 2700 7150 50  0001 C CNN
	5    2700 7150
	1    0    0    -1  
$EndComp
Text GLabel 5600 800  0    50   Input ~ 0
CLK
Text GLabel 5600 1350 0    50   Input ~ 0
RT
Text GLabel 5600 1900 0    50   Input ~ 0
inv_RT
Text GLabel 5600 1000 0    50   Input ~ 0
CLK
Text GLabel 5600 1550 0    50   Input ~ 0
RT
Text GLabel 5600 2100 0    50   Input ~ 0
~RESET~
Text GLabel 6200 900  2    50   Input ~ 0
inv_CLK
Text GLabel 6200 1450 2    50   Input ~ 0
inv_RT
Wire Wire Line
	6200 2200 6200 2000
Connection ~ 6200 2000
Text GLabel 6800 2100 2    50   Input ~ 0
~reset_T~
$Comp
L 74xx:74LS161 U10
U 1 1 609A252A
P 6100 3350
F 0 "U10" H 6100 4331 50  0000 C CNN
F 1 "74LS161" H 6100 4240 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket" H 6100 3350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS161" H 6100 3350 50  0001 C CNN
	1    6100 3350
	1    0    0    -1  
$EndComp
NoConn ~ 5600 2850
NoConn ~ 5600 2950
NoConn ~ 5600 3050
NoConn ~ 5600 3150
NoConn ~ 6600 3350
Text GLabel 6600 2850 2    50   Input ~ 0
T0
Text GLabel 6600 2950 2    50   Input ~ 0
T1
Text GLabel 6600 3050 2    50   Input ~ 0
T2
NoConn ~ 6600 3150
Text GLabel 5600 3650 0    50   Input ~ 0
inv_CLK
Text GLabel 5600 3850 0    50   Input ~ 0
~reset_T~
Text GLabel 5600 3450 0    50   Input ~ 0
VCC
Wire Wire Line
	5600 3550 5600 3450
Connection ~ 5600 3450
Wire Wire Line
	5600 3450 5600 3350
$Sheet
S 7850 1050 1150 1350
U 609E208A
F0 "program-counter" 50
F1 "pc.sch" 50
$EndSheet
$Sheet
S 7850 2850 1150 1100
U 609FA30B
F0 "instruction-register" 50
F1 "ir.sch" 50
$EndSheet
Text GLabel 6650 6650 2    50   Input ~ 0
VCC
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 60A2CDBF
P 6650 6650
F 0 "#FLG0101" H 6650 6725 50  0001 C CNN
F 1 "PWR_FLAG" H 6650 6823 50  0000 C CNN
F 2 "" H 6650 6650 50  0001 C CNN
F 3 "~" H 6650 6650 50  0001 C CNN
	1    6650 6650
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 60A2D941
P 6650 7650
F 0 "#FLG0102" H 6650 7725 50  0001 C CNN
F 1 "PWR_FLAG" H 6650 7823 50  0000 C CNN
F 2 "" H 6650 7650 50  0001 C CNN
F 3 "~" H 6650 7650 50  0001 C CNN
	1    6650 7650
	1    0    0    -1  
$EndComp
Text GLabel 6650 7650 2    50   Input ~ 0
GND
Wire Wire Line
	6650 6650 6300 6650
Connection ~ 2700 6650
Wire Wire Line
	2700 6650 2300 6650
Connection ~ 3600 6650
Wire Wire Line
	3600 6650 3150 6650
Connection ~ 4500 6650
Connection ~ 5400 6650
Wire Wire Line
	5400 6650 4950 6650
Connection ~ 6300 6650
Wire Wire Line
	6300 6650 5850 6650
$Comp
L Device:C C13
U 1 1 60A31673
P 2300 7100
F 0 "C13" H 2415 7146 50  0000 L CNN
F 1 "C" H 2415 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 2338 6950 50  0001 C CNN
F 3 "~" H 2300 7100 50  0001 C CNN
	1    2300 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C14
U 1 1 60A3219B
P 3150 7100
F 0 "C14" H 3265 7146 50  0000 L CNN
F 1 "C" H 3265 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 3188 6950 50  0001 C CNN
F 3 "~" H 3150 7100 50  0001 C CNN
	1    3150 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C17
U 1 1 60A32D21
P 4050 7100
F 0 "C17" H 4165 7146 50  0000 L CNN
F 1 "C" H 4165 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 4088 6950 50  0001 C CNN
F 3 "~" H 4050 7100 50  0001 C CNN
	1    4050 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C18
U 1 1 60A3389E
P 4950 7100
F 0 "C18" H 5065 7146 50  0000 L CNN
F 1 "C" H 5065 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 4988 6950 50  0001 C CNN
F 3 "~" H 4950 7100 50  0001 C CNN
	1    4950 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C19
U 1 1 60A34459
P 5850 7100
F 0 "C19" H 5965 7146 50  0000 L CNN
F 1 "C" H 5965 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 5888 6950 50  0001 C CNN
F 3 "~" H 5850 7100 50  0001 C CNN
	1    5850 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 6950 2300 6650
Wire Wire Line
	3150 6950 3150 6650
Connection ~ 3150 6650
Wire Wire Line
	3150 6650 2700 6650
Wire Wire Line
	4050 6950 4050 6650
Wire Wire Line
	3600 6650 4050 6650
Connection ~ 4050 6650
Wire Wire Line
	4050 6650 4500 6650
Wire Wire Line
	4950 6950 4950 6650
Connection ~ 4950 6650
Wire Wire Line
	4950 6650 4500 6650
Wire Wire Line
	5850 6950 5850 6650
Connection ~ 5850 6650
Wire Wire Line
	5850 6650 5400 6650
Wire Wire Line
	2300 7250 2300 7650
Wire Wire Line
	2300 7650 2700 7650
Connection ~ 2700 7650
Wire Wire Line
	2700 7650 3150 7650
Connection ~ 3600 7650
Wire Wire Line
	3600 7650 4050 7650
Connection ~ 4500 7650
Wire Wire Line
	4500 7650 4950 7650
Connection ~ 5400 7650
Wire Wire Line
	5400 7650 5850 7650
Connection ~ 6300 7650
Wire Wire Line
	6300 7650 6650 7650
Text GLabel 1350 950  2    50   Input ~ 0
VCC
Text GLabel 1350 3150 2    50   Input ~ 0
GND
$Comp
L Device:C C11
U 1 1 60A491D1
P 650 1900
F 0 "C11" H 765 1946 50  0000 L CNN
F 1 "C" H 765 1855 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 688 1750 50  0001 C CNN
F 3 "~" H 650 1900 50  0001 C CNN
	1    650  1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	650  1750 650  950 
Wire Wire Line
	650  950  1350 950 
Wire Wire Line
	650  2050 650  3150
Wire Wire Line
	650  3150 1350 3150
$Comp
L Device:C C15
U 1 1 60A4B742
P 3650 1500
F 0 "C15" H 3765 1546 50  0000 L CNN
F 1 "C" H 3765 1455 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 3688 1350 50  0001 C CNN
F 3 "~" H 3650 1500 50  0001 C CNN
	1    3650 1500
	1    0    0    -1  
$EndComp
$Comp
L Device:C C16
U 1 1 60A4BB31
P 3650 3050
F 0 "C16" H 3765 3096 50  0000 L CNN
F 1 "C" H 3765 3005 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 3688 2900 50  0001 C CNN
F 3 "~" H 3650 3050 50  0001 C CNN
	1    3650 3050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C20
U 1 1 60A50C76
P 6900 3300
F 0 "C20" H 7015 3346 50  0000 L CNN
F 1 "C" H 7015 3255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 6938 3150 50  0001 C CNN
F 3 "~" H 6900 3300 50  0001 C CNN
	1    6900 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	700  4850 700  3550
Wire Wire Line
	700  3550 1350 3550
Wire Wire Line
	700  5150 700  5750
Wire Wire Line
	700  5750 1350 5750
Wire Wire Line
	3650 2900 3650 2450
Wire Wire Line
	3650 2450 4450 2450
Wire Wire Line
	3650 3200 3650 3750
Wire Wire Line
	3650 3750 4450 3750
Wire Wire Line
	3650 1350 3650 800 
Wire Wire Line
	3650 800  4450 800 
Wire Wire Line
	3650 1650 3650 2100
Wire Wire Line
	3650 2100 4450 2100
Wire Wire Line
	6100 2550 6900 2550
Wire Wire Line
	6900 2550 6900 3150
Wire Wire Line
	6900 3450 6900 4150
Wire Wire Line
	6900 4150 6100 4150
Text GLabel 4450 800  2    50   Input ~ 0
VCC
Text GLabel 1350 3550 2    50   Input ~ 0
VCC
Text GLabel 6100 2550 0    50   Input ~ 0
VCC
Text GLabel 4450 2450 2    50   Input ~ 0
VCC
Text GLabel 4450 3750 2    50   Input ~ 0
GND
Text GLabel 1350 5750 2    50   Input ~ 0
GND
Text GLabel 6100 4150 0    50   Input ~ 0
GND
Text GLabel 4450 2100 2    50   Input ~ 0
GND
Text GLabel 6750 5100 2    50   Input ~ 0
~EO~
Text GLabel 6700 5100 0    50   Input ~ 0
U15
Text GLabel 6750 5200 2    50   Input ~ 0
EX
Text GLabel 6750 5300 2    50   Input ~ 0
NX
Text GLabel 6750 5400 2    50   Input ~ 0
EY
Text GLabel 6750 5500 2    50   Input ~ 0
NY
Text GLabel 6750 5600 2    50   Input ~ 0
F
Text GLabel 6750 5700 2    50   Input ~ 0
NO
Text GLabel 6700 5200 0    50   Input ~ 0
U14
Text GLabel 6700 5300 0    50   Input ~ 0
U13
Text GLabel 6700 5400 0    50   Input ~ 0
U12
Text GLabel 6700 5500 0    50   Input ~ 0
U11
Text GLabel 6700 5600 0    50   Input ~ 0
U10
Text GLabel 6700 5700 0    50   Input ~ 0
U9
Text GLabel 6700 5900 0    50   Input ~ 0
U4
Text GLabel 6700 6000 0    50   Input ~ 0
U3
Text GLabel 6700 6100 0    50   Input ~ 0
U2
Text GLabel 6750 5900 2    50   Input ~ 0
JZ
Text GLabel 6750 6000 2    50   Input ~ 0
JGT
Text GLabel 6750 6100 2    50   Input ~ 0
JLT
Wire Wire Line
	6700 5100 6750 5100
Wire Wire Line
	6700 5200 6750 5200
Wire Wire Line
	6700 5300 6750 5300
Wire Wire Line
	6700 5400 6750 5400
Wire Wire Line
	6700 5500 6750 5500
Wire Wire Line
	6700 5600 6750 5600
Wire Wire Line
	6700 5700 6750 5700
Wire Wire Line
	6700 5900 6750 5900
Wire Wire Line
	6700 6000 6750 6000
Wire Wire Line
	6700 6100 6750 6100
Wire Wire Line
	4050 7250 4050 7650
Connection ~ 4050 7650
Wire Wire Line
	4050 7650 4500 7650
Wire Wire Line
	3150 7250 3150 7650
Connection ~ 3150 7650
Wire Wire Line
	3150 7650 3600 7650
Wire Wire Line
	4950 7250 4950 7650
Connection ~ 4950 7650
Wire Wire Line
	4950 7650 5400 7650
Wire Wire Line
	5850 7250 5850 7650
Connection ~ 5850 7650
Wire Wire Line
	5850 7650 6300 7650
Text GLabel 6700 6200 0    50   Input ~ 0
U1
Text GLabel 6700 6300 0    50   Input ~ 0
U0
Text GLabel 6750 6300 2    50   Input ~ 0
spare0
Text GLabel 6750 6200 2    50   Input ~ 0
spare1
Wire Wire Line
	6700 6200 6750 6200
Wire Wire Line
	6700 6300 6750 6300
Text GLabel 10800 6050 2    50   Input ~ 0
spare1
Text GLabel 3950 3250 0    50   Input ~ 0
~EO~
Text GLabel 3950 3350 0    50   Input ~ 0
VCC
Wire Wire Line
	3950 3350 3950 3450
Text GLabel 3950 1700 0    50   Input ~ 0
VCC
Wire Wire Line
	3950 1700 3950 1800
Text GLabel 4950 1500 2    50   Input ~ 0
spare_O4
Text GLabel 4950 1600 2    50   Input ~ 0
spare_O5
Text GLabel 4950 1800 2    50   Input ~ 0
spare_O7
Text GLabel 4950 3450 2    50   Input ~ 0
spare_I7
Text GLabel 10800 5950 2    50   Input ~ 0
spare_O4
Text GLabel 10800 5850 2    50   Input ~ 0
spare_O5
Text GLabel 10800 5750 2    50   Input ~ 0
spare_O7
Text GLabel 9900 5950 0    50   Input ~ 0
spare_I7
NoConn ~ 10600 5550
Text GLabel 950  5550 0    50   Input ~ 0
GND
Wire Wire Line
	950  5550 950  5450
Text GLabel 950  5350 0    50   Input ~ 0
VCC
Text GLabel 950  2750 0    50   Input ~ 0
VCC
Text GLabel 950  2950 0    50   Input ~ 0
GND
Wire Wire Line
	950  2950 950  2850
Text GLabel 6700 5800 0    50   Input ~ 0
U8
Text GLabel 6750 5800 2    50   Input ~ 0
spare8
Wire Wire Line
	6700 5800 6750 5800
Text GLabel 10800 5650 2    50   Input ~ 0
spare8
Text GLabel 950  4050 0    50   Input ~ 0
I8
Text GLabel 950  4150 0    50   Input ~ 0
I9
Text GLabel 950  4250 0    50   Input ~ 0
I10
Text GLabel 950  4350 0    50   Input ~ 0
I11
Text GLabel 950  4450 0    50   Input ~ 0
I12
Text GLabel 950  4550 0    50   Input ~ 0
I13
Text GLabel 950  4650 0    50   Input ~ 0
I14
Text GLabel 950  4750 0    50   Input ~ 0
I15
$Comp
L Device:C C12
U 1 1 60BD4199
P 700 5000
F 0 "C12" H 815 5046 50  0000 L CNN
F 1 "C" H 815 4955 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 738 4850 50  0001 C CNN
F 3 "~" H 700 5000 50  0001 C CNN
	1    700  5000
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x17_Male J2
U 1 1 60BEA5A3
P 9350 1600
F 0 "J2" H 9458 2581 50  0000 C CNN
F 1 "Conn_01x17_Male" H 9458 2490 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x17_P2.54mm_Vertical" H 9350 1600 50  0001 C CNN
F 3 "~" H 9350 1600 50  0001 C CNN
	1    9350 1600
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 60BF767E
P 9700 800
F 0 "R1" V 9493 800 50  0000 C CNN
F 1 "R" V 9584 800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 800 50  0001 C CNN
F 3 "~" H 9700 800 50  0001 C CNN
	1    9700 800 
	0    1    1    0   
$EndComp
$Comp
L Device:R R2
U 1 1 60BF78CF
P 9700 900
F 0 "R2" V 9493 900 50  0000 C CNN
F 1 "R" V 9584 900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 900 50  0001 C CNN
F 3 "~" H 9700 900 50  0001 C CNN
	1    9700 900 
	0    1    1    0   
$EndComp
$Comp
L Device:R R3
U 1 1 60BF873C
P 9700 1000
F 0 "R3" V 9493 1000 50  0000 C CNN
F 1 "R" V 9584 1000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1000 50  0001 C CNN
F 3 "~" H 9700 1000 50  0001 C CNN
	1    9700 1000
	0    1    1    0   
$EndComp
$Comp
L Device:R R4
U 1 1 60BF8742
P 9700 1100
F 0 "R4" V 9493 1100 50  0000 C CNN
F 1 "R" V 9584 1100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1100 50  0001 C CNN
F 3 "~" H 9700 1100 50  0001 C CNN
	1    9700 1100
	0    1    1    0   
$EndComp
$Comp
L Device:R R5
U 1 1 60BF9DB6
P 9700 1200
F 0 "R5" V 9493 1200 50  0000 C CNN
F 1 "R" V 9584 1200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1200 50  0001 C CNN
F 3 "~" H 9700 1200 50  0001 C CNN
	1    9700 1200
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 60BF9DBC
P 9700 1300
F 0 "R6" V 9493 1300 50  0000 C CNN
F 1 "R" V 9584 1300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1300 50  0001 C CNN
F 3 "~" H 9700 1300 50  0001 C CNN
	1    9700 1300
	0    1    1    0   
$EndComp
$Comp
L Device:R R7
U 1 1 60BFB358
P 9700 1400
F 0 "R7" V 9493 1400 50  0000 C CNN
F 1 "R" V 9584 1400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1400 50  0001 C CNN
F 3 "~" H 9700 1400 50  0001 C CNN
	1    9700 1400
	0    1    1    0   
$EndComp
$Comp
L Device:R R8
U 1 1 60BFB35E
P 9700 1500
F 0 "R8" V 9493 1500 50  0000 C CNN
F 1 "R" V 9584 1500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1500 50  0001 C CNN
F 3 "~" H 9700 1500 50  0001 C CNN
	1    9700 1500
	0    1    1    0   
$EndComp
$Comp
L Device:R R9
U 1 1 60BFC99E
P 9700 1600
F 0 "R9" V 9493 1600 50  0000 C CNN
F 1 "R" V 9584 1600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1600 50  0001 C CNN
F 3 "~" H 9700 1600 50  0001 C CNN
	1    9700 1600
	0    1    1    0   
$EndComp
$Comp
L Device:R R10
U 1 1 60BFC9A4
P 9700 1700
F 0 "R10" V 9493 1700 50  0000 C CNN
F 1 "R" V 9584 1700 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1700 50  0001 C CNN
F 3 "~" H 9700 1700 50  0001 C CNN
	1    9700 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R R11
U 1 1 60BFDFD4
P 9700 1800
F 0 "R11" V 9493 1800 50  0000 C CNN
F 1 "R" V 9584 1800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1800 50  0001 C CNN
F 3 "~" H 9700 1800 50  0001 C CNN
	1    9700 1800
	0    1    1    0   
$EndComp
$Comp
L Device:R R12
U 1 1 60BFDFDA
P 9700 1900
F 0 "R12" V 9493 1900 50  0000 C CNN
F 1 "R" V 9584 1900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 1900 50  0001 C CNN
F 3 "~" H 9700 1900 50  0001 C CNN
	1    9700 1900
	0    1    1    0   
$EndComp
$Comp
L Device:R R13
U 1 1 60BFF62C
P 9700 2000
F 0 "R13" V 9493 2000 50  0000 C CNN
F 1 "R" V 9584 2000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 2000 50  0001 C CNN
F 3 "~" H 9700 2000 50  0001 C CNN
	1    9700 2000
	0    1    1    0   
$EndComp
$Comp
L Device:R R14
U 1 1 60BFF632
P 9700 2100
F 0 "R14" V 9493 2100 50  0000 C CNN
F 1 "R" V 9584 2100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 2100 50  0001 C CNN
F 3 "~" H 9700 2100 50  0001 C CNN
	1    9700 2100
	0    1    1    0   
$EndComp
$Comp
L Device:R R15
U 1 1 60C024BC
P 9700 2200
F 0 "R15" V 9493 2200 50  0000 C CNN
F 1 "R" V 9584 2200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 2200 50  0001 C CNN
F 3 "~" H 9700 2200 50  0001 C CNN
	1    9700 2200
	0    1    1    0   
$EndComp
$Comp
L Device:R R16
U 1 1 60C024C2
P 9700 2300
F 0 "R16" V 9493 2300 50  0000 C CNN
F 1 "R" V 9584 2300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 9630 2300 50  0001 C CNN
F 3 "~" H 9700 2300 50  0001 C CNN
	1    9700 2300
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x17_Male J3
U 1 1 60C06D52
P 10250 1600
F 0 "J3" H 10358 2581 50  0000 C CNN
F 1 "Conn_01x17_Male" H 10358 2490 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x17_P2.54mm_Vertical" H 10250 1600 50  0001 C CNN
F 3 "~" H 10250 1600 50  0001 C CNN
	1    10250 1600
	1    0    0    -1  
$EndComp
$Comp
L Device:R R17
U 1 1 60C06D58
P 10600 800
F 0 "R17" V 10393 800 50  0000 C CNN
F 1 "R" V 10484 800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 800 50  0001 C CNN
F 3 "~" H 10600 800 50  0001 C CNN
	1    10600 800 
	0    1    1    0   
$EndComp
$Comp
L Device:R R18
U 1 1 60C06D5E
P 10600 900
F 0 "R18" V 10393 900 50  0000 C CNN
F 1 "R" V 10484 900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 900 50  0001 C CNN
F 3 "~" H 10600 900 50  0001 C CNN
	1    10600 900 
	0    1    1    0   
$EndComp
$Comp
L Device:R R19
U 1 1 60C06D64
P 10600 1000
F 0 "R19" V 10393 1000 50  0000 C CNN
F 1 "R" V 10484 1000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1000 50  0001 C CNN
F 3 "~" H 10600 1000 50  0001 C CNN
	1    10600 1000
	0    1    1    0   
$EndComp
$Comp
L Device:R R20
U 1 1 60C06D6A
P 10600 1100
F 0 "R20" V 10393 1100 50  0000 C CNN
F 1 "R" V 10484 1100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1100 50  0001 C CNN
F 3 "~" H 10600 1100 50  0001 C CNN
	1    10600 1100
	0    1    1    0   
$EndComp
$Comp
L Device:R R21
U 1 1 60C06D70
P 10600 1200
F 0 "R21" V 10393 1200 50  0000 C CNN
F 1 "R" V 10484 1200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1200 50  0001 C CNN
F 3 "~" H 10600 1200 50  0001 C CNN
	1    10600 1200
	0    1    1    0   
$EndComp
$Comp
L Device:R R22
U 1 1 60C06D76
P 10600 1300
F 0 "R22" V 10393 1300 50  0000 C CNN
F 1 "R" V 10484 1300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1300 50  0001 C CNN
F 3 "~" H 10600 1300 50  0001 C CNN
	1    10600 1300
	0    1    1    0   
$EndComp
$Comp
L Device:R R23
U 1 1 60C06D7C
P 10600 1400
F 0 "R23" V 10393 1400 50  0000 C CNN
F 1 "R" V 10484 1400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1400 50  0001 C CNN
F 3 "~" H 10600 1400 50  0001 C CNN
	1    10600 1400
	0    1    1    0   
$EndComp
$Comp
L Device:R R24
U 1 1 60C06D82
P 10600 1500
F 0 "R24" V 10393 1500 50  0000 C CNN
F 1 "R" V 10484 1500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1500 50  0001 C CNN
F 3 "~" H 10600 1500 50  0001 C CNN
	1    10600 1500
	0    1    1    0   
$EndComp
$Comp
L Device:R R25
U 1 1 60C06D88
P 10600 1600
F 0 "R25" V 10393 1600 50  0000 C CNN
F 1 "R" V 10484 1600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1600 50  0001 C CNN
F 3 "~" H 10600 1600 50  0001 C CNN
	1    10600 1600
	0    1    1    0   
$EndComp
$Comp
L Device:R R26
U 1 1 60C06D8E
P 10600 1700
F 0 "R26" V 10393 1700 50  0000 C CNN
F 1 "R" V 10484 1700 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1700 50  0001 C CNN
F 3 "~" H 10600 1700 50  0001 C CNN
	1    10600 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R R27
U 1 1 60C06D94
P 10600 1800
F 0 "R27" V 10393 1800 50  0000 C CNN
F 1 "R" V 10484 1800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1800 50  0001 C CNN
F 3 "~" H 10600 1800 50  0001 C CNN
	1    10600 1800
	0    1    1    0   
$EndComp
$Comp
L Device:R R28
U 1 1 60C06D9A
P 10600 1900
F 0 "R28" V 10393 1900 50  0000 C CNN
F 1 "R" V 10484 1900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 1900 50  0001 C CNN
F 3 "~" H 10600 1900 50  0001 C CNN
	1    10600 1900
	0    1    1    0   
$EndComp
$Comp
L Device:R R29
U 1 1 60C06DA0
P 10600 2000
F 0 "R29" V 10393 2000 50  0000 C CNN
F 1 "R" V 10484 2000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 2000 50  0001 C CNN
F 3 "~" H 10600 2000 50  0001 C CNN
	1    10600 2000
	0    1    1    0   
$EndComp
$Comp
L Device:R R30
U 1 1 60C06DA6
P 10600 2100
F 0 "R30" V 10393 2100 50  0000 C CNN
F 1 "R" V 10484 2100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 2100 50  0001 C CNN
F 3 "~" H 10600 2100 50  0001 C CNN
	1    10600 2100
	0    1    1    0   
$EndComp
$Comp
L Device:R R31
U 1 1 60C06DAC
P 10600 2200
F 0 "R31" V 10393 2200 50  0000 C CNN
F 1 "R" V 10484 2200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 2200 50  0001 C CNN
F 3 "~" H 10600 2200 50  0001 C CNN
	1    10600 2200
	0    1    1    0   
$EndComp
$Comp
L Device:R R32
U 1 1 60C06DB2
P 10600 2300
F 0 "R32" V 10393 2300 50  0000 C CNN
F 1 "R" V 10484 2300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10530 2300 50  0001 C CNN
F 3 "~" H 10600 2300 50  0001 C CNN
	1    10600 2300
	0    1    1    0   
$EndComp
Text GLabel 9850 800  2    50   Input ~ 0
I0
Text GLabel 9850 900  2    50   Input ~ 0
I1
Text GLabel 9850 1000 2    50   Input ~ 0
I2
Text GLabel 9850 1100 2    50   Input ~ 0
I3
Text GLabel 9850 1200 2    50   Input ~ 0
I4
Text GLabel 9850 1300 2    50   Input ~ 0
I5
Text GLabel 9850 1400 2    50   Input ~ 0
I6
Text GLabel 9850 1500 2    50   Input ~ 0
I7
Text GLabel 9850 1600 2    50   Input ~ 0
I8
Text GLabel 9850 1700 2    50   Input ~ 0
I9
Text GLabel 9850 1800 2    50   Input ~ 0
I10
Text GLabel 9850 1900 2    50   Input ~ 0
I11
Text GLabel 9850 2000 2    50   Input ~ 0
I12
Text GLabel 9850 2100 2    50   Input ~ 0
I13
Text GLabel 9850 2200 2    50   Input ~ 0
I14
Text GLabel 9850 2300 2    50   Input ~ 0
I15
Text GLabel 10750 800  2    50   Input ~ 0
U0
Text GLabel 10750 900  2    50   Input ~ 0
U1
Text GLabel 10750 1000 2    50   Input ~ 0
U2
Text GLabel 10750 1100 2    50   Input ~ 0
U3
Text GLabel 10750 1200 2    50   Input ~ 0
U4
Text GLabel 10750 1300 2    50   Input ~ 0
U5
Text GLabel 10750 1400 2    50   Input ~ 0
U6
Text GLabel 10750 1500 2    50   Input ~ 0
U7
Text GLabel 10750 1600 2    50   Input ~ 0
U8
Text GLabel 10750 1700 2    50   Input ~ 0
U9
Text GLabel 10750 1800 2    50   Input ~ 0
U10
Text GLabel 10750 1900 2    50   Input ~ 0
U11
Text GLabel 10750 2000 2    50   Input ~ 0
U12
Text GLabel 10750 2100 2    50   Input ~ 0
U13
Text GLabel 10750 2200 2    50   Input ~ 0
U14
Text GLabel 10750 2300 2    50   Input ~ 0
U15
Text GLabel 9100 4950 2    50   Input ~ 0
~EO~
Text GLabel 9100 5050 2    50   Input ~ 0
~PO~
Text GLabel 9100 5150 2    50   Input ~ 0
~IOH~
Text GLabel 9100 5250 2    50   Input ~ 0
~IOL~
Text GLabel 9100 5350 2    50   Input ~ 0
inv_MO
Text GLabel 9100 5450 2    50   Input ~ 0
inv_DO
Text GLabel 9100 5550 2    50   Input ~ 0
inv_RT
Text GLabel 9100 5650 2    50   Input ~ 0
~AI~
Text GLabel 9100 5750 2    50   Input ~ 0
~II~
Text GLabel 9100 5850 2    50   Input ~ 0
~XI~
Text GLabel 9100 5950 2    50   Input ~ 0
~YI~
Text GLabel 9100 6050 2    50   Input ~ 0
inv_MI
Text GLabel 9100 6150 2    50   Input ~ 0
inv_DI
Text GLabel 9100 6250 2    50   Input ~ 0
inv_PP
Text GLabel 8800 6350 2    50   Input ~ 0
VCC
$Comp
L Device:R R42
U 1 1 60C9B4AC
P 8950 4950
F 0 "R42" V 8743 4950 50  0000 C CNN
F 1 "R" V 8834 4950 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 4950 50  0001 C CNN
F 3 "~" H 8950 4950 50  0001 C CNN
	1    8950 4950
	0    1    1    0   
$EndComp
$Comp
L Device:R R43
U 1 1 60C9BDE5
P 8950 5050
F 0 "R43" V 8743 5050 50  0000 C CNN
F 1 "R" V 8834 5050 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5050 50  0001 C CNN
F 3 "~" H 8950 5050 50  0001 C CNN
	1    8950 5050
	0    1    1    0   
$EndComp
$Comp
L Device:R R44
U 1 1 60C9C648
P 8950 5150
F 0 "R44" V 8743 5150 50  0000 C CNN
F 1 "R" V 8834 5150 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5150 50  0001 C CNN
F 3 "~" H 8950 5150 50  0001 C CNN
	1    8950 5150
	0    1    1    0   
$EndComp
$Comp
L Device:R R45
U 1 1 60C9CEC7
P 8950 5250
F 0 "R45" V 8743 5250 50  0000 C CNN
F 1 "R" V 8834 5250 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5250 50  0001 C CNN
F 3 "~" H 8950 5250 50  0001 C CNN
	1    8950 5250
	0    1    1    0   
$EndComp
$Comp
L Device:R R46
U 1 1 60CA302C
P 8950 5350
F 0 "R46" V 8743 5350 50  0000 C CNN
F 1 "R" V 8834 5350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5350 50  0001 C CNN
F 3 "~" H 8950 5350 50  0001 C CNN
	1    8950 5350
	0    1    1    0   
$EndComp
$Comp
L Device:R R47
U 1 1 60CA3032
P 8950 5450
F 0 "R47" V 8743 5450 50  0000 C CNN
F 1 "R" V 8834 5450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5450 50  0001 C CNN
F 3 "~" H 8950 5450 50  0001 C CNN
	1    8950 5450
	0    1    1    0   
$EndComp
$Comp
L Device:R R48
U 1 1 60CA3038
P 8950 5550
F 0 "R48" V 8743 5550 50  0000 C CNN
F 1 "R" V 8834 5550 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5550 50  0001 C CNN
F 3 "~" H 8950 5550 50  0001 C CNN
	1    8950 5550
	0    1    1    0   
$EndComp
$Comp
L Device:R R49
U 1 1 60CA303E
P 8950 5650
F 0 "R49" V 8743 5650 50  0000 C CNN
F 1 "R" V 8834 5650 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5650 50  0001 C CNN
F 3 "~" H 8950 5650 50  0001 C CNN
	1    8950 5650
	0    1    1    0   
$EndComp
$Comp
L Device:R R50
U 1 1 60CA52B4
P 8950 5750
F 0 "R50" V 8743 5750 50  0000 C CNN
F 1 "R" V 8834 5750 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5750 50  0001 C CNN
F 3 "~" H 8950 5750 50  0001 C CNN
	1    8950 5750
	0    1    1    0   
$EndComp
$Comp
L Device:R R51
U 1 1 60CA52BA
P 8950 5850
F 0 "R51" V 8743 5850 50  0000 C CNN
F 1 "R" V 8834 5850 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5850 50  0001 C CNN
F 3 "~" H 8950 5850 50  0001 C CNN
	1    8950 5850
	0    1    1    0   
$EndComp
$Comp
L Device:R R52
U 1 1 60CA52C0
P 8950 5950
F 0 "R52" V 8743 5950 50  0000 C CNN
F 1 "R" V 8834 5950 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 5950 50  0001 C CNN
F 3 "~" H 8950 5950 50  0001 C CNN
	1    8950 5950
	0    1    1    0   
$EndComp
$Comp
L Device:R R53
U 1 1 60CA52C6
P 8950 6050
F 0 "R53" V 8743 6050 50  0000 C CNN
F 1 "R" V 8834 6050 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 6050 50  0001 C CNN
F 3 "~" H 8950 6050 50  0001 C CNN
	1    8950 6050
	0    1    1    0   
$EndComp
$Comp
L Device:R R54
U 1 1 60CA7284
P 8950 6150
F 0 "R54" V 8743 6150 50  0000 C CNN
F 1 "R" V 8834 6150 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 6150 50  0001 C CNN
F 3 "~" H 8950 6150 50  0001 C CNN
	1    8950 6150
	0    1    1    0   
$EndComp
$Comp
L Device:R R55
U 1 1 60CA728A
P 8950 6250
F 0 "R55" V 8743 6250 50  0000 C CNN
F 1 "R" V 8834 6250 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8880 6250 50  0001 C CNN
F 3 "~" H 8950 6250 50  0001 C CNN
	1    8950 6250
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x15_Male J5
U 1 1 60CB0A1E
P 8600 5650
F 0 "J5" H 8708 6531 50  0000 C CNN
F 1 "Conn_01x15_Male" H 8708 6440 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x15_P2.54mm_Vertical" H 8600 5650 50  0001 C CNN
F 3 "~" H 8600 5650 50  0001 C CNN
	1    8600 5650
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP1
U 1 1 60CCA7F9
P 10000 5950
F 0 "JP1" H 10000 5765 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10000 5856 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10000 5950 50  0001 C CNN
F 3 "~" H 10000 5950 50  0001 C CNN
	1    10000 5950
	-1   0    0    1   
$EndComp
$Comp
L Device:Jumper_NO_Small JP2
U 1 1 60CDBB9B
P 10700 5650
F 0 "JP2" H 10700 5835 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10700 5744 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10700 5650 50  0001 C CNN
F 3 "~" H 10700 5650 50  0001 C CNN
	1    10700 5650
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP3
U 1 1 60CDC183
P 10700 5750
F 0 "JP3" H 10700 5935 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10700 5844 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10700 5750 50  0001 C CNN
F 3 "~" H 10700 5750 50  0001 C CNN
	1    10700 5750
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP4
U 1 1 60CDC531
P 10700 5850
F 0 "JP4" H 10700 6035 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10700 5944 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10700 5850 50  0001 C CNN
F 3 "~" H 10700 5850 50  0001 C CNN
	1    10700 5850
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP5
U 1 1 60CDC8D6
P 10700 5950
F 0 "JP5" H 10700 6135 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10700 6044 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10700 5950 50  0001 C CNN
F 3 "~" H 10700 5950 50  0001 C CNN
	1    10700 5950
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP6
U 1 1 60CDCC77
P 10700 6050
F 0 "JP6" H 10700 6235 50  0000 C CNN
F 1 "Jumper_NO_Small" H 10700 6144 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10700 6050 50  0001 C CNN
F 3 "~" H 10700 6050 50  0001 C CNN
	1    10700 6050
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x10_Male J4
U 1 1 60CEDE3A
P 7250 4600
F 0 "J4" H 7358 5181 50  0000 C CNN
F 1 "Conn_01x10_Male" H 7358 5090 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x10_P2.54mm_Vertical" H 7250 4600 50  0001 C CNN
F 3 "~" H 7250 4600 50  0001 C CNN
	1    7250 4600
	1    0    0    -1  
$EndComp
$Comp
L Device:R R33
U 1 1 60D06B3B
P 7600 4200
F 0 "R33" V 7393 4200 50  0000 C CNN
F 1 "R" V 7484 4200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4200 50  0001 C CNN
F 3 "~" H 7600 4200 50  0001 C CNN
	1    7600 4200
	0    1    1    0   
$EndComp
$Comp
L Device:R R34
U 1 1 60D06B41
P 7600 4300
F 0 "R34" V 7393 4300 50  0000 C CNN
F 1 "R" V 7484 4300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4300 50  0001 C CNN
F 3 "~" H 7600 4300 50  0001 C CNN
	1    7600 4300
	0    1    1    0   
$EndComp
$Comp
L Device:R R35
U 1 1 60D06B47
P 7600 4400
F 0 "R35" V 7393 4400 50  0000 C CNN
F 1 "R" V 7484 4400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4400 50  0001 C CNN
F 3 "~" H 7600 4400 50  0001 C CNN
	1    7600 4400
	0    1    1    0   
$EndComp
$Comp
L Device:R R36
U 1 1 60D06B4D
P 7600 4500
F 0 "R36" V 7393 4500 50  0000 C CNN
F 1 "R" V 7484 4500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4500 50  0001 C CNN
F 3 "~" H 7600 4500 50  0001 C CNN
	1    7600 4500
	0    1    1    0   
$EndComp
$Comp
L Device:R R37
U 1 1 60D06B53
P 7600 4600
F 0 "R37" V 7393 4600 50  0000 C CNN
F 1 "R" V 7484 4600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4600 50  0001 C CNN
F 3 "~" H 7600 4600 50  0001 C CNN
	1    7600 4600
	0    1    1    0   
$EndComp
$Comp
L Device:R R38
U 1 1 60D06B59
P 7600 4700
F 0 "R38" V 7393 4700 50  0000 C CNN
F 1 "R" V 7484 4700 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4700 50  0001 C CNN
F 3 "~" H 7600 4700 50  0001 C CNN
	1    7600 4700
	0    1    1    0   
$EndComp
$Comp
L Device:R R39
U 1 1 60D06B5F
P 7600 4800
F 0 "R39" V 7393 4800 50  0000 C CNN
F 1 "R" V 7484 4800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4800 50  0001 C CNN
F 3 "~" H 7600 4800 50  0001 C CNN
	1    7600 4800
	0    1    1    0   
$EndComp
$Comp
L Device:R R40
U 1 1 60D06B65
P 7600 4900
F 0 "R40" V 7393 4900 50  0000 C CNN
F 1 "R" V 7484 4900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 4900 50  0001 C CNN
F 3 "~" H 7600 4900 50  0001 C CNN
	1    7600 4900
	0    1    1    0   
$EndComp
$Comp
L Device:R R41
U 1 1 60D06B6B
P 7600 5000
F 0 "R41" V 7393 5000 50  0000 C CNN
F 1 "R" V 7484 5000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 7530 5000 50  0001 C CNN
F 3 "~" H 7600 5000 50  0001 C CNN
	1    7600 5000
	0    1    1    0   
$EndComp
Text GLabel 7750 4200 2    50   Input ~ 0
EX
Text GLabel 7750 4300 2    50   Input ~ 0
NX
Text GLabel 7750 4400 2    50   Input ~ 0
EY
Text GLabel 7750 4500 2    50   Input ~ 0
NY
Text GLabel 7750 4600 2    50   Input ~ 0
F
Text GLabel 7750 4700 2    50   Input ~ 0
NO
Text GLabel 7750 4800 2    50   Input ~ 0
T0
Text GLabel 7750 4900 2    50   Input ~ 0
T1
Text GLabel 7750 5000 2    50   Input ~ 0
T2
Text GLabel 7450 5100 2    50   Input ~ 0
GND
Text GLabel 10450 2400 2    50   Input ~ 0
GND
Text GLabel 9550 2400 2    50   Input ~ 0
GND
Text GLabel 10600 6150 2    50   Input ~ 0
spare0
Text Notes 4950 2700 0    50   ~ 0
bus_in==0 needs\nto be unused
$EndSCHEMATC
