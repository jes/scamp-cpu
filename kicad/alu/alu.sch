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
Text GLabel 10350 2000 0    50   3State ~ 0
D1
Text GLabel 10350 2100 0    50   3State ~ 0
D2
Text GLabel 10350 2200 0    50   3State ~ 0
D3
Text GLabel 10350 2300 0    50   3State ~ 0
D4
Text GLabel 10350 2400 0    50   3State ~ 0
D5
Text GLabel 10350 2500 0    50   3State ~ 0
D6
Text GLabel 10350 2600 0    50   3State ~ 0
D7
Text GLabel 10350 2700 0    50   3State ~ 0
D8
Text GLabel 10350 2800 0    50   3State ~ 0
D9
Text GLabel 10350 2900 0    50   3State ~ 0
D10
Text GLabel 10350 3000 0    50   3State ~ 0
D11
Text GLabel 10350 3100 0    50   3State ~ 0
D12
Text GLabel 10350 3200 0    50   3State ~ 0
D13
Text GLabel 10350 3300 0    50   3State ~ 0
D14
Text GLabel 10350 3400 0    50   3State ~ 0
D15
Text GLabel 10850 4800 2    50   Output ~ 0
GND
Text GLabel 10350 4800 0    50   Output ~ 0
VCC
Text GLabel 10350 4700 0    50   Output ~ 0
CLK
Text GLabel 10350 1900 0    50   3State ~ 0
D0
Text GLabel 10350 3600 0    50   Input ~ 0
LT
Text GLabel 10350 3700 0    50   Output ~ 0
~EO~
Text GLabel 10350 3800 0    50   Output ~ 0
~XI~
Text GLabel 10350 3900 0    50   Output ~ 0
~YI~
Text GLabel 10850 3500 2    50   Output ~ 0
EX
Text GLabel 10850 3600 2    50   Output ~ 0
NX
Text GLabel 10850 3700 2    50   Output ~ 0
EY
Text GLabel 10850 3800 2    50   Output ~ 0
NY
Text GLabel 10850 3900 2    50   Output ~ 0
F
Text GLabel 10850 4000 2    50   Output ~ 0
NO
$Comp
L 74xx:74LS377 U1
U 1 1 6020130F
P 2900 1500
F 0 "U1" H 2900 2481 50  0000 C CNN
F 1 "74LS377" H 2900 2390 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 2900 1500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 2900 1500 50  0001 C CNN
	1    2900 1500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS377 U2
U 1 1 60201DB2
P 2900 5400
F 0 "U2" H 2900 6381 50  0000 C CNN
F 1 "74LS377" H 2900 6290 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 2900 5400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 2900 5400 50  0001 C CNN
	1    2900 5400
	1    0    0    -1  
$EndComp
Text GLabel 2400 1900 0    50   Input ~ 0
CLK
Text GLabel 2400 5800 0    50   Input ~ 0
CLK
Text GLabel 2400 1000 0    50   Input ~ 0
D0h
$Comp
L Jumper:SolderJumper_3_Bridged12 JP1
U 1 1 60205A69
P 1600 850
F 0 "JP1" V 1646 918 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 918 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 850 50  0001 C CNN
F 3 "~" H 1600 850 50  0001 C CNN
	1    1600 850 
	0    -1   -1   0   
$EndComp
Text GLabel 1600 1050 3    50   Input ~ 0
D0
Text GLabel 1600 650  1    50   Input ~ 0
D8
$Comp
L Jumper:SolderJumper_3_Bridged12 JP2
U 1 1 602077E9
P 1600 1600
F 0 "JP2" V 1646 1668 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 1668 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 1600 50  0001 C CNN
F 3 "~" H 1600 1600 50  0001 C CNN
	1    1600 1600
	0    -1   -1   0   
$EndComp
Text GLabel 1600 1800 3    50   Input ~ 0
D1
Text GLabel 1600 1400 1    50   Input ~ 0
D9
$Comp
L Jumper:SolderJumper_3_Bridged12 JP3
U 1 1 60209259
P 1600 2350
F 0 "JP3" V 1646 2418 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 2418 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 2350 50  0001 C CNN
F 3 "~" H 1600 2350 50  0001 C CNN
	1    1600 2350
	0    -1   -1   0   
$EndComp
Text GLabel 1600 2550 3    50   Input ~ 0
D2
Text GLabel 1600 2150 1    50   Input ~ 0
D10
$Comp
L Jumper:SolderJumper_3_Bridged12 JP4
U 1 1 60209735
P 1600 3100
F 0 "JP4" V 1646 3168 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 3168 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 3100 50  0001 C CNN
F 3 "~" H 1600 3100 50  0001 C CNN
	1    1600 3100
	0    -1   -1   0   
$EndComp
Text GLabel 1600 3300 3    50   Input ~ 0
D3
Text GLabel 1600 2900 1    50   Input ~ 0
D11
Text GLabel 1750 3100 2    50   Output ~ 0
D3h
$Comp
L Jumper:SolderJumper_3_Bridged12 JP5
U 1 1 60209DDB
P 1600 3850
F 0 "JP5" V 1646 3918 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 3918 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 3850 50  0001 C CNN
F 3 "~" H 1600 3850 50  0001 C CNN
	1    1600 3850
	0    -1   -1   0   
