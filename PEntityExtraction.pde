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
39 38 36 35 34 29 20 16
11  9  7  6  5  3  1

*/




void setup()
{
  size(1280, 1024);
  Applet.init(this);
  Text.init();
}

void draw()
{
  Time.update();
  Popup.update();
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
