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

InputField gridSize = new InputField(450, 430, 40, 24, "Grid Size", InputType.NUMBER);

Button load = new Button(520, 550, 120, 40, "Load");
Button save = new Button(660, 550, 120, 40, "Save");

Button left = new Button(520, 20, 24, 40, "<");
Button right = new Button(755, 20, 24, 40, ">");

Button delete = new Button(440, 560, 50, 24, "Delete");

Button toggleGridlines = new Button(370, 460, 120, 24, "Toggle Gridlines");


int letterRows = 8;
int letterColumns = 6;

int page = 0;
int currentLetter = -1;

float letterButtonSpacing = 50;
float letterButtonSize = 40;

// Nobody needs letters these large anyways
int maxLetterHeight = 20;
int maxLetterWidth = 20;

// Used for the bitmap display
boolean drawGridlines = true;


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
    fontVersion,
    gridSize
  };

  // And here are our buttons
  uiButtons = new Button[]
    {
    load,
    save,
    left,
    right,
    newLetterButton,
    delete,
    toggleGridlines
  };

  // Some nice defaults
  letterWidth.content = "5";
  letterHeight.content = "7";
  fontVersion.content = "1.0";
  gridSize.content = "25";
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

  // Draw the currently made letters
  updateLetters();
  drawLetters();

  // Draw the screen that lets you edit the bitmaps
  drawBitmaps();
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

  boolean hasLetters = letters.size() > 0;

  // Don't need to take input if we have no letters!
  if (hasLetters)
  {
    for (InputField f : inputFields)
    {
      // Colour and draw
      f.mouseDown = f.isHovered() && lmbDown;
      f.display();
    }
  }

  // Disable buttons if we have no letters
  delete.enabled = hasLetters;
  toggleGridlines.enabled = hasLetters;
}

void verifyLimits()
{
  // Clamp our numbers (we don't want letters that are 0px wide)
  // Don't clamp while we are editing though
  letterWidth.clamp(1, maxLetterWidth);
  letterHeight.clamp(1, maxLetterHeight);
  gridSize.clamp(10, 40);
}

void updateLetters()
{
  // Place 'new' button at end of list
  newLetterButton.setPosition(getPosition(letters.size()));

  // We went over the top, might happen when deleting letters
  if (currentLetter >= letters.size())
  {
    currentLetter = letters.size() - 1;
  }

  // Haven't selected any letters yet!
  if (currentLetter < 0)
  {
    // A letter has been added! Select it!
    if (letters.size() > 0)
      currentLetter = 0;
    else
      // Still no letters, no updating to do
      return;
  }

  Letter l = letters.get(currentLetter);
  Button b = letterButtons.get(currentLetter);

  l.name = letterName.content;
  if (letterChar.content.length() > 0)
    l.character = letterChar.content.charAt(0);
  l.width = letterWidth.numericContent();
  l.height = letterHeight.numericContent();

  b.label = letterChar.content;
}

// Gets a letter position given a certain index
PVector getPosition(int index)
{
  // Clamp it to a valid index
  index %= lettersPerPage();
  // Offset the row and column
  float x = 505 + (index % letterColumns) * letterButtonSpacing;
  float y = 80 + (index / letterColumns) * letterButtonSpacing;
  // Return it
  return new PVector(x, y);
}

int lettersPerPage()
{
  return letterColumns * letterRows;
}

int numPages()
{
  return pageOfLetter(letters.size() + 1);
}

// Called when the left/right buttons are pressed
void handlePageFlip(int offset)
{
  int totalPages = numPages();

  // Can't flip if we only have 1 page :P
  if (totalPages == 1)
    return;

  // Add it
  page += offset;

  // And loop around
  if (page < 0)
    page = totalPages - 1;
  else if (page >= totalPages)
    page = 0;
}

// Returns true if index is on the current page
boolean isLetterOnPage(int index)
{
  int min = page * lettersPerPage();
  int max = (page + 1) * lettersPerPage() - 1;
  return index >= min && index <= max;
}

int pageOfLetter(int index)
{
  // Divide the index by how many letters are per page
  float percent = index / float(lettersPerPage());
  // Round that up and give it back
  return (int)Math.ceil(percent);
}

