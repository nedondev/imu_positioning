/**
 * Show GY521 Data.
 * 
 * Reads the serial port to get x- and y- axis rotational data from an accelerometer,
 * a gyroscope, and comeplementary-filtered combination of the two, and displays the
 * orientation data as it applies to three different colored rectangles.
 * It gives the z-orientation data as given by the gyroscope, but since the accelerometer
 * can't provide z-orientation, we don't use this data.
 * 
 */

import processing.serial.*;

Serial  myPort;
short   portIndex = 32;
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication
int     calibrating;

float   dt;
float   x_gyr;  //Gyroscope data
float   y_gyr;
float   z_gyr;
float   x_acc;  //Accelerometer data
float   y_acc;
float   z_acc;
float   x_ac, y_ac, z_ac; //Accel none angular
float   x_fil;  //Filtered data
float   y_fil;
float   z_fil;
int phase; //which section data  from regression -> 0 loop ->1
Table table;

final int MAX = 510;
final int NEUTRAL = 340;
final int MIN = 170;
final int SHIFT_GRAPH = 120;
int counter = 0;
PFont font;

void initRow(){
  table = new Table();
  table.addColumn("id");
  table.addColumn("dt");
  table.addColumn("accel_x");
  table.addColumn("accel_y");
  table.addColumn("accel_z");
  table.addColumn("accel_angle_x");
  table.addColumn("accel_angle_y");
  table.addColumn("accel_angle_z");
  table.addColumn("angle_x");
  table.addColumn("angle_y");
  table.addColumn("angle_z");
  table.addColumn("phase");
}

void saveRow(float dt, float accel_x, float accel_y, float accel_z
  , float accel_angle_x, float accel_angle_y, float accel_angle_z
  , float angle_x, float angle_y, float angle_z, int phase, String fileName){
  TableRow newRow = table.addRow();
  newRow.setInt("id", table.getRowCount() - 1);
  newRow.setFloat("dt", dt);
  newRow.setFloat("accel_x", accel_x);
  newRow.setFloat("accel_y", accel_y);
  newRow.setFloat("accel_z", accel_z);
  newRow.setFloat("accel_angle_x", accel_angle_x);
  newRow.setFloat("accel_angle_y", accel_angle_y);
  newRow.setFloat("accel_angle_z", accel_angle_z);
  newRow.setFloat("angle_x", angle_x);
  newRow.setFloat("angle_y", angle_y);
  newRow.setFloat("angle_z", angle_z);
  newRow.setInt("phase", phase);

  saveTable(table, fileName);
}

void setup() {
  //  size(640, 360, P3D); 
  initRow();
  size(1280,800,P3D);
  noStroke();
  colorMode(RGB, 256);
  font = loadFont("Arial-Black-100.vlw");

  //  println("in setup");
  String portName = Serial.list()[portIndex];
  //  println(Serial.list());
  //  println(" Connecting to -> " + Serial.list()[portIndex]);
  myPort = new Serial(this, portName, 38400);
  myPort.clear();
  myPort.bufferUntil(lf);
  graph_layout();
} 

void draw() {
  if(counter == 1250) // dosažení konce grafu
  {
  counter = SHIFT_GRAPH;
  graph_layout(); 
  }  

noStroke();
fill(255,0,0);
float tx_acc = (x_ac + 18000)/36000*420 +130 ;
if(tx_acc < 550 && tx_acc > 130 ) 
{ellipse(counter,800-tx_acc,10,10);} 
fill(0,255,0);
float ty_acc = (y_ac + 18000)/36000*420 +130 ;
if(ty_acc < 550 && ty_acc > 130)
  {ellipse(counter,800-ty_acc,10,10);}
fill(0,0,255);
float tz_acc = (z_ac + 18000)/36000*420 +130 ;
if(tz_acc < 550 && tz_acc > 130)
  {ellipse(counter,800-tz_acc,10,10);}

stroke(0);
line(SHIFT_GRAPH, 800-NEUTRAL,1260,800-NEUTRAL);
line(SHIFT_GRAPH, 800-MIN,1260,800-MIN);
line(SHIFT_GRAPH, 800-MAX,1260,800-MAX);
} 

void graph_layout()
{
background(122,122,122);
fill(255);
textFont(font,50);
text("Accelerometer and Arduino",250,70);
textFont(font,40);
text("graph in Processing",400,120);
text("Axis:",20,180);
fill(255,0,0);
text("X",200,180);
fill(0,255,0);
text("Y",250,180);
fill(0,0,255);
text("Z",300,180);

fill(255);
rectMode(CENTER);
strokeWeight(10);
rect(640,460,1235,495);
strokeWeight(1);
fill(0);
textFont(font,40);
text("+1g",35,800-MAX+5);
text(" 0g",35,800-NEUTRAL+5);
text("-1g",35,800-MIN+5);
}

void serialEvent(Serial p) {

  inString = (myPort.readString());

  try {
    // Parse the data
    println(inString);
    String[] dataStrings = split(inString, '#');
    for (int i = 0; i < dataStrings.length; i++) {
      String type = dataStrings[i].substring(0, 4);
      String dataval = dataStrings[i].substring(4);
      if (type.equals("DEL:")) {
        dt = float(dataval);
        print("Dt:");
        println(dt);
      } else if (type.equals("ACC:")) {
        String data[] = split(dataval, ',');
        x_acc = float(data[0]);
        y_acc = float(data[1]);
        z_acc = float(data[2]);
        /*
        print("Acc:");
         print(x_acc);
         print(",");
         print(y_acc);
         print(",");
         println(z_acc);
         */
      } else if (type.equals("GYR:")) {
        String data[] = split(dataval, ',');
        x_gyr = float(data[0]);
        y_gyr = float(data[1]);
        z_gyr = float(data[2]);
      } else if (type.equals("FIL:")) {
        String data[] = split(dataval, ',');
        x_fil = float(data[0]);
        y_fil = float(data[1]);
        z_fil = float(data[2]);
      } else if (type.equals("ACD:")) {
        String data[] = split(dataval, ',');
        x_ac = float(data[0]);
        y_ac = float(data[1]);
        z_ac = float(data[2]);
      } else if (type.equals("REAL")) {
        phase =1; 
      }else if (type.equals("TRAN")) {
        phase =0;
      }
    }
    saveRow(dt, x_ac, y_ac, z_ac
            , x_acc, y_acc, z_acc
            , x_fil, y_fil, z_fil, phase, "Dataset/testRegression.csv");
    counter++;
  } 
  catch (Exception e) {
    print("Caught Exception:");
    println(e);
    
  }
}
