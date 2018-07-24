

int value = 0;

#define MAX_CLICKERS 6
#define OFFSET 2
#define DEBUG 0

int clickers[MAX_CLICKERS] = {0,0,0,0,0,0};

void setup() {
  Serial.begin(115200);
  if (DEBUG) {
    Serial.println("clickers ready");
  }

  for (int i = 0; i < 6; ++i) {
    pinMode(i+OFFSET, OUTPUT);
  }
}

void loop() {
  int c = Serial.read();
  if (c > -1) {

    if ((c >= '0') && (c <= '9')) {
      value = 10*value + c - '0';
      if (DEBUG) {
        Serial.println(c);        
      }
    }
    else {
      if (c=='c' and value >= 0 and value < MAX_CLICKERS) {
        if (DEBUG) {
          Serial.println("got value");
          Serial.println(value);
        }
        clickers[value] = 20000;
        digitalWrite(value+OFFSET, HIGH);
      }
      value = 0;
    }
  }
  for (int i = 0; i < MAX_CLICKERS; i++) {
    if (clickers[i] > 0) {
      clickers[i]--;
      if (clickers[i] == 0) {
        digitalWrite(i+OFFSET, LOW);
        if (DEBUG) {
          Serial.println("off");
        }
      }
    }
  }
}

