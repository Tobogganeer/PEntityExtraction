/*

 Evan Daveikis
 991 721 245
 
 Entity Extraction
 
 */


/*

 MILESTONE 2 TODO:
 Player movement
 Loading content from disk
 
 SI (remove as they are done)
 45 (game states)
 49 (collision detection)
 */



final boolean desktopMode = true;


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
  if (key == 'w' || key == 'W')
    menu.onInput(Direction.UP);
  else if (key == 'd' || key == 'D')
    menu.onInput(Direction.RIGHT);
  else if (key == 's' || key == 'S')
    menu.onInput(Direction.DOWN);
  else if (key == 'a' || key == 'A')
    menu.onInput(Direction.LEFT);
  else if (key == BACKSPACE)
    menu.back();
  else if (key == ENTER)
    menu.select();
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
