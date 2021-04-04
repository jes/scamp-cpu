EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 5
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 5250 2900 0    50   Input ~ 0
CS0
Text HLabel 5250 3000 0    50   Input ~ 0
CS1
Text HLabel 5250 3100 0    50   Input ~ 0
~CS2
$Comp
L Interface_UART:8250 U3
U 1 1 606CBB55
P 6250 3100
AR Path="/6069F7D6/606CBB55" Ref="U3"  Part="1" 
AR Path="/606BA90E/606CBB55" Ref="U4"  Part="1" 
AR Path="/606BAC52/606CBB55" Ref="U5"  Part="1" 
AR Path="/606BAF9A/606CBB55" Ref="U6"  Part="1" 
F 0 "U3" H 6250 4981 50  0000 C CNN
F 1 "8250" H 6250 4890 50  0000 C CNN
F 2 "Package_DIP:DIP-40_W15.24mm" H 6250 3100 50  0001 C CIN
F 3 "" H 6250 3100 50  0001 C CNN
	1    6250 3100
	1    0    0    -1  
$EndComp
Text GLabel 5250 1700 0    50   Input ~ 0
D0
Text GLabel 5250 1800 0    50   Input ~ 0
D1
Text GLabel 5250 1900 0    50   Input ~ 0
D2
Text GLabel 5250 2000 0    50   Input ~ 0
D3
Text GLabel 5250 2100 0    50   Input ~ 0
D4
Text GLabel 5250 2200 0    50   Input ~ 0
D5
Text GLabel 5250 2300 0    50   Input ~ 0
D6
Text GLabel 5250 2400 0    50   Input ~ 0
D7
Text GLabel 5250 2600 0    50   Input ~ 0
A0
Text GLabel 5250 2700 0    50   Input ~ 0
A1
Text GLabel 5250 2800 0    50   Input ~ 0
A2
Text GLabel 5250 3900 0    50   Input ~ 0
VCC
Text GLabel 5250 4200 0    50   Input ~ 0
VCC
Text GLabel 5250 4000 0    50   Input ~ 0
WR
Text GLabel 5250 4100 0    50   Input ~ 0
DO
Text GLabel 5250 4300 0    50   Input ~ 0
GND
NoConn ~ 5250 4400
Text GLabel 5250 4500 0    50   Input ~ 0
inv_~RESET
Text GLabel 6250 4800 0    50   Input ~ 0
GND
Wire Wire Line
	7250 4300 7250 4500
NoConn ~ 7250 3800
NoConn ~ 7250 3900
NoConn ~ 7250 2500
NoConn ~ 7250 2800
$Comp
L Connector:Conn_01x06_Male J2
U 1 1 606D2EED
P 9900 2150
AR Path="/6069F7D6/606D2EED" Ref="J2"  Part="1" 
AR Path="/606BA90E/606D2EED" Ref="J3"  Part="1" 
AR Path="/606BAC52/606D2EED" Ref="J4"  Part="1" 
AR Path="/606BAF9A/606D2EED" Ref="J5"  Part="1" 
F 0 "J2" H 9872 2124 50  0000 R CNN
F 1 "Conn_01x06_Male" H 9872 2033 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 9900 2150 50  0001 C CNN
F 3 "~" H 9900 2150 50  0001 C CNN
	1    9900 2150
	-1   0    0    -1  
$EndComp
Text GLabel 9700 1950 0    50   Input ~ 0
GND
Text GLabel 9500 2150 0    50   Input ~ 0
VCC
NoConn ~ 7250 2000
NoConn ~ 7250 2100
NoConn ~ 7250 2600
NoConn ~ 7250 1900
Text GLabel 6250 1400 0    50   Input ~ 0
VCC
$Comp
L Jumper:SolderJumper_2_Open JP1
U 1 1 606D4F71
P 2200 3150
AR Path="/6069F7D6/606D4F71" Ref="JP1"  Part="1" 
AR Path="/606BA90E/606D4F71" Ref="JP2"  Part="1" 
AR Path="/606BAC52/606D4F71" Ref="JP3"  Part="1" 
AR Path="/606BAF9A/606D4F71" Ref="JP4"  Part="1" 
F 0 "JP1" V 2154 3218 50  0000 L CNN
F 1 "SolderJumper_2_Open" V 2245 3218 50  0000 L CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_TrianglePad1.0x1.5mm" H 2200 3150 50  0001 C CNN
F 3 "~" H 2200 3150 50  0001 C CNN
	1    2200 3150
	0    1    1    0   
$EndComp
Wire Wire Line
	2200 3300 2400 3300
