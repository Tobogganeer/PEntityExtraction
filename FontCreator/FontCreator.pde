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
int currentLetter = -1;

float letterButtonSpacing = 50;
float letterButtonSize = 40;

// Letters and letter buttons are added at runtime
ArrayList<Letter> letters = new ArrayList<Letter>();
ArrayList<Button> letterButtons = new ArrayList<Button>();

// Input fields and UI buttons are not
InputField[] inputFields;
Button[] uiButtons;
Button newLetterButton = new Button(0, 0, letterButtonSize, letterButtonSize, "NEW");

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
    right,
    newLetterButton
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
  updateLetters();
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

void updateLetters()
{
  // Place 'new' button at end of list
  newLetterButton.setPosition(getPosition(letters.size()));
}

PVector getPosition(int index)
{
  index %= lettersPerPage();
  float x = 505 + (index % letterColumns) * letterButtonSpacing;
  float y = 80 + (index / letterColumns) * letterButtonSpacing;
  return new PVector(x, y);
}

int lettersPerPage()
{
  return letterColumns * letterRows;
}



void mouseReleased()
{
  // Check if we click any input fields (and buttons later)
  for (InputField field : inputFields)
    field.onMousePressed();

  if (newLetterButton.isHovered())
  {
    letters.add(new Letter("test", Character.forDigit(letters.size() % 10, 10), 4, 4));
  }
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
  int offset = lettersPerPage() * page;

  for (int i = offset; i < letters.size() - offset; i++)
  {
    PVector pos = getPosition(i);
    rect(pos.x, pos.y, letterButtonSize, letterButtonSize);
  }
}

void drawHeader()
{
  textAlign(CENTER, CENTER);
  // Divide it by how many letters are per page and round that up.
  int pages = (int)Math.ceil((letters.size() + 1) / float(lettersPerPage()));
  String label = "Page " + (page + 1) + " / " + pages;
  fill(255);
  textSize(24);
  text(label, 650, 40);
  textSize(14);
}
