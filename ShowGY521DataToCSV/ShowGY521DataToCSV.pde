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
}

void saveRow(float dt, float accel_x, float accel_y, float accel_z
  , float accel_angle_x, float accel_angle_y, float accel_angle_z
  , float angle_x, float angle_y, float angle_z, int phase){
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
  newRow.setFloat("phase", phase);

  saveTable(table, "./tempDataset/testRegression.csv");
}

void setup() {
  //  size(640, 360, P3D); 
  initRow();
  size(1400, 800, P3D);
  noStroke();
  colorMode(RGB, 256); 

  //  println("in setup");
  String portName = Serial.list()[portIndex];
  //  println(Serial.list());
  //  println(" Connecting to -> " + Serial.list()[portIndex]);
  myPort = new Serial(this, portName, 38400);
  myPort.clear();
  myPort.bufferUntil(lf);
} 

void draw_rect_rainbow() {
  scale(90);
  beginShape(QUADS);

  fill(0, 1, 1); 
  vertex(-1, 1.5, 0.25);
  fill(1, 1, 1); 
  vertex( 1, 1.5, 0.25);
  fill(1, 0, 1); 
  vertex( 1, -1.5, 0.25);
  fill(0, 0, 1); 
  vertex(-1, -1.5, 0.25);

  fill(1, 1, 1); 
  vertex( 1, 1.5, 0.25);
  fill(1, 1, 0); 
  vertex( 1, 1.5, -0.25);
  fill(1, 0, 0); 
  vertex( 1, -1.5, -0.25);
  fill(1, 0, 1); 
  vertex( 1, -1.5, 0.25);

  fill(1, 1, 0); 
  vertex( 1, 1.5, -0.25);
  fill(0, 1, 0); 
  vertex(-1, 1.5, -0.25);
  fill(0, 0, 0); 
  vertex(-1, -1.5, -0.25);
  fill(1, 0, 0); 
  vertex( 1, -1.5, -0.25);

  fill(0, 1, 0); 
  vertex(-1, 1.5, -0.25);
  fill(0, 1, 1); 
  vertex(-1, 1.5, 0.25);
  fill(0, 0, 1); 
  vertex(-1, -1.5, 0.25);
  fill(0, 0, 0); 
  vertex(-1, -1.5, -0.25);

  fill(0, 1, 0); 
  vertex(-1, 1.5, -0.25);
  fill(1, 1, 0); 
  vertex( 1, 1.5, -0.25);
  fill(1, 1, 1); 
  vertex( 1, 1.5, 0.25);
  fill(0, 1, 1); 
  vertex(-1, 1.5, 0.25);

  fill(0, 0, 0); 
  vertex(-1, -1.5, -0.25);
  fill(1, 0, 0); 
  vertex( 1, -1.5, -0.25);
  fill(1, 0, 1); 
  vertex( 1, -1.5, 0.25);
  fill(0, 0, 1); 
  vertex(-1, -1.5, 0.25);

  endShape();
}

void draw_rect(int r, int g, int b) {
  scale(90);
  beginShape(QUADS);

  fill(r, g, b);
  vertex(-1, 1.5, 0.25);
  vertex( 1, 1.5, 0.25);
  vertex( 1, -1.5, 0.25);
  vertex(-1, -1.5, 0.25);

  vertex( 1, 1.5, 0.25);
  vertex( 1, 1.5, -0.25);
  vertex( 1, -1.5, -0.25);
  vertex( 1, -1.5, 0.25);

  vertex( 1, 1.5, -0.25);
  vertex(-1, 1.5, -0.25);
  vertex(-1, -1.5, -0.25);
  vertex( 1, -1.5, -0.25);

  vertex(-1, 1.5, -0.25);
  vertex(-1, 1.5, 0.25);
  vertex(-1, -1.5, 0.25);
  vertex(-1, -1.5, -0.25);

  vertex(-1, 1.5, -0.25);
  vertex( 1, 1.5, -0.25);
  vertex( 1, 1.5, 0.25);
  vertex(-1, 1.5, 0.25);

  vertex(-1, -1.5, -0.25);
  vertex( 1, -1.5, -0.25);
  vertex( 1, -1.5, 0.25);
  vertex(-1, -1.5, 0.25);

  endShape();
}

void draw() { 

  background(0);
  lights();

  // Tweak the view of the rectangles
  int distance = 50;
  int x_rotation = 90;

  //Show gyro data
  pushMatrix(); 
  translate(width/6, height/2, -50); 
  rotateX(radians(-x_gyr - x_rotation));
  rotateY(radians(-y_gyr));
  draw_rect(249, 250, 50);

  popMatrix(); 

  //Show accel data
  pushMatrix();
  translate(width/2, height/2, -50);
  rotateX(radians(-x_acc - x_rotation));
  rotateY(radians(-y_acc));
  draw_rect(56, 140, 206);
  popMatrix();

  //Show combined data
  pushMatrix();
  translate(5*width/6, height/2, -50);
  rotateX(radians(-x_fil - x_rotation));
  rotateY(radians(-y_fil));
  draw_rect(93, 175, 83);
  popMatrix();

  textSize(24);
  String accStr = "(" + (int) x_acc + ", " + (int) y_acc + ")";
  String gyrStr = "(" + (int) x_gyr + ", " + (int) y_gyr + ")";
  String filStr = "(" + (int) x_fil + ", " + (int) y_fil + ")";


  fill(249, 250, 50);
  text("Gyroscope", (int) width/6.0 - 60, 25);
  text(gyrStr, (int) (width/6.0) - 40, 50);

  fill(56, 140, 206);
  text("Accelerometer", (int) width/2.0 - 50, 25);
  text(accStr, (int) (width/2.0) - 30, 50); 

  fill(83, 175, 93);
  text("Combination", (int) (5.0*width/6.0) - 40, 25);
  text(filStr, (int) (5.0*width/6.0) - 20, 50);
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
            , x_fil, y_fil, z_fil, phase);
  } 
  catch (Exception e) {
    println("Caught Exception");
  }
}