void addLetter()
{
  // Index before adding new letter
  PVector buttonPos = getPosition(letters.size());
  currentLetter = letters.size();

  // Add a blank letter, but keep the current width and height
  letters.add(new Letter("", ' ', letterWidth.numericContent(), letterHeight.numericContent()));
  letterButtons.add(new Button(buttonPos.x, buttonPos.y, letterButtonSize, letterButtonSize, ""));
  letterName.reset();
  letterChar.reset();

  // TODO: Clear screen bitmaps
}

// Used when selecting a new letter
void matchFieldsToCurrentLetter()
{
  if (currentLetter < 0)
    return;

  Letter l = letters.get(currentLetter);

  letterName.content = l.name;
  letterChar.content = Character.toString(l.character);
  letterWidth.content = Integer.toString(l.width);
  letterHeight.content = Integer.toString(l.height);
}

void checkLetterButtonClicks()
{
  int offset = lettersPerPage() * page;

  // Loop through buttons that are actually on screen
  for (int i = offset; i < letters.size(); i++)
  {
    Button b = letterButtons.get(i);
    // If we are clicking it
    if (b.isHovered())
    {
      // Change to that letter
      currentLetter = i;
      matchFieldsToCurrentLetter();
      break;
    }
  }
}

void delete()
{
  // Can this one
  letters.remove(currentLetter);
  letterButtons.remove(currentLetter);

  // Go back to the last letter
  currentLetter--;

  // We deleted all of them :(
  if (currentLetter < 0)
    return;

  matchFieldsToCurrentLetter();

  // Flip pages if need be
  page = pageOfLetter(currentLetter);
}




void mouseReleased()
{
  // Check if we click any input fields (and buttons later)
  for (InputField field : inputFields)
    field.onMousePressed();

  if (newLetterButton.isHovered())
  {
    addLetter();
  }

  // Check if we are trying to flip pages
  if (left.isHovered())
    handlePageFlip(-1);
  else if (right.isHovered())
    handlePageFlip(1);

  if (delete.isHovered())
    delete();

  if (toggleGridlines.isHovered())
    drawGridlines = !drawGridlines;

  // Check if we clicked a letter
  checkLetterButtonClicks();
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

  boolean lmbDown = mousePressed && mouseButton == LEFT;

  for (int i = offset; i < letters.size(); i++)
  {
    Button b = letterButtons.get(i);
    PVector pos = getPosition(i);
    b.setPosition(pos);
    b.mouseDown = b.isHovered() && lmbDown;
    b.display();
  }

  if (isLetterOnPage(currentLetter))
  {
    // Draw a transparent yellow over top of our selected one!
    fill(255, 255, 0, 60);
    PVector pos = getPosition(currentLetter);
    rect(pos.x, pos.y, letterButtonSize, letterButtonSize);
  }
}

void drawBitmaps()
{
  // We aren't editing any letter!
  if (currentLetter < 0)
    return;

  int rows = letterHeight.numericContent();
  int columns = letterWidth.numericContent();

  // The size is invalid (eg. if you are editing the size)
  if (rows < 1 || columns < 1)
    return;

  rows = min(rows, maxLetterHeight);
  columns = min(columns, maxLetterWidth);

  stroke(160);
  strokeWeight(1);

  if (!drawGridlines)
    noStroke();

  Rect window = new Rect(0, 0, 500, 500);
  float toggleSize = gridSize.numericContent();
  PVector totalSize = new PVector(columns * toggleSize, rows * toggleSize);
  PVector padding = new PVector(window.w - totalSize.x, window.h - totalSize.y);
  // Divide by 2 for padding on each side
  padding.div(2); // Skill inventory #43! Never used the div() function before

  fill(0);
  for (int i = 0; i < columns; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      rect(padding.x + i * toggleSize, padding.y + j * toggleSize, toggleSize, toggleSize);
    }
  }

  // Re-enable stroke
  stroke(160);
  strokeWeight(2);
}

void drawHeader()
{
  textAlign(CENTER, CENTER);
  String label = "Page " + (page + 1) + " / " + numPages();
  fill(255);
  textSize(24);
  text(label, 650, 40);
  textSize(14);
}
