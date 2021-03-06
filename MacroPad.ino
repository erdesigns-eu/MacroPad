/* @file MacroPad.ino
|| @version 1.0
|| @author Ernst Reidinga (ERDesigns)
|| @contact ernst@erdesigns.eu
||
|| @description
|| | MacroPad firmware for use with the ERDesigns MacroPad software.
|| | The firmware supports up to 10 simultanious keypresses,
|| | and up to 10 rows and cols with keys. The firmware uses
|| | the Keypad Library 3.01 written by Mark Stanley, Alexander Brevig.
|| #
*/

#include <Keypad.h>

const byte ROWS = 5;
const byte COLS = 5;

// These could be random characters, these are not used.
char hexaKeys[ROWS][COLS] = {
  {'a','a','a','a','a'},
  {'f','g','h','i','j'},
  {'k','l','m','n','o'},
  {'p','q','r','s','t'},
  {'u','v','w','x','y'}
};
byte rowPins[ROWS] = {5, 6, 7, 8, 9};
byte colPins[COLS] = {14, 15, 16, 17, 18};
 
//initialize an instance of class NewKeypad
Keypad kpd = Keypad( makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS); 

String key;

bool active;
bool config;

const unsigned int MAX_INPUT = 10;

void setup() {
    // Set in waiting mode - start by software
    active = false;
    config = false;
    // Start the serial port
    Serial.begin(115200);
    // Wait for serial port to connect. Needed for native USB
    while (!Serial);
    // Print the MacroPad device name
    Serial.println(F("MacroPad v1.0"));
}

void process_data (char * data) {
  if (strcmp(data, "ID") == 0 || strcmp(data, "id") == 0) {
    Serial.println(F("ID|MP001"));
  }
  if (strcmp(data, "VERSION") == 0 || strcmp(data, "version") == 0) {
    Serial.println(F("VERSION|1.0"));
  }
  if (strcmp(data, "OWNER") == 0 || strcmp(data, "owner") == 0) {
    Serial.println(F("OWNER|Ernst Reidinga"));
  }
  if (strcmp(data, "CONFIG") == 0 || strcmp(data, "config") == 0) {
    config = true;
    active = true;
  }
  if (strcmp(data, "START") == 0 || strcmp(data, "start") == 0) {
    active = true;
  }
  if (strcmp(data, "STOP") == 0 || strcmp(data, "stop") == 0) {
    active = false;
    config = false;
  }
  if (strcmp(data, "ACTIVE") == 0 || strcmp(data, "active") == 0) {
    Serial.println("ACTIVE|" + String(active));
  }
}

void loop() {
    static char input_line [MAX_INPUT];
    static unsigned int input_pos = 0;

    // Read and process incoming data
    if (Serial.available () > 0) {
        char inByte = Serial.read ();
        switch (inByte) {
            case '\n':
            case '\r':
              input_line [input_pos] = 0;
              process_data(input_line);
              input_pos = 0; 
              break;
       
            default:
              if (input_pos < (MAX_INPUT - 1))
                input_line [input_pos++] = inByte;
              break;
        }
    }

    // Read and process key states
    if (active == true && kpd.getKeys()) {
        for (int i = 0; i < LIST_MAX; i++) {
            if (kpd.key[i].stateChanged) {
                if (config == true) {
                  if (kpd.key[i].kstate == PRESSED) {
                    Serial.println(String(kpd.key[i].kcode) + " 1");
                  }
                } else {
                  key = String(kpd.key[i].kcode);
                  switch (kpd.key[i].kstate) {  
                      case PRESSED:
                        key += " 1";
                        break;
                      case HOLD:
                        key += " 2";
                        break;
                      case RELEASED:
                        key += " 3";
                        break;
                  }
                  Serial.println(key);
                }
            }
        }
    }
}
