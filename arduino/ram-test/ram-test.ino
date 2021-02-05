/* Simple Arduino program to test my understanding of how the RAM chip works */

int we_pin = 2;
int oe_pin = 3;
int addr_pin[] = {12,13};
int data_pin[] = {4,5,6,7,8,9,10,11};

void setup() {
  Serial.begin(9600);
  minit();
}

void loop() {
  Serial.println("Write 42 to 0...");
  mwrite(0, 42);
  Serial.println("Write 100 to 1...");
  mwrite(1, 100);
  Serial.println("Read from 0...");
  Serial.println(mread(0)); // expect 42
  Serial.println("Read from 1...");
  Serial.println(mread(1)); // expect 100
  Serial.println();
  delay(1000);
}

void minit() {
  pinMode(we_pin,OUTPUT);
  pinMode(oe_pin,OUTPUT);
  
  digitalWrite(we_pin, 1);
  digitalWrite(oe_pin, 1);
  
  for (int i = 0; i < 2; i++)
    pinMode(addr_pin[i], OUTPUT);
}

void mwrite(int addr, int val) {
  for (int i = 0; i < 8; i++)
    pinMode(data_pin[i], OUTPUT);

  for (int i = 0; i < 2; i++)
    digitalWrite(addr_pin[i], (addr & (1 << i)) ? 1 : 0);

  for (int i = 0; i < 8; i++)
    digitalWrite(data_pin[i], (val & (1 << i)) ? 1 : 0);

  delay(1);
  digitalWrite(oe_pin, 1);
  delay(1);
  digitalWrite(we_pin, 0);
  delay(1);
  digitalWrite(we_pin, 1);
}

int mread(int addr) {
  for (int i = 0; i < 8; i++)
    pinMode(data_pin[i], INPUT);

  for (int i = 0; i < 2; i++)
    digitalWrite(addr_pin[i], (addr & (1 << i)) ? 1 : 0);

  delay(1);
  digitalWrite(we_pin, 1);
  delay(1);
  digitalWrite(oe_pin, 0);
  delay(1);

  int val = 0;
  for (int i = 0; i < 8; i++) {
    val |= digitalRead(data_pin[i]) << i;
  }

  digitalWrite(oe_pin, 1);

  return val;
}
