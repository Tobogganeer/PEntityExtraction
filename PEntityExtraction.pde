/*

 Evan Daveikis
 991 721 245
 
 Entity Extraction
 
 */


/*

 MILESTONE 4 TODO:
 Entities
 Game end
 Finish up gameplay
 Implement effects
 
 */



//final boolean desktopMode = true;

boolean mapUp, mapRight, mapDown, mapLeft, mapZoomIn, mapZoomOut;
boolean showControls;
static boolean isCabinet;


void settings()
{
  // Check if the display size is +- 10 pixels
  isCabinet = Maths.within(displayWidth, Applet.width, 10) && Maths.within(displayHeight, Applet.height, 10);

  // https://processing.org/reference/size_.html
  // Make the display fullscreen if we are eh close enough
  if (isCabinet)
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

  if (isCabinet)
    noCursor();
}

void draw()
{
  background(255);
  Time.update();

  updateBoardControls();

  Game.update();
  Menus.current().draw();
  Particle.updateAll();

  //debugGraphics();

  Popup.update();

  if (showControls)
    MainMenu.drawControls();
}

void debugGraphics()
{
  float diff = constrain((pmouseX - mouseX) * 0.1, -35, 35);
  Draw.start(mouseX, mouseY, diff);//, frameCount, map(sin(frameCount * 0.01) + 1, 0, 2, 0.4, 0.7));
  {
    // String name, String id, String description, String imagePath, CardType type, int count, String[] tags, int actionCost, Effect[] onUse
    new Card(CardData.get(IDs.Entity.Item.OddMachine)).draw();
    //Text.align(TextAlign.CENTERLEFT);
    //Text.strokeWeight = 0.5;
    //Text.box("Card - Type", Card.headerRect(), 2, 5);

    //Text.align(TextAlign.TOPLEFT);
    //Text.strokeWeight = 0;
    //Rect imgRect = Card.imageRect();
    //Text.box("W=" + imgRect.w + ", H=" + imgRect.h, imgRect, 2, 5);
    //rect(0, 0, 250, 350);
    //Text.label("Entity - Item", 5, 5, 1.5);
    //Text.box("Descr\nTest\nDamage=5", new Rect(0, 200, 250, 150), 1.5, 10);
    //Shapes.trapezoid(new PVector(), 100, 50, 30, Direction.RIGHT);
  }
  Draw.end();

  Text.label("Particles: " + Particle.all.size(), 20, 20, 3);
  Text.label("Direction: " + dirTest.name(), 20, 100, 3);

  vel = new PVector(pmouseX - mouseX, pmouseY - mouseY);

  Draw.start();
  {
    Colours.stroke(0);
    Colours.strokeWeight(4);
    Colours.fill(100, 255, 200);
    Shapes.cross(new PVector(mouseX, mouseY + 40), 40, 10, true);

    Colours.stroke(0);
    Colours.strokeWeight(4);
    Shapes.bullet(new PVector(mouseX + 40, mouseY), 20, 60, Colours.create(245, 96, 47), Colours.create(212, 162, 61), true);
  }
  Draw.end();
}

PVector vel;
Direction dirTest = Direction.UP;

void keyPressed()
{
  Menu menu = Menus.current();

  if (isCabinet)
    pollCabinetControls(menu);
  else
    pollDesktopControls(menu);
}

void keyReleased()
{
  if (isCabinet)
    releaseCabinetControls();
  else
    releaseDesktopControls();
}

void mousePressed()
{
  //if (mouseButton == RIGHT)
  //{
  //  Game.end();
  //  Menus.gameOver.open();
  //}
  //Game.selectedPlayer().give(new Card(CardData.get(IDs.Entity.Item.OddMachine)));
  //dirTest = Direction.rotate(dirTest, 1);
  //else if (mouseButton == RIGHT)
  //  dirTest = Direction.rotate(dirTest, -1);
}

void mouseWheel()
{
  //new CardParticle(Game.selectedPlayer().cards.get(0));
  //Game.selectedPlayer().cards.remove(0);
  //println("Mouse: (" + mouseX + ", " + mouseY + ")");
  //CardParticle part = new CardParticle(new Card(CardData.get(IDs.Entity.Item.OddMachine), new PVector(mouseX, mouseY)));
  //part.velocity.add(vel.copy().mult(-15));
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
    {
      key = 0;
      menu.select();
    }
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

    if (key == '1')
      showControls = true;
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

  if (key == '1')
    showControls = false;
}


void pollDesktopControls(Menu menu)
{

  // Map the left stick to the directions
  if (key == 'w' || key == 'W')
    menu.onInput(Direction.UP);
  else if (key == 'd' || key == 'D')
    menu.onInput(Direction.RIGHT);
  else if (key == 's' || key == 'S')
    menu.onInput(Direction.DOWN);
  else if (key == 'a' || key == 'A')
    menu.onInput(Direction.LEFT);

  if (key == CODED)
  {
    // Pan the map around
    if (keyCode == UP)
      mapUp = true;
    else if (keyCode == RIGHT)
      mapRight = true;
    else if (keyCode == DOWN)
      mapDown = true;
    else if (keyCode == LEFT)
      mapLeft = true;

    if (keyCode == SHIFT)
      menu.back();
  }

  // Zoom the map
  else if (key == 'f' || key == 'F')
    mapZoomOut = true;
  else if (key == 'r' || key == 'R')
    mapZoomIn = true;

  // Alt controls for desktop
  if (key == BACKSPACE)
    menu.back();
  else if (key == ENTER || key == ' ')
    menu.select();

  if (key == ESC)
  {
    key = 0;
    menu.back();
  }

  if (key == TAB)
    showControls = true;
}

void releaseDesktopControls()
{
  if (key == CODED)
  {
    // Pan the map around
    if (keyCode == UP)
      mapUp = false;
    else if (keyCode == RIGHT)
      mapRight = false;
    else if (keyCode == DOWN)
      mapDown = false;
    else if (keyCode == LEFT)
      mapLeft = false;
  }

  if (key == 'f' || key == 'F')
    mapZoomOut = false;
  else if (key == 'r' || key == 'R')
    mapZoomIn = false;

  if (key == TAB)
    showControls = false;
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
