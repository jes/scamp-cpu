EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 3
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74xx:74LS244 U18
U 1 1 609FB21F
P 1950 2100
F 0 "U18" H 1950 3081 50  0000 C CNN
F 1 "74LS244" H 1950 2990 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 1950 2100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS244" H 1950 2100 50  0001 C CNN
	1    1950 2100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244 U20
U 1 1 609FB56E
P 3400 2100
F 0 "U20" H 3400 3081 50  0000 C CNN
F 1 "74LS244" H 3400 2990 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 3400 2100 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS244" H 3400 2100 50  0001 C CNN
	1    3400 2100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244 U19
U 1 1 609FBA7A
P 1950 4250
F 0 "U19" H 1950 5231 50  0000 C CNN
F 1 "74LS244" H 1950 5140 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 1950 4250 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS244" H 1950 4250 50  0001 C CNN
	1    1950 4250
	1    0    0    -1  
$EndComp
Text GLabel 1450 2500 0    50   Input ~ 0
~IOL~
Text GLabel 1450 2600 0    50   Input ~ 0
~IOL~
Text GLabel 2900 2500 0    50   Input ~ 0
~IOH~
Text GLabel 2900 2600 0    50   Input ~ 0
~IOH~
Text GLabel 1450 4650 0    50   Input ~ 0
~IOLH~
Text GLabel 1450 4750 0    50   Input ~ 0
~IOLH~
$Comp
L 74xx:74LS00 U17
U 1 1 60A0009B
P 4200 5350
F 0 "U17" H 4200 5675 50  0000 C CNN
F 1 "74LS00" H 4200 5584 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 5350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 4200 5350 50  0001 C CNN
	1    4200 5350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U17
U 2 1 60A01042
P 4200 5900
F 0 "U17" H 4200 6225 50  0000 C CNN
F 1 "74LS00" H 4200 6134 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 5900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 4200 5900 50  0001 C CNN
	2    4200 5900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U17
U 3 1 60A01FA6
P 4200 6450
F 0 "U17" H 4200 6775 50  0000 C CNN
F 1 "74LS00" H 4200 6684 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 6450 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 4200 6450 50  0001 C CNN
	3    4200 6450
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U17
U 5 1 60A03780
P 1900 6400
F 0 "U17" H 2130 6446 50  0000 L CNN
F 1 "74LS00" H 2130 6355 50  0000 L CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 1900 6400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 1900 6400 50  0001 C CNN
	5    1900 6400
	1    0    0    -1  
$EndComp
Text GLabel 3900 5250 0    50   Input ~ 0
~IOH~
Text GLabel 4500 5350 2    50   Input ~ 0
~IOLH~
Text GLabel 3900 5450 0    50   Input ~ 0
~IOL~
NoConn ~ 4500 6450
NoConn ~ 3900 6350
NoConn ~ 3900 6550
Text GLabel 1450 3750 0    50   Input ~ 0
I0
Text GLabel 1450 3850 0    50   Input ~ 0
I1
Text GLabel 1450 3950 0    50   Input ~ 0
I2
Text GLabel 1450 4050 0    50   Input ~ 0
I3
Text GLabel 1450 4150 0    50   Input ~ 0
I4
Text GLabel 1450 4250 0    50   Input ~ 0
I5
Text GLabel 1450 4350 0    50   Input ~ 0
I6
Text GLabel 1450 4450 0    50   Input ~ 0
I7
Text GLabel 2450 3750 2    50   Input ~ 0
D0
Text GLabel 2450 3850 2    50   Input ~ 0
D1
Text GLabel 2450 3950 2    50   Input ~ 0
D2
Text GLabel 2450 4050 2    50   Input ~ 0
D3
Text GLabel 2450 4150 2    50   Input ~ 0
D4
Text GLabel 2450 4250 2    50   Input ~ 0
D5
Text GLabel 2450 4350 2    50   Input ~ 0
D6
Text GLabel 2450 4450 2    50   Input ~ 0
D7
Wire Wire Line
	1450 2300 1450 2200
Connection ~ 1450 1700
Wire Wire Line
	1450 1700 1450 1600
Connection ~ 1450 1800
Wire Wire Line
	1450 1800 1450 1700
Connection ~ 1450 1900
Wire Wire Line
	1450 1900 1450 1800
Connection ~ 1450 2000
Wire Wire Line
	1450 2000 1450 1900
Connection ~ 1450 2100
Wire Wire Line
	1450 2100 1450 2000
Connection ~ 1450 2200
Wire Wire Line
	1450 2200 1450 2100
Wire Wire Line
	2900 2300 2900 2200
Connection ~ 2900 1700
Wire Wire Line
	2900 1700 2900 1600
Connection ~ 2900 1800
Wire Wire Line
	2900 1800 2900 1700
Connection ~ 2900 1900
Wire Wire Line
	2900 1900 2900 1800