Text GLabel 2200 3000 0    50   Input ~ 0
SHAREDXIN
$Comp
L Device:C C1
U 1 1 606D6D88
P 2050 3300
AR Path="/6069F7D6/606D6D88" Ref="C1"  Part="1" 
AR Path="/606BA90E/606D6D88" Ref="C3"  Part="1" 
AR Path="/606BAC52/606D6D88" Ref="C5"  Part="1" 
AR Path="/606BAF9A/606D6D88" Ref="C7"  Part="1" 
F 0 "C1" V 1798 3300 50  0000 C CNN
F 1 "C" V 1889 3300 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 2088 3150 50  0001 C CNN
F 3 "~" H 2050 3300 50  0001 C CNN
	1    2050 3300
	0    1    1    0   
$EndComp
Connection ~ 2200 3300
Text GLabel 1900 3300 0    50   Input ~ 0
GND
$Comp
L Device:Crystal Y1
U 1 1 606D73BF
P 2400 3450
AR Path="/6069F7D6/606D73BF" Ref="Y1"  Part="1" 
AR Path="/606BA90E/606D73BF" Ref="Y2"  Part="1" 
AR Path="/606BAC52/606D73BF" Ref="Y3"  Part="1" 
AR Path="/606BAF9A/606D73BF" Ref="Y4"  Part="1" 
F 0 "Y1" V 2354 3581 50  0000 L CNN
F 1 "Crystal" V 2445 3581 50  0000 L CNN
F 2 "Crystal:Crystal_HC49-U_Vertical" H 2400 3450 50  0001 C CNN
F 3 "~" H 2400 3450 50  0001 C CNN
	1    2400 3450
	0    1    1    0   
$EndComp
Connection ~ 2400 3300
Wire Wire Line
	2400 3300 5250 3300
$Comp
L Device:C C2
U 1 1 606D7C45
P 2050 3600
AR Path="/6069F7D6/606D7C45" Ref="C2"  Part="1" 
AR Path="/606BA90E/606D7C45" Ref="C4"  Part="1" 
AR Path="/606BAC52/606D7C45" Ref="C6"  Part="1" 
AR Path="/606BAF9A/606D7C45" Ref="C8"  Part="1" 
F 0 "C2" V 1798 3600 50  0000 C CNN
F 1 "C" V 1889 3600 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 2088 3450 50  0001 C CNN
F 3 "~" H 2050 3600 50  0001 C CNN
	1    2050 3600
	0    1    1    0   
$EndComp
Wire Wire Line
	2200 3600 2400 3600
Text GLabel 1900 3600 0    50   Input ~ 0
GND
$Comp
L Device:C C11
U 1 1 606E2035
P 4250 2850
AR Path="/6069F7D6/606E2035" Ref="C11"  Part="1" 
AR Path="/606BA90E/606E2035" Ref="C12"  Part="1" 
AR Path="/606BAC52/606E2035" Ref="C13"  Part="1" 
AR Path="/606BAF9A/606E2035" Ref="C14"  Part="1" 
F 0 "C11" H 4365 2896 50  0000 L CNN
F 1 "C" H 4365 2805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 4288 2700 50  0001 C CNN
F 3 "~" H 4250 2850 50  0001 C CNN
	1    4250 2850
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2700 4250 1400
Wire Wire Line
	4250 3000 4250 4800
$Comp
L Device:Jumper_NO_Small JP5
U 1 1 606EC725
P 9600 2050
AR Path="/6069F7D6/606EC725" Ref="JP5"  Part="1" 
AR Path="/606BA90E/606EC725" Ref="JP10"  Part="1" 
AR Path="/606BAC52/606EC725" Ref="JP15"  Part="1" 
AR Path="/606BAF9A/606EC725" Ref="JP20"  Part="1" 
F 0 "JP5" H 9600 2235 50  0000 C CNN
F 1 "Jumper_NO_Small" H 9600 2144 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9600 2050 50  0001 C CNN
F 3 "~" H 9600 2050 50  0001 C CNN
	1    9600 2050
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP6
U 1 1 606EC88F
P 9600 2150
AR Path="/6069F7D6/606EC88F" Ref="JP6"  Part="1" 
AR Path="/606BA90E/606EC88F" Ref="JP11"  Part="1" 
AR Path="/606BAC52/606EC88F" Ref="JP16"  Part="1" 
AR Path="/606BAF9A/606EC88F" Ref="JP21"  Part="1" 
F 0 "JP6" H 9600 2335 50  0000 C CNN
F 1 "Jumper_NO_Small" H 9600 2244 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9600 2150 50  0001 C CNN
F 3 "~" H 9600 2150 50  0001 C CNN
	1    9600 2150
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP7
U 1 1 606ECA86
P 9600 2250
AR Path="/6069F7D6/606ECA86" Ref="JP7"  Part="1" 
AR Path="/606BA90E/606ECA86" Ref="JP12"  Part="1" 
AR Path="/606BAC52/606ECA86" Ref="JP17"  Part="1" 
AR Path="/606BAF9A/606ECA86" Ref="JP22"  Part="1" 
F 0 "JP7" H 9600 2435 50  0000 C CNN
F 1 "Jumper_NO_Small" H 9600 2344 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9600 2250 50  0001 C CNN
F 3 "~" H 9600 2250 50  0001 C CNN
	1    9600 2250
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP8
U 1 1 606ECC37
P 9600 2350
AR Path="/6069F7D6/606ECC37" Ref="JP8"  Part="1" 
AR Path="/606BA90E/606ECC37" Ref="JP13"  Part="1" 
AR Path="/606BAC52/606ECC37" Ref="JP18"  Part="1" 
AR Path="/606BAF9A/606ECC37" Ref="JP23"  Part="1" 
F 0 "JP8" H 9600 2535 50  0000 C CNN
F 1 "Jumper_NO_Small" H 9600 2444 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9600 2350 50  0001 C CNN
F 3 "~" H 9600 2350 50  0001 C CNN
	1    9600 2350
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP9
U 1 1 606ECDF1
P 9600 2450
AR Path="/6069F7D6/606ECDF1" Ref="JP9"  Part="1" 
AR Path="/606BA90E/606ECDF1" Ref="JP14"  Part="1" 
AR Path="/606BAC52/606ECDF1" Ref="JP19"  Part="1" 
AR Path="/606BAF9A/606ECDF1" Ref="JP24"  Part="1" 
F 0 "JP9" H 9600 2635 50  0000 C CNN
F 1 "Jumper_NO_Small" H 9600 2544 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9600 2450 50  0001 C CNN
F 3 "~" H 9600 2450 50  0001 C CNN
	1    9600 2450
	1    0    0    -1  
