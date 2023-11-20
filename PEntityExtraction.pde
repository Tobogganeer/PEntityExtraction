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
  Font.load();
}

void draw()
{
  Time.update();
  Popup.update();
  
  background(255);
  fill(0);
  noStroke();
  Draw.start(100, 100, frameCount);
  Font.current.get('a').draw(0, 0, 7);
  Draw.end();
  
  PVector pos = new PVector(200, 200);
  rectMode(CENTER);
  fill(255, 0, 0);
  rect(pos.x, pos.y, 200, 4);
  rect(pos.x, pos.y, 4, 80);
  
  fill(0);
  Text.align(TextAlign.TopLeft);
  Text.draw("Top Left", pos, 4);
  Text.align(TextAlign.BottomRight);
  Text.draw("Bottom Right", pos, 4);
  fill(0, 200, 0);
  Text.align(TextAlign.Center);
  Text.draw("Center", pos, 4);
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