$EndComp
Text GLabel 1600 4050 3    50   Input ~ 0
D4
Text GLabel 1600 3650 1    50   Input ~ 0
D12
Text GLabel 1750 3850 2    50   Output ~ 0
D4h
$Comp
L Jumper:SolderJumper_3_Bridged12 JP6
U 1 1 6020AD05
P 1600 4600
F 0 "JP6" V 1646 4668 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 4668 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 4600 50  0001 C CNN
F 3 "~" H 1600 4600 50  0001 C CNN
	1    1600 4600
	0    -1   -1   0   
$EndComp
Text GLabel 1600 4800 3    50   Input ~ 0
D5
Text GLabel 1600 4400 1    50   Input ~ 0
D13
Text GLabel 1750 4600 2    50   Output ~ 0
D5h
$Comp
L Jumper:SolderJumper_3_Bridged12 JP7
U 1 1 6020B219
P 1600 5350
F 0 "JP7" V 1646 5418 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 5418 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 5350 50  0001 C CNN
F 3 "~" H 1600 5350 50  0001 C CNN
	1    1600 5350
	0    -1   -1   0   
$EndComp
Text GLabel 1600 5550 3    50   Input ~ 0
D6
Text GLabel 1600 5150 1    50   Input ~ 0
D14
Text GLabel 1750 5350 2    50   Output ~ 0
D6h
$Comp
L Jumper:SolderJumper_3_Bridged12 JP8
U 1 1 6020B891
P 1600 6100
F 0 "JP8" V 1646 6168 50  0000 L CNN
F 1 "SolderJumper_3_Bridged12" V 1555 6168 50  0000 L CNN
F 2 "Jumper:SolderJumper-3_P1.3mm_Open_Pad1.0x1.5mm" H 1600 6100 50  0001 C CNN
F 3 "~" H 1600 6100 50  0001 C CNN
	1    1600 6100
	0    -1   -1   0   
$EndComp
Text GLabel 1600 6300 3    50   Input ~ 0
D7
Text GLabel 1600 5900 1    50   Input ~ 0
D15
Text GLabel 1750 6100 2    50   Output ~ 0
D7h
Text GLabel 2400 1100 0    50   Input ~ 0
D1h
Text GLabel 2400 1200 0    50   Input ~ 0
D2h
Text GLabel 2400 1300 0    50   Input ~ 0
D3h
Text GLabel 2400 1400 0    50   Input ~ 0
D4h
Text GLabel 2400 1500 0    50   Input ~ 0
D5h
Text GLabel 2400 1600 0    50   Input ~ 0
D6h
Text GLabel 2400 1700 0    50   Input ~ 0
D7h
Text GLabel 2400 2000 0    50   Input ~ 0
~XI~
Text GLabel 3400 1000 2    50   Output ~ 0
X0
Text GLabel 3400 1100 2    50   Output ~ 0
X1
Text GLabel 3400 1200 2    50   Output ~ 0
X2
Text GLabel 3400 1300 2    50   Output ~ 0
X3
Text GLabel 3400 1400 2    50   Output ~ 0
X4
Text GLabel 3400 1500 2    50   Output ~ 0
X5
Text GLabel 3400 1600 2    50   Output ~ 0
X6
Text GLabel 3400 1700 2    50   Output ~ 0
X7
Text GLabel 3400 4900 2    50   Output ~ 0
Y0
Text GLabel 3400 5000 2    50   Output ~ 0
Y1
Text GLabel 3400 5100 2    50   Output ~ 0
Y2
Text GLabel 3400 5200 2    50   Output ~ 0
Y3
Text GLabel 3400 5300 2    50   Output ~ 0
Y4
Text GLabel 3400 5400 2    50   Output ~ 0
Y5
Text GLabel 3400 5500 2    50   Output ~ 0
Y6
Text GLabel 3400 5600 2    50   Output ~ 0
Y7
Text GLabel 2400 5900 0    50   Input ~ 0
~YI~
Text GLabel 2400 4900 0    50   Input ~ 0
D0h
Text GLabel 2400 5000 0    50   Input ~ 0
D1h
Text GLabel 2400 5100 0    50   Input ~ 0
D2h
Text GLabel 2400 5200 0    50   Input ~ 0
D3h
Text GLabel 2400 5300 0    50   Input ~ 0
D4h
Text GLabel 2400 5400 0    50   Input ~ 0
D5h
Text GLabel 2400 5500 0    50   Input ~ 0
D6h
Text GLabel 2400 5600 0    50   Input ~ 0
D7h
Text GLabel 1750 2350 2    50   Output ~ 0
D2h
Text GLabel 1750 1600 2    50   Output ~ 0
D1h
Text GLabel 1750 850  2    50   Output ~ 0
D0h
Text GLabel 10350 3500 0    50   Input ~ 0
Z
$Comp
L Connector:Conn_01x09_Male J2
U 1 1 6023BB30
P 3650 1400
F 0 "J2" H 3758 1981 50  0000 C CNN
F 1 "Conn_01x09_Male" H 3758 1890 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x09_P2.54mm_Vertical" H 3650 1400 50  0001 C CNN
F 3 "~" H 3650 1400 50  0001 C CNN
	1    3650 1400
	1    0    0    -1  
