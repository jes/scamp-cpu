/* jes's eeprom burner
 *  
 *  TODO: add a way to bulk read/write data, so that it doesn't take so long
 */

#define BUFSZ 32

const int addr_pin[10] = {10, 9, 8, 7, 6, 5, 4, 3, 0, 1};
const int data_pin[8] = {11, 12, 13, A5, A4, A3, A2, A1};
const int we_pin = 2;
const int oe_pin = A0;

void setup() {
  Serial.end();
  for (int b = 0; b < 10; b++)
    pinMode(addr_pin[b], OUTPUT);
  pinMode(we_pin, OUTPUT);
  pinMode(oe_pin, OUTPUT);
  digitalWrite(we_pin, HIGH);
  digitalWrite(oe_pin, HIGH);
  
  begin_serial();
}

void loop() {
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

void begin_serial() {
  delay(1);
  Serial.begin(115200);
}

void end_serial() {
  digitalWrite(we_pin, HIGH);
  Serial.end();
  delay(1);
}

void set_addr(int addr) {
  for (int b = 0; b < 10; b++)
    digitalWrite(addr_pin[b], !!(addr & (1<<b)));
}

void write_data(int addr, int data) {
  end_serial();
  digitalWrite(we_pin, HIGH);
  digitalWrite(oe_pin, HIGH);
  set_addr(addr);
  for (int b = 0; b < 8; b++)
    pinMode(data_pin[b], OUTPUT);
  for (int b = 0; b < 8; b++)
    digitalWrite(data_pin[b], !!(data & (1<<b)));
  delay(1);;
  digitalWrite(we_pin, LOW);
  delayMicroseconds(1); // datasheet: "max write pulse width" is 1000 ns
  digitalWrite(we_pin, HIGH);
  delay(1);
  begin_serial();
}

int read_data(int addr) {
  end_serial();
  set_addr(addr);
  digitalWrite(oe_pin, LOW);
  digitalWrite(we_pin, HIGH);
  delay(1);
  int data = 0;
  for (int b = 0; b < 8; b++)
    pinMode(data_pin[b], INPUT);
  delay(1);
  for (int b = 0; b < 8; b++)
    if (digitalRead(data_pin[b]))
      data |= (1<<b);
  digitalWrite(oe_pin, HIGH);
  begin_serial();
  return data;
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
