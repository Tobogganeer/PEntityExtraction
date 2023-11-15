// Evan Daveikis

/*

 Code Credit: Kit Barry
 https://slate.sheridancollege.ca/d2l/le/content/1134892/viewContent/15022343/View
 
 Just testing out the controller library
 
 EDIT: Just learned about arcade mappings
 Won't even need the controller library
 Keeping this file for if I add controller support
 (may make playtesting easier)
 
 */

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

ControlIO control;
ControlDevice controlDevice;

ControlSlider leftStickX;
ControlSlider leftStickY;

PVector position = new PVector(200, 200);
PVector[] prevPositions = new PVector[5];

void setup()
{
  size(400, 400);
  
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a joystick that matches the configuration file.
  controlDevice = control.filter(GCP.GAMEPAD).getMatchedDevice("GameController");
  if (controlDevice == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }

  // Setup a function to trap events for this button
  //stick.getButton("LeftStickX").plug(this, "gas", ControlIO.ON_RELEASE);
  
  //http://www.lagers.org.uk/gamecontrol/api.html
  leftStickX = controlDevice.getSlider("LeftStickX");
  leftStickY = controlDevice.getSlider("LeftStickY");
}

void draw()
{
  background(255);
  fill(0);
  
  // Calculate some screen values
  float x = width / 2 + leftStickX.getValue() * 100;
  float y = height / 2 + leftStickY.getValue() * 100;
  
  // Smooth the little dot thingy
  position = PVector.lerp(position, new PVector(x, y), 0.2);
  
  for (int i = prevPositions.length - 1; i > 0;)
  {
    i--;
    prevPositions[i] = i > 0 ? prevPositions[i - 1] : position;
  } // TODO: Implement
  
  // Plot that sucker
  rect(position.x, position.y, 5, 5);
}