$EndComp
Text GLabel 4150 1000 2    50   Input ~ 0
X0
Text GLabel 4150 1100 2    50   Input ~ 0
X1
Text GLabel 4150 1200 2    50   Input ~ 0
X2
Text GLabel 4150 1300 2    50   Input ~ 0
X3
Text GLabel 4150 1400 2    50   Input ~ 0
X4
Text GLabel 4150 1500 2    50   Input ~ 0
X5
Text GLabel 4150 1600 2    50   Input ~ 0
X6
Text GLabel 4150 1700 2    50   Input ~ 0
X7
Text GLabel 3850 1800 2    50   Input ~ 0
GND
$Comp
L Connector:Conn_01x09_Male J3
U 1 1 60240041
P 3700 3350
F 0 "J3" H 3808 3931 50  0000 C CNN
F 1 "Conn_01x09_Male" H 3808 3840 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x09_P2.54mm_Vertical" H 3700 3350 50  0001 C CNN
F 3 "~" H 3700 3350 50  0001 C CNN
	1    3700 3350
	1    0    0    -1  
$EndComp
Text GLabel 4200 2950 2    50   Input ~ 0
E0
Text GLabel 4200 3050 2    50   Input ~ 0
E1
Text GLabel 4200 3150 2    50   Input ~ 0
E2
Text GLabel 4200 3250 2    50   Input ~ 0
E3
Text GLabel 4200 3350 2    50   Input ~ 0
E4
Text GLabel 4200 3450 2    50   Input ~ 0
E5
Text GLabel 4200 3550 2    50   Input ~ 0
E6
Text GLabel 4200 3650 2    50   Input ~ 0
E7
Text GLabel 3900 3750 2    50   Input ~ 0
GND
$Comp
L 74xx:74LS244 U3
U 1 1 6024A85D
P 2900 3450
F 0 "U3" H 2900 4431 50  0000 C CNN
F 1 "74LS244" H 2900 4340 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 2900 3450 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS244" H 2900 3450 50  0001 C CNN
	1    2900 3450
	1    0    0    -1  
$EndComp
Text GLabel 2400 2950 0    50   Input ~ 0
E0
Text GLabel 2400 3050 0    50   Input ~ 0
E1
Text GLabel 2400 3150 0    50   Input ~ 0
E2
Text GLabel 2400 3250 0    50   Input ~ 0
E3
Text GLabel 2400 3350 0    50   Input ~ 0
E4
Text GLabel 2400 3450 0    50   Input ~ 0
E5
Text GLabel 2400 3550 0    50   Input ~ 0
E6
Text GLabel 2400 3650 0    50   Input ~ 0
E7
Text GLabel 3400 2950 2    50   Input ~ 0
D0h
Text GLabel 3400 3050 2    50   Input ~ 0
D1h
Text GLabel 3400 3150 2    50   Input ~ 0
D2h
Text GLabel 3400 3250 2    50   Input ~ 0
D3h
Text GLabel 3400 3350 2    50   Input ~ 0
D4h
Text GLabel 3400 3450 2    50   Input ~ 0
D5h
Text GLabel 3400 3550 2    50   Input ~ 0
D6h
Text GLabel 3400 3650 2    50   Input ~ 0
D7h
Text GLabel 2400 3850 0    50   Input ~ 0
~EO~
Text GLabel 2400 3950 0    50   Input ~ 0
~EO~
$Comp
L Connector:Conn_01x09_Male J4
U 1 1 6027FBDA
P 3650 5300
F 0 "J4" H 3758 5881 50  0000 C CNN
F 1 "Conn_01x09_Male" H 3758 5790 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x09_P2.54mm_Vertical" H 3650 5300 50  0001 C CNN
F 3 "~" H 3650 5300 50  0001 C CNN
	1    3650 5300
	1    0    0    -1  
$EndComp
Text GLabel 4150 4900 2    50   Input ~ 0
Y0
Text GLabel 4150 5000 2    50   Input ~ 0
Y1
Text GLabel 4150 5100 2    50   Input ~ 0
Y2
Text GLabel 4150 5200 2    50   Input ~ 0
Y3
Text GLabel 4150 5300 2    50   Input ~ 0
Y4
Text GLabel 4150 5400 2    50   Input ~ 0
Y5
Text GLabel 4150 5500 2    50   Input ~ 0
Y6
Text GLabel 4150 5600 2    50   Input ~ 0
Y7
Text GLabel 3850 5700 2    50   Input ~ 0
GND
NoConn ~ 10350 4500
NoConn ~ 10850 4700
NoConn ~ 10850 4600
NoConn ~ 10850 4500
NoConn ~ 10850 4400
NoConn ~ 10850 4300
NoConn ~ 10850 4200
NoConn ~ 10850 4100
Text GLabel 2900 700  0    50   Input ~ 0
VCC
Text GLabel 2900 2300 0    50   Input ~ 0
GND
Text GLabel 2900 2650 0    50   Input ~ 0
VCC
Text GLabel 2900 4250 0    50   Input ~ 0
GND
Text GLabel 2900 4600 0    50   Input ~ 0
VCC
Text GLabel 2900 6200 0    50   Input ~ 0
GND
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 602913A3
P 10150 850
F 0 "#FLG0101" H 10150 925 50  0001 C CNN
F 1 "PWR_FLAG" H 10150 1023 50  0000 C CNN
F 2 "" H 10150 850 50  0001 C CNN
F 3 "~" H 10150 850 50  0001 C CNN
	1    10150 850 
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 602918D6
P 10550 850
F 0 "#FLG0102" H 10550 925 50  0001 C CNN
F 1 "PWR_FLAG" H 10550 1023 50  0000 C CNN
F 2 "" H 10550 850 50  0001 C CNN
F 3 "~" H 10550 850 50  0001 C CNN
	1    10550 850 
	1    0    0    -1  
