#include <Wire.h>

int value;
int address;

void setup()
{
  Wire.begin();
  Serial.begin(115200);
  Serial.println("\nVerilog I2C Test");
  value = 0;
  address = 114;
}

void loop()
{
  delay(1000);
  Serial.print("Starting to ");
  Serial.print(address);
  Serial.print(" with ");
  Serial.println(value);

  Wire.beginTransmission(address);
  Wire.write(value);
  int error = Wire.endTransmission();
  Serial.println("Device response OK");
  value++;    
      
  Wire.requestFrom(address, 2);
  while(Wire.available()) 
  {
    Serial.print("Reading: ");
    Serial.println(Wire.read());
  }
  
  Serial.println("");
  Serial.println("==================================================");
  Serial.println("");
  delay(1000);        
}

