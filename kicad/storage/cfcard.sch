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
L Connector_Generic:Conn_02x20_Odd_Even J2
U 1 1 60BC0369
P 4750 3200
AR Path="/60BC0128/60BC0369" Ref="J2"  Part="1" 
AR Path="/60BC913C/60BC0369" Ref="J4"  Part="1" 
F 0 "J4" H 4800 4317 50  0000 C CNN
F 1 "Conn_02x20_Odd_Even" H 4800 4226 50  0000 C CNN
F 2 "storage:cfcard" H 4750 3200 50  0001 C CNN
F 3 "~" H 4750 3200 50  0001 C CNN
	1    4750 3200
	1    0    0    -1  
$EndComp
Text GLabel 4550 2300 0    50   Input ~ 0
~RESET~
Text GLabel 5050 2300 2    50   Input ~ 0
GND
Text GLabel 4550 2400 0    50   Input ~ 0
245D7
Text GLabel 4550 2500 0    50   Input ~ 0
245D6
Text GLabel 4550 2600 0    50   Input ~ 0
245D5
Text GLabel 4550 2700 0    50   Input ~ 0
245D4
Text GLabel 4550 2800 0    50   Input ~ 0
245D3
Text GLabel 4550 2900 0    50   Input ~ 0
245D2
Text GLabel 4550 3000 0    50   Input ~ 0
245D1
Text GLabel 4550 3100 0    50   Input ~ 0
245D0
Text GLabel 5050 2400 2    50   Input ~ 0
245D8
Text GLabel 5050 2500 2    50   Input ~ 0
245D9
Text GLabel 5050 2600 2    50   Input ~ 0
245D10
Text GLabel 5050 2700 2    50   Input ~ 0
245D11
Text GLabel 5050 2800 2    50   Input ~ 0
245D12
Text GLabel 5050 2900 2    50   Input ~ 0
245D13
Text GLabel 5050 3000 2    50   Input ~ 0
245D14
Text GLabel 5050 3100 2    50   Input ~ 0
245D15
Text GLabel 4550 3200 0    50   Input ~ 0
GND
Text GLabel 5050 3300 2    50   Input ~ 0
GND
Text GLabel 5050 3400 2    50   Input ~ 0
GND
Text GLabel 5050 3500 2    50   Input ~ 0
GND
NoConn ~ 5050 3600
NoConn ~ 5050 3200
Text GLabel 5050 3700 2    50   Input ~ 0
GND
NoConn ~ 5050 3800
NoConn ~ 5050 3900
Text GLabel 5050 4000 2    50   Input ~ 0
A2
Text GLabel 5050 4200 2    50   Input ~ 0
GND
Text HLabel 5050 4100 2    50   Input ~ 0
~CS1~
NoConn ~ 4550 3300
Text GLabel 4550 3400 0    50   Input ~ 0
~IOWR~
Text GLabel 4550 3500 0    50   Input ~ 0
~IORD~
NoConn ~ 4550 3600
NoConn ~ 4550 3700
NoConn ~ 4550 3800
Text GLabel 4550 3900 0    50   Input ~ 0
A1
Text GLabel 4550 4000 0    50   Input ~ 0
A0
Text HLabel 4550 4100 0    50   Input ~ 0
~CS0~
NoConn ~ 4550 4200
$Comp
L Connector_Generic:Conn_01x02 J3
U 1 1 60BC6FA0
P 6550 2350
AR Path="/60BC0128/60BC6FA0" Ref="J3"  Part="1" 
AR Path="/60BC913C/60BC6FA0" Ref="J5"  Part="1" 
F 0 "J5" H 6630 2342 50  0000 L CNN
F 1 "Conn_01x02" H 6630 2251 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 6550 2350 50  0001 C CNN
F 3 "~" H 6550 2350 50  0001 C CNN
	1    6550 2350
	1    0    0    -1  
$EndComp
Text GLabel 6350 2350 0    50   Input ~ 0
VCC
Text GLabel 6350 2450 0    50   Input ~ 0
GND
$Comp
L Device:C C4
U 1 1 60C47AAF
P 6350 3200
AR Path="/60BC0128/60C47AAF" Ref="C4"  Part="1" 
AR Path="/60BC913C/60C47AAF" Ref="C5"  Part="1" 
F 0 "C5" H 6465 3246 50  0000 L CNN
F 1 "C" H 6465 3155 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D6.0mm_W2.5mm_P5.00mm" H 6388 3050 50  0001 C CNN
F 3 "~" H 6350 3200 50  0001 C CNN
	1    6350 3200
	1    0    0    -1  
$EndComp
Text GLabel 6350 3050 2    50   Input ~ 0
VCC
Text GLabel 6350 3350 2    50   Input ~ 0
GND
$EndSCHEMATC