$EndComp
Text GLabel 10150 850  0    50   Input ~ 0
VCC
Text GLabel 10550 850  0    50   Input ~ 0
GND
$Comp
L Device:C C1
U 1 1 60294B7C
P 1950 1250
F 0 "C1" H 2065 1296 50  0000 L CNN
F 1 "C" H 2065 1205 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 1988 1100 50  0001 C CNN
F 3 "~" H 1950 1250 50  0001 C CNN
	1    1950 1250
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 602951C7
P 2000 3350
F 0 "C3" H 2115 3396 50  0000 L CNN
F 1 "C" H 2115 3305 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 2038 3200 50  0001 C CNN
F 3 "~" H 2000 3350 50  0001 C CNN
	1    2000 3350
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 60296EBA
P 1950 5100
F 0 "C2" H 2065 5146 50  0000 L CNN
F 1 "C" H 2065 5055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 1988 4950 50  0001 C CNN
F 3 "~" H 1950 5100 50  0001 C CNN
	1    1950 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1950 4950 1950 4600
Wire Wire Line
	1950 4600 2900 4600
Wire Wire Line
	1950 5250 1950 6200
Wire Wire Line
	1950 6200 2900 6200
Wire Wire Line
	2000 3500 2000 4250
Wire Wire Line
	2000 4250 2900 4250
Wire Wire Line
	2000 3200 2000 2650
Wire Wire Line
	2000 2650 2900 2650
Wire Wire Line
	1950 1100 1950 700 
Wire Wire Line
	1950 700  2900 700 
Wire Wire Line
	1950 1400 1950 2300
Wire Wire Line
	1950 2300 2900 2300
$Comp
L 74xx:74LS377 U4
U 1 1 6029BB2B
P 9200 1750
F 0 "U4" H 9200 2731 50  0000 C CNN
F 1 "74LS377" H 9200 2640 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 9200 1750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 9200 1750 50  0001 C CNN
	1    9200 1750
	1    0    0    -1  
$EndComp
Text GLabel 9200 950  0    50   Input ~ 0
VCC
Text GLabel 9200 2550 0    50   Input ~ 0
GND
Text GLabel 8700 1250 0    50   Input ~ 0
Z_new
Text GLabel 8700 1350 0    50   Input ~ 0
E7
Text GLabel 8700 2250 0    50   Input ~ 0
~EO~
Text GLabel 8700 2150 0    50   Input ~ 0
CLK
NoConn ~ 8700 1450
NoConn ~ 8700 1550
NoConn ~ 8700 1650
NoConn ~ 8700 1750
NoConn ~ 8700 1850
NoConn ~ 8700 1950
NoConn ~ 9700 1450
NoConn ~ 9700 1550
NoConn ~ 9700 1650
NoConn ~ 9700 1750
NoConn ~ 9700 1850
NoConn ~ 9700 1950
Text GLabel 9700 1250 2    50   Input ~ 0
Z
Text GLabel 9700 1350 2    50   Input ~ 0
LT
$Comp
L Device:C C4
U 1 1 602A43B9
P 8150 1600
F 0 "C4" H 8265 1646 50  0000 L CNN
F 1 "C" H 8265 1555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 8188 1450 50  0001 C CNN
F 3 "~" H 8150 1600 50  0001 C CNN
	1    8150 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	8150 1450 8150 950 
Wire Wire Line
	8150 950  9200 950 
Wire Wire Line
	8150 1750 8150 2550
Wire Wire Line
	8150 2550 9200 2550
$Comp
L Connector:Conn_01x03_Male J5
U 1 1 602A710B
P 9950 1350
F 0 "J5" H 10058 1631 50  0000 C CNN
F 1 "Conn_01x03_Male" H 10058 1540 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 9950 1350 50  0001 C CNN
F 3 "~" H 9950 1350 50  0001 C CNN
	1    9950 1350
	1    0    0    -1  
$EndComp
Text GLabel 10450 1250 2    50   Input ~ 0
Z
Text GLabel 10450 1350 2    50   Input ~ 0
LT
Text GLabel 10150 1450 2    50   Input ~ 0
GND
$Comp
L 74xx:74LS32 U5
U 1 1 602AE7BE
P 6400 4050
F 0 "U5" H 6400 4375 50  0000 C CNN
F 1 "74LS32" H 6400 4284 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 6400 4050 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 6400 4050 50  0001 C CNN
	1    6400 4050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U5
U 5 1 602B5C5C
P 4150 7100
F 0 "U5" H 4380 7146 50  0000 L CNN
F 1 "74LS32" H 4380 7055 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4150 7100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4150 7100 50  0001 C CNN
	5    4150 7100
	1    0    0    -1  
$EndComp
Text GLabel 8750 3800 0    50   Input ~ 0
nz1
Text GLabel 8750 4000 0    50   Input ~ 0
nz2
$Comp
L 74xx:74LS02 U6
U 1 1 602D21BF
P 9050 3900
F 0 "U6" H 9050 4225 50  0000 C CNN
F 1 "74LS02" H 9050 4134 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 9050 3900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls02" H 9050 3900 50  0001 C CNN
	1    9050 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U6
