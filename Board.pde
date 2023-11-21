static class Board
{
  // TODO: Impl

  void draw()
  {
    PApplet app = Applet.get();
    drawSpinningText(app);
    drawAlignTest(app);
    drawBoxTest(app);
  }

  void drawSpinningText(PApplet app)
  {
    Draw.start(600, 400, sin(app.frameCount * 0.1) * 15);
    {
      app.fill(0);
      //Font.current.get('a').draw(0, 0, 7);
      Text.align(TextAlign.Center);
      Text.label("SPIN!", 0, 0, 9);
      Text.label("(booya)", 0, 50, 3);
    }
    Draw.end();
  }

  void drawAlignTest(PApplet app)
  {
    Draw.start();
    {
      PVector pos = new PVector(800, 800);
      app.rectMode(CENTER);
      app.fill(255, 0, 0);
      app.rect(pos.x, pos.y, 200, 4);
      app.rect(pos.x, pos.y, 4, 80);

      app.fill(0);
      Text.align(TextAlign.TopLeft);
      Text.label("Top Left", pos, 4);
      Text.align(TextAlign.BottomRight);
      Text.label("Bottom Right", pos, 4);
      app.stroke(255);
      app.strokeWeight(0.5);
      Text.align(TextAlign.Center);
      Text.label("Center", pos, 4);
    }
    Draw.end();
  }

  void drawBoxTest(PApplet app)
  {
    Text.align(TextAlign.TopLeft);
    drawBox(new Rect(200, 160, 200, 100), app, "[Top Left]\nThese are the text\nalignment tests");
    Text.align(TextAlign.Center);
    drawBox(new Rect(200, 260, 200, 100), app, "[Center]\nFor boxes");
    Text.align(TextAlign.BottomRight);
    drawBox(new Rect(200, 360, 200, 100), app, "[Bottom Right]\nNot bad, eh?");
  }

  void drawBox(Rect r, PApplet app, String label)
  {
    Draw.start();
    {
      app.stroke(0);
      app.noFill();
      r.draw();

      app.noStroke();
      app.fill(0);
      Text.box(label, r, 2, 5);
    }
    Draw.end();
  }
}
