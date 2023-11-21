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
 39 7  6  5  3  1
 
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
  noStroke();

  drawSpinningText();
  drawAlignTest();
  drawBoxTest();
}

void drawSpinningText()
{
  Draw.start(600, 400, sin(frameCount * 0.1) * 15);
  {
    fill(0);
    //Font.current.get('a').draw(0, 0, 7);
    Text.align(TextAlign.Center);
    Text.draw("SPIN!", 0, 0, 9);
    Text.draw("(booya)", 0, 50, 3);
  }
  Draw.end();
}

void drawAlignTest()
{
  Draw.start();
  {
    PVector pos = new PVector(800, 800);
    rectMode(CENTER);
    fill(255, 0, 0);
    rect(pos.x, pos.y, 200, 4);
    rect(pos.x, pos.y, 4, 80);

    fill(0);
    Text.align(TextAlign.TopLeft);
    Text.draw("Top Left", pos, 4);
    Text.align(TextAlign.BottomRight);
    Text.draw("Bottom Right", pos, 4);
    stroke(255);
    strokeWeight(0.5);
    Text.align(TextAlign.Center);
    Text.draw("Center", pos, 4);
  }
  Draw.end();
}

void drawBoxTest()
{
  Text.align(TextAlign.TopLeft);
  drawBox(new Rect(200, 160, 200, 100), "[Top Left]\nThese are the text\nalignment tests");
  Text.align(TextAlign.Center);
  drawBox(new Rect(200, 260, 200, 100), "[Center]\nFor boxes");
  Text.align(TextAlign.BottomRight);
  drawBox(new Rect(200, 360, 200, 100), "[Bottom Right]\nNot bad, eh?");
}

void drawBox(Rect r, String label)
{
  Draw.start();
  {
    stroke(0);
    noFill();
    r.draw();

    noStroke();
    fill(0);
    Text.box(label, r, 2, 5);
  }
  Draw.end();
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