U 5 1 602D3554
P 5300 7100
F 0 "U6" H 5530 7146 50  0000 L CNN
F 1 "74LS02" H 5530 7055 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5300 7100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls02" H 5300 7100 50  0001 C CNN
	5    5300 7100
	1    0    0    -1  
$EndComp
Text GLabel 9350 3900 2    50   Input ~ 0
Z_new
Text GLabel 5300 6600 2    50   Input ~ 0
VCC
Text GLabel 5300 7600 2    50   Input ~ 0
GND
Text GLabel 4150 6600 2    50   Input ~ 0
VCC
Text GLabel 4150 7600 2    50   Input ~ 0
GND
$Comp
L Device:C C5
U 1 1 602EB31A
P 3700 7100
F 0 "C5" H 3815 7146 50  0000 L CNN
F 1 "C" H 3815 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 3738 6950 50  0001 C CNN
F 3 "~" H 3700 7100 50  0001 C CNN
	1    3700 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C6
U 1 1 602EC0FA
P 4850 7100
F 0 "C6" H 4965 7146 50  0000 L CNN
F 1 "C" H 4965 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 4888 6950 50  0001 C CNN
F 3 "~" H 4850 7100 50  0001 C CNN
	1    4850 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 6600 3700 6600
Wire Wire Line
	3700 6600 3700 6950
Wire Wire Line
	3700 7250 3700 7600
Wire Wire Line
	3700 7600 4150 7600
Wire Wire Line
	4850 7250 4850 7600
Wire Wire Line
	4850 7600 5300 7600
Wire Wire Line
	4850 6950 4850 6600
Wire Wire Line
	4850 6600 5300 6600
$Sheet
S 4850 900  850  1400
U 60339557
F0 "alulow" 50
F1 "alu4.sch" 50
F2 "X0" I L 4850 1000 50 
F3 "X1" I L 4850 1100 50 
F4 "X2" I L 4850 1200 50 
F5 "X3" I L 4850 1300 50 
F6 "Y0" I L 4850 1450 50 
F7 "Y1" I L 4850 1550 50 
F8 "Y2" I L 4850 1650 50 
F9 "Y3" I L 4850 1750 50 
F10 "C_in" I L 4850 1900 50 
F11 "C_out" I R 5700 1900 50 
F12 "E0" I R 5700 1250 50 
F13 "E1" I R 5700 1350 50 
F14 "E2" I R 5700 1450 50 
F15 "E3" I R 5700 1550 50 
$EndSheet
Text GLabel 4850 1000 0    50   Input ~ 0
X0
Text GLabel 4850 1100 0    50   Input ~ 0
X1
Text GLabel 4850 1200 0    50   Input ~ 0
X2
Text GLabel 4850 1300 0    50   Input ~ 0
X3
Text GLabel 4850 1450 0    50   Input ~ 0
Y0
Text GLabel 4850 1550 0    50   Input ~ 0
Y1
Text GLabel 4850 1650 0    50   Input ~ 0
Y2
Text GLabel 4850 1750 0    50   Input ~ 0
Y3
Text GLabel 4850 1900 0    50   Input ~ 0
carry_in
Text GLabel 5700 1250 2    50   Input ~ 0
E0
Text GLabel 5700 1350 2    50   Input ~ 0
E1
Text GLabel 5700 1450 2    50   Input ~ 0
E2
Text GLabel 5700 1550 2    50   Input ~ 0
E3
$Sheet
S 6400 900  850  1400
U 604E3030
F0 "aluhigh" 50
F1 "alu4.sch" 50
F2 "X0" I L 6400 1000 50 
F3 "X1" I L 6400 1100 50 
F4 "X2" I L 6400 1200 50 
F5 "X3" I L 6400 1300 50 
F6 "Y0" I L 6400 1450 50 
F7 "Y1" I L 6400 1550 50 
F8 "Y2" I L 6400 1650 50 
F9 "Y3" I L 6400 1750 50 
F10 "C_in" I L 6400 1900 50 
F11 "C_out" I R 7250 1900 50 
F12 "E0" I R 7250 1250 50 
F13 "E1" I R 7250 1350 50 
F14 "E2" I R 7250 1450 50 
F15 "E3" I R 7250 1550 50 
$EndSheet
Text GLabel 6400 1000 0    50   Input ~ 0
X4
Text GLabel 6400 1100 0    50   Input ~ 0
X5
Text GLabel 6400 1200 0    50   Input ~ 0
X6
Text GLabel 6400 1300 0    50   Input ~ 0
X7
Text GLabel 6400 1450 0    50   Input ~ 0
Y4
Text GLabel 6400 1550 0    50   Input ~ 0
Y5
Text GLabel 6400 1650 0    50   Input ~ 0
Y6
Text GLabel 6400 1750 0    50   Input ~ 0
Y7
Text GLabel 7250 1250 2    50   Input ~ 0
E4
Text GLabel 7250 1350 2    50   Input ~ 0
E5
Text GLabel 7250 1450 2    50   Input ~ 0
E6
Text GLabel 7250 1550 2    50   Input ~ 0
E7
Text GLabel 7250 1900 2    50   Input ~ 0
carry_out
Wire Wire Line
	5700 1900 6400 1900
$Comp
L 74xx:74LS32 U10
U 3 1 6058C183
P 5200 3250
F 0 "U10" H 5200 3575 50  0000 C CNN
F 1 "74LS32" H 5200 3484 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5200 3250 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5200 3250 50  0001 C CNN
	3    5200 3250
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U10
U 4 1 6058DD23
P 5200 3800
F 0 "U10" H 5200 4125 50  0000 C CNN
F 1 "74LS32" H 5200 4034 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5200 3800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5200 3800 50  0001 C CNN
	4    5200 3800
	1    0    0    -1  
