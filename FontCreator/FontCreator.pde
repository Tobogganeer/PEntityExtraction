/*

 Evan Daveikis
 991 721 245
 
 Font Creator
 Used to more easily create fonts for the new font library
 that (will be) made for PEntityExtraction.
 
 Draw out the font on the canvas, and export
 the font as a json file.
 
 */

import java.util.ArrayList;

//InputField letterName = new InputField(x, y, w, h, "Letter Name", InputType.STRING);
//InputField letterChar = new InputField(x, y, w, h, "Letter Char", InputType.CHAR);

//InputField letterWidth = new InputField(x, y, w, h, "Letter Width", InputType.NUMBER);
//InputField letterHeight = new InputField(x, y, w, h, "Letter Height", InputType.NUMBER);

//InputField fontVersion = new InputField(x, y, w, h, "Font Version", InputType.STRING);

//Button load = new Button(510, 510, 120, 80, "Load");
//Button save = new Button(650, 510, 120, 80, "Save");




/*
 stringInput = new InputField(x, y, w, h, "Label", InputType.STRING);
 charInput = new InputField(x, y, w, h, "Label", InputType.CHAR);
 intInput = new InputField(x, y, w, h, "Label", InputType.NUMBER);
 */

// New buttons are added at runtime
ArrayList<Button> buttons = new ArrayList<Button>();
// New input fields are not
InputField[] inputFields;

void setup()
{
  // Setup the screen and constant drawing settings
  size(800, 600);
  stroke(160);
  strokeWeight(2);
  textSize(14);

  // Here is all of our input fields (empty atm)
  inputFields = new InputField[] {
   
  };
}

void draw()
{
  // Draw the basics
  background(100);
  drawPanels();

  // Buttons and input fields
  drawControls();
  // Verify our numbers are valid
  verifyLimits();
}

void drawControls()
{
  // We are holding down the left mouse button
  boolean lmbDown = mousePressed && mouseButton == LEFT;

  for (Button b : buttons)
  {
    // Colour them correctly
    b.mouseDown = b.isHovered() && lmbDown;
    // Draw them
    b.display();
  }

  for (InputField f : inputFields)
  {
    // Colour and draw
    f.mouseDown = f.isHovered() && lmbDown;
    f.display();
  }
}

void verifyLimits()
{
  // Clamp our numbers (we don't want letters that are 0px wide)
}


void mouseReleased()
{
  // Check if we click any input fields (and buttons later)
  for (InputField field : inputFields)
    field.onMousePressed();
}

void keyPressed()
{
  // Send inputs to our input fields
  for (InputField field : inputFields)
    field.onKeyPressed();
}

void drawPanels()
{
  fill(55);
  
  // Draw the bottom panel with letter settings
  float letterPanelHeight = 200;
  rect(0, height - letterPanelHeight, width, letterPanelHeight);
  
  // Right panel with font info and settings
  float fontPanelWidth = 300;
  rect(width - fontPanelWidth, 0, fontPanelWidth, height);
}