$EndComp
Text Label 7250 2200 0    50   ~ 0
~CTS
Text Label 9500 2050 2    50   ~ 0
~CTS
Text Label 9500 2450 2    50   ~ 0
~RTS
Text Label 9500 2350 2    50   ~ 0
TXD
Text Label 9500 2250 2    50   ~ 0
RXD
Text Label 7250 2700 0    50   ~ 0
~RTS
Text Label 7250 3300 0    50   ~ 0
RXD
Text Label 7250 3400 0    50   ~ 0
TXD
Wire Wire Line
	4250 4800 6250 4800
Wire Wire Line
	4250 1400 6250 1400
$Comp
L Device:R R1
U 1 1 607002B1
P 2550 3600
AR Path="/6069F7D6/607002B1" Ref="R1"  Part="1" 
AR Path="/606BA90E/607002B1" Ref="R2"  Part="1" 
AR Path="/606BAC52/607002B1" Ref="R3"  Part="1" 
AR Path="/606BAF9A/607002B1" Ref="R4"  Part="1" 
F 0 "R1" V 2343 3600 50  0000 C CNN
F 1 "R" V 2434 3600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 2480 3600 50  0001 C CNN
F 3 "~" H 2550 3600 50  0001 C CNN
	1    2550 3600
	0    1    1    0   
$EndComp
Connection ~ 2400 3600
Wire Wire Line
	2700 3600 5250 3600
$Comp
L Device:R R5
U 1 1 60705984
P 9200 3200
AR Path="/6069F7D6/60705984" Ref="R5"  Part="1" 
AR Path="/606BA90E/60705984" Ref="R7"  Part="1" 
AR Path="/606BAC52/60705984" Ref="R9"  Part="1" 
AR Path="/606BAF9A/60705984" Ref="R11"  Part="1" 
F 0 "R5" V 8993 3200 50  0000 C CNN
F 1 "R" V 9084 3200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 9130 3200 50  0001 C CNN
F 3 "~" H 9200 3200 50  0001 C CNN
	1    9200 3200
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 60705B67
P 9200 3300
AR Path="/6069F7D6/60705B67" Ref="R6"  Part="1" 
AR Path="/606BA90E/60705B67" Ref="R8"  Part="1" 
AR Path="/606BAC52/60705B67" Ref="R10"  Part="1" 
AR Path="/606BAF9A/60705B67" Ref="R12"  Part="1" 
F 0 "R6" V 8993 3300 50  0000 C CNN
F 1 "R" V 9084 3300 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 9130 3300 50  0001 C CNN
F 3 "~" H 9200 3300 50  0001 C CNN
	1    9200 3300
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x03_Male J6
U 1 1 60705F50
P 9550 3300
AR Path="/6069F7D6/60705F50" Ref="J6"  Part="1" 
AR Path="/606BA90E/60705F50" Ref="J7"  Part="1" 
AR Path="/606BAC52/60705F50" Ref="J8"  Part="1" 
AR Path="/606BAF9A/60705F50" Ref="J9"  Part="1" 
F 0 "J6" H 9522 3324 50  0000 R CNN
F 1 "Conn_01x03_Male" H 9522 3233 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 9550 3300 50  0001 C CNN
F 3 "~" H 9550 3300 50  0001 C CNN
	1    9550 3300
	-1   0    0    -1  
$EndComp
Text GLabel 9350 3400 0    50   Input ~ 0
GND
Text Label 9050 3200 2    50   ~ 0
TXD
Text Label 9050 3300 2    50   ~ 0
RXD
$EndSCHEMATC