$EndComp
Text GLabel 4900 3150 0    50   Input ~ 0
E0
Text GLabel 4900 3350 0    50   Input ~ 0
E1
Text GLabel 4900 3700 0    50   Input ~ 0
E2
Text GLabel 4900 3900 0    50   Input ~ 0
E3
$Comp
L 74xx:74LS32 U10
U 1 1 605A19CA
P 5200 4350
F 0 "U10" H 5200 4675 50  0000 C CNN
F 1 "74LS32" H 5200 4584 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5200 4350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5200 4350 50  0001 C CNN
	1    5200 4350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U10
U 2 1 605A9F48
P 5200 4900
F 0 "U10" H 5200 5225 50  0000 C CNN
F 1 "74LS32" H 5200 5134 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5200 4900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5200 4900 50  0001 C CNN
	2    5200 4900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U5
U 3 1 605AB958
P 5800 3500
F 0 "U5" H 5800 3825 50  0000 C CNN
F 1 "74LS32" H 5800 3734 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5800 3500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5800 3500 50  0001 C CNN
	3    5800 3500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U5
U 4 1 605ADA33
P 5800 4600
F 0 "U5" H 5800 4925 50  0000 C CNN
F 1 "74LS32" H 5800 4834 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 5800 4600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 5800 4600 50  0001 C CNN
	4    5800 4600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS32 U10
U 5 1 605B0B18
P 2850 7100
F 0 "U10" H 3080 7146 50  0000 L CNN
F 1 "74LS32" H 3080 7055 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 2850 7100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 2850 7100 50  0001 C CNN
	5    2850 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 3250 5500 3400
Wire Wire Line
	5500 3600 5500 3800
Wire Wire Line
	5500 4350 5500 4500
Wire Wire Line
	5500 4700 5500 4900
Text GLabel 4900 4250 0    50   Input ~ 0
E4
Text GLabel 4900 4450 0    50   Input ~ 0
E5
Text GLabel 4900 4800 0    50   Input ~ 0
E6
Text GLabel 4900 5000 0    50   Input ~ 0
E7
Text GLabel 2850 6600 2    50   Input ~ 0
VCC
Text GLabel 2850 7600 2    50   Input ~ 0
GND
$Comp
L Device:C C7
U 1 1 605CABAE
P 2350 7100
F 0 "C7" H 2465 7146 50  0000 L CNN
F 1 "C" H 2465 7055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 2388 6950 50  0001 C CNN
F 3 "~" H 2350 7100 50  0001 C CNN
	1    2350 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2350 6950 2350 6600
Wire Wire Line
	2350 6600 2850 6600
Wire Wire Line
	2350 7250 2350 7600
Wire Wire Line
	2350 7600 2850 7600
NoConn ~ 10850 1900
NoConn ~ 10850 2000
NoConn ~ 10850 2100
NoConn ~ 10850 2200
NoConn ~ 10850 2300
NoConn ~ 10850 2400
NoConn ~ 10850 2500
NoConn ~ 10850 2600
NoConn ~ 10850 2700
NoConn ~ 10850 2800
NoConn ~ 10850 2900
NoConn ~ 10850 3000
NoConn ~ 10850 3100
NoConn ~ 10850 3200
NoConn ~ 10850 3300
NoConn ~ 10850 3400
NoConn ~ 10350 4600
NoConn ~ 10350 4400
NoConn ~ 10350 4300
NoConn ~ 10350 4200
NoConn ~ 10350 4100
NoConn ~ 10350 4000
Text Label 10850 1900 0    50   ~ 0
A0
Text Label 10850 2000 0    50   ~ 0
A1
Text Label 10850 2100 0    50   ~ 0
A2
Text Label 10850 2200 0    50   ~ 0
A3
Text Label 10850 2300 0    50   ~ 0
A4
Text Label 10850 2400 0    50   ~ 0
A5
Text Label 10850 2500 0    50   ~ 0
A6
Text Label 10850 2600 0    50   ~ 0
A7
Text Label 10850 2700 0    50   ~ 0
A8
Text Label 10850 2800 0    50   ~ 0
A9
Text Label 10850 2900 0    50   ~ 0
A10
Text Label 10850 3000 0    50   ~ 0
A11
Text Label 10850 3100 0    50   ~ 0
A12
Text Label 10850 3200 0    50   ~ 0
A13
Text Label 10850 3300 0    50   ~ 0
A14
Text Label 10850 3400 0    50   ~ 0
A15
Text Label 10350 4000 2    50   ~ 0
~AI~
Text Label 10350 4100 2    50   ~ 0
MO
Text Label 10350 4200 2    50   ~ 0
MI
Text Label 10350 4300 2    50   ~ 0
DO
Text Label 10350 4400 2    50   ~ 0
DI
Text Label 10350 4600 2    50   ~ 0
~RESET~
$Comp
L Connector_Generic:Conn_02x30_Counter_Clockwise J1
U 1 1 601D0516
P 10550 3300
F 0 "J1" H 10600 4917 50  0000 C CNN
F 1 "Conn_02x30_Counter_Clockwise" H 10600 4826 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x30_P2.54mm_Horizontal" H 10550 3300 50  0001 C CNN
F 3 "~" H 10550 3300 50  0001 C CNN
	1    10550 3300
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Male J7
U 1 1 606C3AD6
P 10400 5950
F 0 "J7" H 10508 6131 50  0000 C CNN
F 1 "Conn_01x02_Male" H 10508 6040 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 10400 5950 50  0001 C CNN
F 3 "~" H 10400 5950 50  0001 C CNN
	1    10400 5950
	1    0    0    -1  
