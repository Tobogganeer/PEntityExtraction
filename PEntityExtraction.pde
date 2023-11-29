/*

 Evan Daveikis
 991 721 245
 
 Entity Extraction
 
 */


/*

 MILESTONE 2 TODO:
 Player movement
 
 SI (remove as they are done)
 45 (game states)
 49 (collision detection)
 */



final boolean desktopMode = true;

boolean mapUp, mapRight, mapDown, mapLeft;


void settings()
{
  // https://processing.org/reference/size_.html
  // Make the display fullscreen if we are eh close enough
  if (Maths.within(displayWidth, Applet.width, 5) && Maths.within(displayHeight, Applet.height, 5))
    fullScreen();
  else
    size(Applet.width, Applet.height);
}

void setup()
{
  Applet.init(this);

  Font.load();
  CardData.loadCards();

  Menus.initTitleMenus();
  Menus.mainMenu.open();

  if (!desktopMode)
    noCursor();
}

void draw()
{
  background(255);
  Time.update();

  Game.update();
  Menus.current().draw();

  Popup.update();

  Draw.start(mouseX, mouseY, frameCount);
  {
    rect(0, 0, 250, 350);
    Text.label("Entity - Item", 5, 5, 1.5);
    Text.box("Descr\nTest\nDamage=5", new Rect(0, 200, 250, 150), 1.5, 10);
    Shapes.trapezoid(new PVector(), 100, 50, 30, Direction.RIGHT);
  }
  Draw.end();
}

void keyPressed()
{
  Menu menu = Menus.current();

  // TODO: Map controls
  if (desktopMode)
    pollDesktopControls(menu);
  else
    pollCabinetControls(menu);
}

void keyReleased()
{
  if (desktopMode)
    releaseDesktopControls();
  else
    releaseCabinetControls();
}

void mousePressed()
{
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
    // Control is the top left button, back
    if (key == CONTROL)
      menu.back();
    // Alt is to the right of control, select
    else if (key == ALT || key == ' ')
      menu.select();
  }
}

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
