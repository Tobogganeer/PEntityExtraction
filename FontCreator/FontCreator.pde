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

InputField letterName = new InputField(100, 520, 100, 24, "Letter Name", InputType.STRING);
InputField letterChar = new InputField(100, 560, 24, 24, "Letter Char", InputType.CHAR);

InputField letterWidth = new InputField(350, 520, 40, 24, "Letter Width", InputType.NUMBER);
InputField letterHeight = new InputField(350, 560, 40, 24, "Letter Height", InputType.NUMBER);

InputField fontVersion = new InputField(660, 510, 120, 24, "Font Version", InputType.STRING);

Button load = new Button(520, 550, 120, 40, "Load");
Button save = new Button(660, 550, 120, 40, "Save");

Button left = new Button(520, 20, 24, 40, "<");
Button right = new Button(755, 20, 24, 40, ">");


int letterRows = 8;
int letterColumns = 6;

int page = 0;

ArrayList<Letter> letters = new ArrayList<Letter>();




/*
 stringInput = new InputField(x, y, w, h, "Label", InputType.STRING);
 charInput = new InputField(x, y, w, h, "Label", InputType.CHAR);
 intInput = new InputField(x, y, w, h, "Label", InputType.NUMBER);
 */

// Letter buttons are added at runtime
ArrayList<Button> letterButtons = new ArrayList<Button>();
// New input fields and UI buttons are not
InputField[] inputFields;
Button[] uiButtons;

void setup()
{
  // Setup the screen and constant drawing settings
  size(800, 600);
  stroke(160);
  strokeWeight(2);
  textSize(14);

  // Here is all of our input fields
  inputFields = new InputField[]
    {
    letterName,
    letterChar,
    letterWidth,
    letterHeight,
    fontVersion
  };

  // And here are our buttons
  uiButtons = new Button[]
    {
    load,
    save,
    left,
    right
  };

  // Some nice defaults
  letterWidth.content = "5";
  letterHeight.content = "7";
  fontVersion.content = "1.0";
}

void draw()
{
  // Draw the basics
  background(100);
  drawPanels();
  drawHeader();

  // Buttons and input fields
  drawControls();
  // Verify our numbers are valid
  verifyLimits();

  // Draw the currently made
  drawLetters();
}

void drawControls()
{
  // We are holding down the left mouse button
  boolean lmbDown = mousePressed && mouseButton == LEFT;

  for (Button b : uiButtons)
  {
    // Colour them correctly
    b.mouseDown = b.isHovered() && lmbDown;
    // Draw them
    b.display();
  }
  
  for (Button b : letterButtons)
  {
    b.mouseDown = b.isHovered() && lmbDown;
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
  // Don't clamp while we are editing though
  if (!letterWidth.isActive) letterWidth.clamp(1, 20);
  if (!letterHeight.isActive) letterHeight.clamp(1, 20);
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
  float letterPanelHeight = 100;
  rect(0, height - letterPanelHeight, width, letterPanelHeight);

  // Right panel with font info and settings
  float fontPanelWidth = 300;
  rect(width - fontPanelWidth, 0, fontPanelWidth, height);
}

void drawLetters()
{
  float size = 50;
  float rectSize = 40;

  for (int i = 0; i < 6; i++)
  {
    for (int j = 0; j < 8; j++)
    {
      rect(505 + i * size, 80 + j * size, rectSize, rectSize);
    }
  }
}

void drawHeader()
{
  textAlign(CENTER, CENTER);
  // Divide it by how many letters are per page and round that up.
  int pages = (int)Math.ceil((letters.size() + 1) / float(letterColumns * letterRows));
  String label = "Page " + (page + 1) + " / " + pages;
  fill(255);
  textSize(24);
  text(label, 650, 40);
  textSize(14);
}