$EndComp
Text GLabel 10600 5950 2    50   Input ~ 0
carry_out
Text GLabel 10600 6050 2    50   Input ~ 0
nz1
Wire Wire Line
	6100 3950 6100 3500
Wire Wire Line
	6100 4600 6100 4150
Text GLabel 6700 4050 2    50   Input ~ 0
nz1
Text Notes 7350 7500 0    50   ~ 0
SCAMP ALU Card (8-bit slice)
$Comp
L Device:R R1
U 1 1 6071B6A8
P 4000 1000
F 0 "R1" V 3793 1000 50  0000 C CNN
F 1 "R" V 3884 1000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1000 50  0001 C CNN
F 3 "~" H 4000 1000 50  0001 C CNN
	1    4000 1000
	0    1    1    0   
$EndComp
$Comp
L Device:R R2
U 1 1 6071F3E8
P 4000 1100
F 0 "R2" V 3793 1100 50  0000 C CNN
F 1 "R" V 3884 1100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1100 50  0001 C CNN
F 3 "~" H 4000 1100 50  0001 C CNN
	1    4000 1100
	0    1    1    0   
$EndComp
$Comp
L Device:R R3
U 1 1 6071F5BF
P 4000 1200
F 0 "R3" V 3793 1200 50  0000 C CNN
F 1 "R" V 3884 1200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1200 50  0001 C CNN
F 3 "~" H 4000 1200 50  0001 C CNN
	1    4000 1200
	0    1    1    0   
$EndComp
$Comp
L Device:R R4
U 1 1 6071F7D6
P 4000 1300
F 0 "R4" V 3793 1300 50  0000 C CNN
F 1 "R" V 3884 1300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1300 50  0001 C CNN
F 3 "~" H 4000 1300 50  0001 C CNN
	1    4000 1300
	0    1    1    0   
$EndComp
$Comp
L Device:R R5
U 1 1 6071FAE0
P 4000 1400
F 0 "R5" V 3793 1400 50  0000 C CNN
F 1 "R" V 3884 1400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1400 50  0001 C CNN
F 3 "~" H 4000 1400 50  0001 C CNN
	1    4000 1400
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 6071FCC7
P 4000 1500
F 0 "R6" V 3793 1500 50  0000 C CNN
F 1 "R" V 3884 1500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1500 50  0001 C CNN
F 3 "~" H 4000 1500 50  0001 C CNN
	1    4000 1500
	0    1    1    0   
$EndComp
$Comp
L Device:R R7
U 1 1 6071FEDE
P 4000 1600
F 0 "R7" V 3793 1600 50  0000 C CNN
F 1 "R" V 3884 1600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1600 50  0001 C CNN
F 3 "~" H 4000 1600 50  0001 C CNN
	1    4000 1600
	0    1    1    0   
$EndComp
$Comp
L Device:R R8
U 1 1 60720145
P 4000 1700
F 0 "R8" V 3793 1700 50  0000 C CNN
F 1 "R" V 3884 1700 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 1700 50  0001 C CNN
F 3 "~" H 4000 1700 50  0001 C CNN
	1    4000 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R R19
U 1 1 60729159
P 4050 2950
F 0 "R19" V 3843 2950 50  0000 C CNN
F 1 "R" V 3934 2950 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 2950 50  0001 C CNN
F 3 "~" H 4050 2950 50  0001 C CNN
	1    4050 2950
	0    1    1    0   
$EndComp
$Comp
L Device:R R20
U 1 1 6072CE8B
P 4050 3050
F 0 "R20" V 3843 3050 50  0000 C CNN
F 1 "R" V 3934 3050 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3050 50  0001 C CNN
F 3 "~" H 4050 3050 50  0001 C CNN
	1    4050 3050
	0    1    1    0   
$EndComp
$Comp
L Device:R R21
U 1 1 6072D5B3
P 4050 3150
F 0 "R21" V 3843 3150 50  0000 C CNN
F 1 "R" V 3934 3150 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3150 50  0001 C CNN
F 3 "~" H 4050 3150 50  0001 C CNN
	1    4050 3150
	0    1    1    0   
$EndComp
$Comp
L Device:R R22
U 1 1 6072DCB8
P 4050 3250
F 0 "R22" V 3843 3250 50  0000 C CNN
F 1 "R" V 3934 3250 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3250 50  0001 C CNN
F 3 "~" H 4050 3250 50  0001 C CNN
	1    4050 3250
	0    1    1    0   
$EndComp
$Comp
L Device:R R23
U 1 1 6072E3C9
P 4050 3350
F 0 "R23" V 3843 3350 50  0000 C CNN
F 1 "R" V 3934 3350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3350 50  0001 C CNN
F 3 "~" H 4050 3350 50  0001 C CNN
	1    4050 3350
	0    1    1    0   
