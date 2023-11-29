/*

 Evan Daveikis
 991 721 245
 
 Entity Extraction
 
 */


/*

 MILESTONE 3 TODO:
 Map generation (hard coded)
 Item collection
 Item use
 Actions
 Entities
 Game end
 Particles
 
 SI:
 41: Random PVector
 40: Dist and dir of 2 points
 39: Physics
 17: Nested loop
 
 */



//final boolean desktopMode = true;

boolean mapUp, mapRight, mapDown, mapLeft, mapZoomIn, mapZoomOut;


void settings()
{
  // https://processing.org/reference/size_.html
  // Make the display fullscreen if we are eh close enough
  if (isInCabinet())
    fullScreen();
  else
    size(Applet.width, Applet.height);
}

boolean isInCabinet()
{
  // Check if the display size is +- 10 pixels
  return Maths.within(displayWidth, Applet.width, 10) && Maths.within(displayHeight, Applet.height, 10);
}

void setup()
{
  Applet.init(this);

  Font.load();
  CardData.loadCards();

  Menus.initTitleMenus();
  Menus.mainMenu.open();

  if (isInCabinet())
    noCursor();
}

void draw()
{
  background(255);
  Time.update();

  updateBoardControls();

  Game.update();
  Menus.current().draw();

  Popup.update();

  Draw.start(mouseX, mouseY, frameCount, map(sin(frameCount * 0.01) + 1, 0, 2, 0.4, 0.7));
  {
    rect(0, 0, 250, 350);
    Text.label("Entity - Item", 5, 5, 1.5);
    Text.box("Descr\nTest\nDamage=5", new Rect(0, 200, 250, 150), 1.5, 10);
    //Shapes.trapezoid(new PVector(), 100, 50, 30, Direction.RIGHT);

    for (int i = 0; i < clicks; i++)
    {
      PVector pos = Maths.getVertex(i, clicks);
      ellipse(pos.x * 40, pos.y * 40, 10, 10);
    }
  }
  Draw.end();
}

void keyPressed()
{
  Menu menu = Menus.current();

  // TODO: Map controls
  //if (desktopMode)
  //  pollDesktopControls(menu);
  //else
  pollCabinetControls(menu);
}

void keyReleased()
{
  //if (desktopMode)
  //  releaseDesktopControls();
  //else
  releaseCabinetControls();
}

int clicks;

void mousePressed()
{
  clicks++;
  println("Mouse: (" + mouseX + ", " + mouseY + ")");
}

void pollCabinetControls(Menu menu)
{
  if (key == CODED)
  {
    // Map the left stick to the directions
    if (keyCode == UP)
      menu.onInput(Direction.UP);
    else if (keyCode == RIGHT)
      menu.onInput(Direction.RIGHT);
    else if (keyCode == DOWN)
      menu.onInput(Direction.DOWN);
    else if (keyCode == LEFT)
      menu.onInput(Direction.LEFT);

    // Control is the top left button, back
    if (keyCode == CONTROL)
      menu.back();
    // Alt is to the right of control, select
    else if (keyCode == ALT)
      menu.select();
  } else
  {
    // Pan the map around
    if (key == 'r' || key == 'R')
      mapUp = true;
    else if (key == 'g' || key == 'G')
      mapRight = true;
    else if (key == 'f' || key == 'F')
      mapDown = true;
    else if (key == 'd' || key == 'D')
      mapLeft = true;
    // Zoom the map
    else if (key == 'a' || key == 'A')
      mapZoomOut = true;
    else if (key == 's' || key == 'S' || key == 'q' || key == 'Q')
      mapZoomIn = true;

    // Space as an alternative to alt (its a bit buggy in windowed apps)
    if (key == ' ')
      menu.select();

    // Alt controls for desktop/testing
    if (key == BACKSPACE)
      menu.back();
    else if (key == ENTER)
      menu.select();
  }
}

void releaseCabinetControls()
{
  if (key == 'r' || key == 'R')
    mapUp = false;
  else if (key == 'g' || key == 'G')
    mapRight = false;
  else if (key == 'f' || key == 'F')
    mapDown = false;
  else if (key == 'd' || key == 'D')
    mapLeft = false;
  else if (key == 'a' || key == 'A')
    mapZoomOut = false;
  else if (key == 's' || key == 'S' || key == 'q' || key == 'Q')
    mapZoomIn = false;
}

void updateBoardControls()
{
  Board.desiredInput.x = 0;
  if (mapLeft) Board.desiredInput.x += 1;
  if (mapRight) Board.desiredInput.x -= 1;

  Board.desiredInput.y = 0;
  if (mapUp) Board.desiredInput.y += 1;
  if (mapDown) Board.desiredInput.y -= 1;

  Board.desiredZoom = 0;
  if (mapZoomIn) Board.desiredZoom = 1;
  if (mapZoomOut) Board.desiredZoom = -1;
}

/*
void pollDesktopControls(Menu menu)
 {
 if (key == CODED)
 {
 // Menu navigation
 if (keyCode == UP)
 menu.onInput(Direction.UP);
 else if (keyCode == RIGHT)
 menu.onInput(Direction.RIGHT);
 else if (keyCode == DOWN)
 menu.onInput(Direction.DOWN);
 else if (keyCode == LEFT)
 menu.onInput(Direction.LEFT);
 } else
 {
 // Map panning
 if (key == 'w' || key == 'W')
 mapUp = true;
 else if (key == 'd' || key == 'D')
 mapRight = true;
 else if (key == 's' || key == 'S')
 mapDown = true;
 else if (key == 'a' || key == 'A')
 mapLeft = true;
 
 // Menu select/back
 else if (key == BACKSPACE)
 menu.back();
 else if (key == ENTER)
 menu.select();
 }
 }
 */

/*

 Arcade controls
 
 Left Joystick: arrows keys
 Right Joystick: RDFG
 
 Left Buttons
 = ctrl  alt space
 = shift  z    x
 =   c    5
 
 Right buttons
 =   a    s    q
 =   w    e    [
 =   ]    6
 
 Player 1 button: 1
 Player 2 button: 2
 
 Left Pinball: 3
 Right Pinball: 4
 
 */