Connection ~ 2900 2000
Wire Wire Line
	2900 2000 2900 1900
Connection ~ 2900 2100
Wire Wire Line
	2900 2100 2900 2000
Connection ~ 2900 2200
Wire Wire Line
	2900 2200 2900 2100
Text GLabel 3900 1600 2    50   Input ~ 0
D8
Text GLabel 3900 1700 2    50   Input ~ 0
D9
Text GLabel 3900 1800 2    50   Input ~ 0
D10
Text GLabel 3900 1900 2    50   Input ~ 0
D11
Text GLabel 3900 2000 2    50   Input ~ 0
D12
Text GLabel 3900 2100 2    50   Input ~ 0
D13
Text GLabel 3900 2200 2    50   Input ~ 0
D14
Text GLabel 3900 2300 2    50   Input ~ 0
D15
Text GLabel 2450 1600 2    50   Input ~ 0
D8
Text GLabel 2450 1700 2    50   Input ~ 0
D9
Text GLabel 2450 1800 2    50   Input ~ 0
D10
Text GLabel 2450 1900 2    50   Input ~ 0
D11
Text GLabel 2450 2000 2    50   Input ~ 0
D12
Text GLabel 2450 2100 2    50   Input ~ 0
D13
Text GLabel 2450 2200 2    50   Input ~ 0
D14
Text GLabel 2450 2300 2    50   Input ~ 0
D15
Text GLabel 1450 1600 0    50   Input ~ 0
GND
Text GLabel 2900 1600 0    50   Input ~ 0
VCC
$Comp
L Device:C C8
U 1 1 60A14603
P 1000 2100
F 0 "C8" H 1115 2146 50  0000 L CNN
F 1 "C" H 1115 2055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 1038 1950 50  0001 C CNN
F 3 "~" H 1000 2100 50  0001 C CNN
	1    1000 2100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C7
U 1 1 60A14B23
P 700 2100
F 0 "C7" H 815 2146 50  0000 L CNN
F 1 "C" H 815 2055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 738 1950 50  0001 C CNN
F 3 "~" H 700 2100 50  0001 C CNN
	1    700  2100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C9
U 1 1 60A15069
P 1000 4200
F 0 "C9" H 1115 4246 50  0000 L CNN
F 1 "C" H 1115 4155 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 1038 4050 50  0001 C CNN
F 3 "~" H 1000 4200 50  0001 C CNN
	1    1000 4200
	1    0    0    -1  
$EndComp
$Comp
L Device:C C10
U 1 1 60A155D4
P 1350 6300
F 0 "C10" H 1465 6346 50  0000 L CNN
F 1 "C" H 1465 6255 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 1388 6150 50  0001 C CNN
F 3 "~" H 1350 6300 50  0001 C CNN
	1    1350 6300
	1    0    0    -1  
$EndComp
Text GLabel 3400 1300 2    50   Input ~ 0
VCC
Text GLabel 3400 2900 2    50   Input ~ 0
GND
Text GLabel 1950 5050 2    50   Input ~ 0
GND
Text GLabel 1900 6900 2    50   Input ~ 0
GND
Text GLabel 1900 5900 2    50   Input ~ 0
VCC
Text GLabel 1950 3450 2    50   Input ~ 0
VCC
Wire Wire Line
	1000 1950 1000 1300
Wire Wire Line
	1000 1300 1950 1300
Wire Wire Line
	1000 2250 1000 2900
Wire Wire Line
	1950 1300 3400 1300
Connection ~ 1950 1300
Wire Wire Line
	1950 2900 3400 2900
Connection ~ 1950 2900
Wire Wire Line
	700  2250 700  2900
Wire Wire Line
	700  2900 1000 2900
Connection ~ 1000 2900
Wire Wire Line
	1000 2900 1950 2900
Wire Wire Line
	700  1950 700  1300
Wire Wire Line
	700  1300 1000 1300
Connection ~ 1000 1300
Wire Wire Line
	1000 4050 1000 3450
Wire Wire Line
	1000 3450 1950 3450
Wire Wire Line
	1000 4350 1000 5050
Wire Wire Line
	1000 5050 1950 5050
Wire Wire Line
	1350 6150 1350 5900
Wire Wire Line
	1350 5900 1900 5900
Wire Wire Line
	1350 6450 1350 6900
Wire Wire Line
	1350 6900 1900 6900
$Comp
L 74xx:74LS377 U21
U 1 1 60B44843
P 6850 2750
F 0 "U21" H 6850 3731 50  0000 C CNN
F 1 "74LS377" H 6850 3640 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 6850 2750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 6850 2750 50  0001 C CNN
	1    6850 2750
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS377 U22
U 1 1 60B44CA7
P 8500 2750
F 0 "U22" H 8500 3731 50  0000 C CNN
F 1 "74LS377" H 8500 3640 50  0000 C CNN
F 2 "Package_DIP:DIP-20_W7.62mm_Socket" H 8500 2750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS377" H 8500 2750 50  0001 C CNN
	1    8500 2750
	1    0    0    -1  
