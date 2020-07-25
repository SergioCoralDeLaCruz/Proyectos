// Librerias I2C para controlar el mpu6050
// la libreria MPU6050.h necesita I2Cdev.h, I2Cdev.h necesita Wire.h
#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"
int potencia=0;
int estadoFreno=0;
int giro=0;
// La dirección del MPU6050 puede ser 0x68 o 0x69, dependiendo 
// del estado de AD0. Si no se especifica, 0x68 estará implicito
MPU6050 sensor;

// Valores RAW (sin procesar) del acelerometro y giroscopio en los ejes x,y,z
int gx, gy, gz;

long tiempo_prev, dt;
float girosc_ang_x, girosc_ang_y;
float girosc_ang_x_prev, girosc_ang_y_prev;



////MOTOR PAP:


#define IN1  11
#define IN2  10
#define IN3  9
#define IN4  8

int Paso [ 8 ][ 4 ] =
{ {1, 0, 0, 0},
  {1, 1, 0, 0},
  {0, 1, 0, 0},
  {0, 1, 1, 0},
  {0, 0, 1, 0},
  {0, 0, 1, 1},
  {0, 0, 0, 1},
  {1, 0, 0, 1}
};

int steps_left = 4090;
boolean Direction = true;
int Steps = 0;  // Define el paso actual de la secuencia
int retardoParaPAP=0;
float giroY=0;
float ultimoAngulo=0;

//MOTOR PAP--



//SENSOR EFECTO HALL:


#define PINHALL 6

float velocidadHall=0;
float velocidadMaximaHall=0;
long tiempoHall=0;
int CantidadImanHall=0;
int aHall=0;

int F_LecHall(int pinSensor){
  return digitalRead(pinSensor);
}


//SENSOR EFECTO HALL--



//VELOCIDAD ANGULAR MOTOR

#include <FreqCount.h>

float velocidadAngular=0;
float velocidadAngularMaxima=0;
//VELOCIDAD ANGULAR MOTOR---


void setup() {
  Serial.begin(57600);    //Iniciando puerto serial
  Wire.begin();           //Iniciando I2C  
  sensor.initialize();    //Iniciando el sensor

  if (sensor.testConnection()) Serial.println("Sensor iniciado correctamente");
  else Serial.println("Error al iniciar el sensor");
  tiempo_prev=millis();


  //MOTOR PAP:

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  //MOTOR PAP--


  //SENSOR EFECTO HALL
  pinMode(PINHALL,INPUT);
  // SENSOR EFECTO HALL---


  //VELOCIDAD ANGULAR MOTOR


  FreqCount.begin(1000);

  //VELOCIDAD ANGULAR MOTOR---
  
}



void loop() {


  
  // Leer las velocidades angulares 
  sensor.getRotation(&gx, &gy, &gz);
  
  //Calcular los angulos rotacion:
  
  dt = millis()-tiempo_prev;
  tiempo_prev=millis();
  
  girosc_ang_x = (gx/131)*dt/1000.0 + girosc_ang_x_prev;
  girosc_ang_y = (gy/131)*dt/1000.0 + girosc_ang_y_prev;

  girosc_ang_x_prev=girosc_ang_x;
  girosc_ang_y_prev=girosc_ang_y;

  //Mostrar los angulos separadas por un [tab]

  /*
  Serial.print(" Rotacion en X:  ");
  Serial.print(girosc_ang_x); 
  Serial.print(" tRotacion en Y: ");
  Serial.println(girosc_ang_y);
*/
  retardoParaPAP++;
  //MOTOR PAP:
  
  if (retardoParaPAP==1000){
  retardoParaPAP=0;
  giroY=girosc_ang_y-ultimoAngulo;
  ultimoAngulo=girosc_ang_y;
      if (giroY<0){
        Direction=true;
        giroY=-giroY;
      }
      else Direction=false;

      
      steps_left=(giroY*4090/360);

  while (steps_left > 0)
  {
    stepper() ;     // Avanza un paso
    steps_left-- ;  // Un paso menos
    delay (1) ;
  }
  //Direction = !Direction; // Invertimos la direceccion de giro
//  steps_left = 4090;
  
  }
  //MOTOR PAP--




//SENSOR EFECTO HALL

int ValSensor=F_LecHall(PINHALL);

if((ValSensor==0)||(aHall==1)){
  aHall=1;
  if(ValSensor==1){
    aHall=0;
    CantidadImanHall++;
  }
}

if(tiempoHall==1000){
  velocidadHall=((0.2*CantidadImanHall)/10);
  CantidadImanHall=0;
  tiempoHall=0;
  if(velocidadMaximaHall<velocidadHall){
    velocidadMaximaHall=velocidadHall;
  }
}

tiempoHall++;

/*
Serial.print("  ValorDelSensor:  ");
Serial.print(ValSensor);
Serial.print("  TiempoDelSensor:  ");
Serial.print(tiempoHall);
Serial.print("  Velocidad:  ");
Serial.print(velocidadHall);
Serial.print("  Velocidad Máxima:  ");
Serial.print(velocidadMaximaHall);
*/
//SENSOR EFECTO HALL----


//VELOCIDAD ANGULAR MOTOR


  if (FreqCount.available()) {
    unsigned long count = FreqCount.read();
    velocidadAngular=count*3,1416;

    /*
    Serial.print(" Frecuencia ");
    Serial.print(count);
    Serial.print(" Velocidad Angular ");
    Serial.print(velocidadAngular);
    Serial.print(" Velocidad Angular Máxima ");
    Serial.print(velocidadAngularMaxima);
    */
    if(velocidadAngularMaxima<velocidadAngular){
     velocidadAngularMaxima=velocidadAngular;
    }
  }

//VELOCIDAD ANGULAR MOTOR---

int b=estadoFreno;
potencia=velocidadAngular*7;
giro=int(girosc_ang_y);
String myString = String(potencia)+";" + String(b)+";"+String(giro)+";"+String(velocidadHall)+";"+String(giro);
Serial.print(" String: ");
Serial.println(myString);
mySerial.print(myString);
  delay(1);

  
  //girosc_ang_y     Rotacion de la turbina (grados sexagecimales)
  //velocidadAngular  Velocidad angular actual de las aspas de la turbina (rad/s)
  //velocidadAngularMaxima   Velocidad angular máxima de la turbina(rad/s)
  //velocidadHall   Velocidad actual del aire(m/s)
  //velocidadMaximaHall Velocidad máxima del aire (m/s)
  //Potencia calcular a partir de "velocidadAngular"
  
  //potencia//freno=0//Direccion de la turb//VelViento//DireccionViento

  
}



//MOTOR PAP:

void stepper()            //Avanza un paso
{
  digitalWrite( IN1, Paso[Steps][ 0] );
  digitalWrite( IN2, Paso[Steps][ 1] );
  digitalWrite( IN3, Paso[Steps][ 2] );
  digitalWrite( IN4, Paso[Steps][ 3] );

  SetDirection();
}

void SetDirection()
{
  if (Direction)
    Steps++;
  else
    Steps--;

  Steps = ( Steps + 8 ) % 8 ;
}
//potencia//freno=0//Direccion de la turb//VelViento//DireccionViento
//MOTOR PAP --
