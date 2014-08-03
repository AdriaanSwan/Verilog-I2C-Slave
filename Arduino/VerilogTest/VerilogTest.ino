#include <Wire.h>

byte value;
int address;

void setup()
{
  value = 0;
  address = 114;
  
  Wire.begin();
  Serial.begin(115200);
  Serial.println("Verilog I2C Test\n\n");

  delay(1000);
}

void loop()
{
  Serial.print("Address\t");
  Serial.println(address);
  Serial.print("Value\t");
  Serial.println(value);

  Wire.beginTransmission(address);
  Wire.write(value);
  int error = Wire.endTransmission();
     
  Serial.print("Result\t");
  Serial.println(error);    
      
  Wire.requestFrom(address, 2);
  while(Wire.available()) 
  {
    Serial.print("Read\t");
    Serial.println(Wire.read());
  }
  Serial.println("\n");
   
  value++;
  delay(5);
}