$EndComp
Text GLabel 6350 2250 0    50   Input ~ 0
D0
Text GLabel 6350 2350 0    50   Input ~ 0
D1
Text GLabel 6350 2450 0    50   Input ~ 0
D2
Text GLabel 6350 2550 0    50   Input ~ 0
D3
Text GLabel 6350 2650 0    50   Input ~ 0
D4
Text GLabel 6350 2750 0    50   Input ~ 0
D5
Text GLabel 6350 2850 0    50   Input ~ 0
D6
Text GLabel 6350 2950 0    50   Input ~ 0
D7
Text GLabel 6350 3150 0    50   Input ~ 0
CLK
Text GLabel 6350 3250 0    50   Input ~ 0
~II~
Text GLabel 7350 2250 2    50   Input ~ 0
I0
Text GLabel 7350 2350 2    50   Input ~ 0
I1
Text GLabel 7350 2450 2    50   Input ~ 0
I2
Text GLabel 7350 2550 2    50   Input ~ 0
I3
Text GLabel 7350 2650 2    50   Input ~ 0
I4
Text GLabel 7350 2750 2    50   Input ~ 0
I5
Text GLabel 7350 2850 2    50   Input ~ 0
I6
Text GLabel 7350 2950 2    50   Input ~ 0
I7
Text GLabel 8000 2250 0    50   Input ~ 0
D8
Text GLabel 8000 2350 0    50   Input ~ 0
D9
Text GLabel 8000 2450 0    50   Input ~ 0
D10
Text GLabel 8000 2550 0    50   Input ~ 0
D11
Text GLabel 8000 2650 0    50   Input ~ 0
D12
Text GLabel 8000 2750 0    50   Input ~ 0
D13
Text GLabel 8000 2850 0    50   Input ~ 0
D14
Text GLabel 8000 2950 0    50   Input ~ 0
D15
Text GLabel 9000 2250 2    50   Input ~ 0
I8
Text GLabel 9000 2350 2    50   Input ~ 0
I9
Text GLabel 9000 2450 2    50   Input ~ 0
I10
Text GLabel 9000 2550 2    50   Input ~ 0
I11
Text GLabel 9000 2650 2    50   Input ~ 0
I12
Text GLabel 9000 2750 2    50   Input ~ 0
I13
Text GLabel 9000 2850 2    50   Input ~ 0
I14
Text GLabel 9000 2950 2    50   Input ~ 0
I15
Text GLabel 8000 3150 0    50   Input ~ 0
CLK
Text GLabel 8000 3250 0    50   Input ~ 0
~II~
$Comp
L Device:C C22
U 1 1 60B4DAE3
P 6000 2650
F 0 "C22" H 6115 2696 50  0000 L CNN
F 1 "C" H 6115 2605 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 6038 2500 50  0001 C CNN
F 3 "~" H 6000 2650 50  0001 C CNN
	1    6000 2650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C21
U 1 1 60B4DCA1
P 5700 2650
F 0 "C21" H 5815 2696 50  0000 L CNN
F 1 "C" H 5815 2605 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 5738 2500 50  0001 C CNN
F 3 "~" H 5700 2650 50  0001 C CNN
	1    5700 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6000 2500 6000 1950
Wire Wire Line
	6000 1950 6850 1950
Connection ~ 6850 1950
Wire Wire Line
	6850 1950 8500 1950
Wire Wire Line
	5700 2500 5700 1950
Wire Wire Line
	5700 1950 6000 1950
Connection ~ 6000 1950
Wire Wire Line
	6000 2800 6000 3550
Connection ~ 6850 3550
Wire Wire Line
	6850 3550 8500 3550
Wire Wire Line
	5700 2800 5700 3550
Wire Wire Line
	5700 3550 6000 3550
Connection ~ 6000 3550
Wire Wire Line
	6000 3550 6850 3550
Text GLabel 8500 1950 2    50   Input ~ 0
VCC
Text GLabel 8500 3550 2    50   Input ~ 0
GND
Text GLabel 3900 5800 0    50   Input ~ 0
PP
Text GLabel 3900 6000 0    50   Input ~ 0
PP
Text GLabel 4500 5900 2    50   Input ~ 0
inv_PP
$Comp
L 74xx:74LS00 U17
U 4 1 60F21E94
P 4200 7000
F 0 "U17" H 4200 7325 50  0000 C CNN
F 1 "74LS00" H 4200 7234 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_Socket" H 4200 7000 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74ls00" H 4200 7000 50  0001 C CNN
	4    4200 7000
	1    0    0    -1  
$EndComp
NoConn ~ 3900 6900
NoConn ~ 3900 7100
NoConn ~ 4500 7000
$EndSCHEMATC
