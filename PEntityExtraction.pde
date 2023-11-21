/*

 Evan Daveikis
 991 721 245
 
 Entity Extraction
 
 */


/*

 MILESTONE 1 TODO:
 
 Multiple players
 Menu system
 Placeholder player actions
 Player cards (player class)
 
 SI (remove as they are done)
 39
 
 */


boolean desktopMode = true;







Board board;
ListMenu mainMenu;

void setup()
{
  size(1280, 1024);

  Applet.init(this);
  Font.load();

  board = new Board();
  initMainMenu();

  History.goTo(mainMenu);
}

void draw()
{
  background(255);
  Time.update();

  board.draw();

  History.current().draw();

  Popup.update();
}

void keyPressed()
{
  Menu menu = History.current();

  if (desktopMode)
    pollDesktopControls(menu);
  else
    pollCabinetControls(menu);
}

void pollCabinetControls(Menu menu)
{
  if (key == CODED)
  {
    // Map the left stick to the directions
    if (keyCode == UP)
      menu.onInput(Direction.Up);
    else if (keyCode == RIGHT)
      menu.onInput(Direction.Right);
    else if (keyCode == DOWN)
      menu.onInput(Direction.Down);
    else if (keyCode == LEFT)
      menu.onInput(Direction.Left);
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
    menu.onInput(Direction.Up);
  else if (key == 'd' || key == 'D')
    menu.onInput(Direction.Right);
  else if (key == 's' || key == 'S')
    menu.onInput(Direction.Down);
  else if (key == 'a' || key == 'A')
    menu.onInput(Direction.Left);
  else if (key == BACKSPACE)
    menu.back();
  else if (key == ENTER)
    menu.select();
}


void initMainMenu()
{
  Rect window = new Rect(0, 0, width, height);
  Rect buttonRect = new Rect(0, 0, 300, 80);
  Rect elementsRect = Rect.center(width / 2, height / 2, buttonRect.w, buttonRect.h * 2.5);

  MenuItem play = new MenuItem("Play", buttonRect, (m, i) -> println("Selected play"));
  MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> println("Selected guide"));

  mainMenu = new ListMenu("ENTITY EXTRACTION", window, elementsRect, MenuLayout.Vertical, play, guide);
  mainMenu.nameAlignment = TextAlign.TopCenter;
  mainMenu.nameTextPadding = 200;
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
