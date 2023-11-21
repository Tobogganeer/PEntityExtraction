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

import java.util.Stack;
import java.util.HashMap;
import java.util.Arrays;


boolean desktopMode = true;



void setup()
{
  size(1280, 1024);
  Applet.init(this);

  Font.load();

  Game.create();
  Menus.initTitleMenus();
  Menus.mainMenu.open();
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
