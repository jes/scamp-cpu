/* jes's eeprom burner - 24LC256 edition
 *  
 * Based on http://www.learningaboutelectronics.com/Articles/24LC256-EEPROM-circuit-with-an-arduino.php
 * and https://github.com/jes/scamp-cpu/blob/master/arduino/eeprom-burner/eeprom-burner.ino
 * 
 * Assumed pin wiring:
 *  * pin 8 to +5v
 *  * pin 5 to A4, with 10k ohm pull-up
 *  * pin 6 to A5, with 10k ohm pull-up
 *  * everything else to ground
 */

#include <Wire.h>

#define BUFSZ 32
#define eeprom 0x50

void setup(void){
  Wire.begin();
  Serial.begin(115200);
}

void loop(){
  static char buf[BUFSZ];
  static int p;
  
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c == '\r' || c== '\n' || p == BUFSZ-1) {
      buf[p++] = 0;
      serialCommand(buf);
      p = 0;
    } else {
      buf[p++] = c;
    }
  }
}

//defines the writeEEPROM function
void write_data(int addr, int data) {
  Wire.beginTransmission(eeprom);
  Wire.write((int)(addr >> 8));
  Wire.write((int)(addr & 0xFF));
  Wire.write(data);
  Wire.endTransmission();
}

//defines the readEEPROM function
int read_data(int addr) {
  byte rdata = 0xFF;
  Wire.beginTransmission(eeprom);
  Wire.write((int)(addr >> 8));
  Wire.write((int)(addr & 0xFF));
  Wire.endTransmission();
  Wire.requestFrom(eeprom,1);
  if (Wire.available())
    rdata = Wire.read();
  return rdata;
}

void serialCommand(char *buf) {
  char **params = split(buf);

  if (strcmp(params[0], "help") == 0) {
    Serial.print(
      "eeprom-burner commands:\r\n"
      "   help           - show help\r\n"
      "   read ADDR      - read from ADDR\r\n"
      "   write ADDR VAL - write VAL to ADDR\r\n"
      "\r\n"
      "values and addresses should be in decimal\r\n"
    );
      
  } else if (strcmp(params[0], "read") == 0) {
    if (!params[1]) {
      Serial.println("error: usage: read ADDR");
      return;
    }
    int addr = atoi(params[1]);
    Serial.println(read_data(addr));
  } else if (strcmp(params[0], "write") == 0) {
    if (!params[1] || !params[2]) {
      Serial.println("error: usage: write ADDR VAL");
      return;
    }
    int addr = atoi(params[1]);
    int val = atoi(params[2]);
    write_data(addr, val);
    Serial.println("ok");
  }
}

// replace each space in buf with a \0, and return a (static!) nul-terminated array of pointers to the string parts
char **split(char *buf) {
  static char *parts[16];
  int n = 0;
  
  char *p = buf;
  while (*p && n < 15) {
    parts[n++] = p;
    while (*p && *p != ' ')
      p++;
    if (*p == ' ')
      *(p++) = 0;
  }
  parts[n++] = 0;
  
  return parts;
}
