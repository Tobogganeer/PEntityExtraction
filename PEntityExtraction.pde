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
 39 7
 
 */


Board board;
Menu mainMenu;

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

void mousePressed()
{
  Popup.show("Hi?", 3);
}


void initMainMenu()
{
  Rect window = new Rect(0, 0, width, height);
  Rect buttonRect = new Rect(0, 0, 300, 80);
  float elementsHeight = buttonRect.h * 2.5;
  Rect elementsRect = new Rect(width / 2 - buttonRect.w / 2, height / 2 - elementsHeight / 2, width / 2 + buttonRect.w / 2, elementsHeight);

  MenuItem play = new MenuItem("Play", buttonRect, (m, i) -> println("Selected play"));
  MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> println("Selected guide"));

  mainMenu = new ListMenu("Main Menu", window, elementsRect, MenuLayout.Vertical, play, guide);
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