$EndComp
$Comp
L Device:R R24
U 1 1 6072EAE6
P 4050 3450
F 0 "R24" V 3843 3450 50  0000 C CNN
F 1 "R" V 3934 3450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3450 50  0001 C CNN
F 3 "~" H 4050 3450 50  0001 C CNN
	1    4050 3450
	0    1    1    0   
$EndComp
$Comp
L Device:R R25
U 1 1 6072F277
P 4050 3550
F 0 "R25" V 3843 3550 50  0000 C CNN
F 1 "R" V 3934 3550 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3550 50  0001 C CNN
F 3 "~" H 4050 3550 50  0001 C CNN
	1    4050 3550
	0    1    1    0   
$EndComp
$Comp
L Device:R R26
U 1 1 6072F99C
P 4050 3650
F 0 "R26" V 3843 3650 50  0000 C CNN
F 1 "R" V 3934 3650 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3980 3650 50  0001 C CNN
F 3 "~" H 4050 3650 50  0001 C CNN
	1    4050 3650
	0    1    1    0   
$EndComp
$Comp
L Device:R R10
U 1 1 607363FD
P 4000 4900
F 0 "R10" V 3793 4900 50  0000 C CNN
F 1 "R" V 3884 4900 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 4900 50  0001 C CNN
F 3 "~" H 4000 4900 50  0001 C CNN
	1    4000 4900
	0    1    1    0   
$EndComp
$Comp
L Device:R R11
U 1 1 60742639
P 4000 5000
F 0 "R11" V 3793 5000 50  0000 C CNN
F 1 "R" V 3884 5000 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5000 50  0001 C CNN
F 3 "~" H 4000 5000 50  0001 C CNN
	1    4000 5000
	0    1    1    0   
$EndComp
$Comp
L Device:R R12
U 1 1 60742E47
P 4000 5100
F 0 "R12" V 3793 5100 50  0000 C CNN
F 1 "R" V 3884 5100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5100 50  0001 C CNN
F 3 "~" H 4000 5100 50  0001 C CNN
	1    4000 5100
	0    1    1    0   
$EndComp
$Comp
L Device:R R13
U 1 1 6074368B
P 4000 5200
F 0 "R13" V 3793 5200 50  0000 C CNN
F 1 "R" V 3884 5200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5200 50  0001 C CNN
F 3 "~" H 4000 5200 50  0001 C CNN
	1    4000 5200
	0    1    1    0   
$EndComp
$Comp
L Device:R R14
U 1 1 60743EDB
P 4000 5300
F 0 "R14" V 3793 5300 50  0000 C CNN
F 1 "R" V 3884 5300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5300 50  0001 C CNN
F 3 "~" H 4000 5300 50  0001 C CNN
	1    4000 5300
	0    1    1    0   
$EndComp
$Comp
L Device:R R15
U 1 1 60744746
P 4000 5400
F 0 "R15" V 3793 5400 50  0000 C CNN
F 1 "R" V 3884 5400 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5400 50  0001 C CNN
F 3 "~" H 4000 5400 50  0001 C CNN
	1    4000 5400
	0    1    1    0   
$EndComp
$Comp
L Device:R R16
U 1 1 60744F99
P 4000 5500
F 0 "R16" V 3793 5500 50  0000 C CNN
F 1 "R" V 3884 5500 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5500 50  0001 C CNN
F 3 "~" H 4000 5500 50  0001 C CNN
	1    4000 5500
	0    1    1    0   
$EndComp
$Comp
L Device:R R17
U 1 1 60745870
P 4000 5600
F 0 "R17" V 3793 5600 50  0000 C CNN
F 1 "R" V 3884 5600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3930 5600 50  0001 C CNN
F 3 "~" H 4000 5600 50  0001 C CNN
	1    4000 5600
	0    1    1    0   
$EndComp
$Comp
L Device:R R28
U 1 1 607516D6
P 10300 1250
F 0 "R28" V 10093 1250 50  0000 C CNN
F 1 "R" V 10184 1250 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10230 1250 50  0001 C CNN
F 3 "~" H 10300 1250 50  0001 C CNN
	1    10300 1250
	0    1    1    0   
$EndComp
$Comp
L Device:R R29
U 1 1 60751A21
P 10300 1350
F 0 "R29" V 10093 1350 50  0000 C CNN
F 1 "R" V 10184 1350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 10230 1350 50  0001 C CNN
F 3 "~" H 10300 1350 50  0001 C CNN
	1    10300 1350
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x03_Male J6
U 1 1 6075CB35
P 8950 5850
F 0 "J6" H 9058 6131 50  0000 C CNN
F 1 "Conn_01x03_Male" H 9058 6040 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 8950 5850 50  0001 C CNN
F 3 "~" H 8950 5850 50  0001 C CNN
	1    8950 5850
	1    0    0    -1  
$EndComp
Text GLabel 9150 5850 2    50   Input ~ 0
carry_in
Text GLabel 9150 5750 2    50   Input ~ 0
GND
Text GLabel 9150 5950 2    50   Input ~ 0
nz2
Text Notes 7000 7000 0    50   ~ 0
Primary card: Connect solder jumpers to upper 8 bits of bus. Connect carry_in,nz2 via wire to\ncarry_out,nz1 of other card. Don't connect carry_out,nz1.\n\nSecondary card: Connect solder jumpers to lower 8 bits of bus. Connect carry_in to GND via jumper.\nConnect nz1,carry_out to nz2,carry_in of other card via wire. Don't populate U4,U6.
$EndSCHEMATC
