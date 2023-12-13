static class Shapes
{
  static void triangle(PVector position, float width, float height, Direction direction)
  {
    // Rotation seems a bit wonky? idk
    Draw.start(position, direction.getAngle());
    {
      Applet.get().triangle(-width / 2, 0, width / 2, 0, 0, -height);
    }
    Draw.end();
  }
  
  static void arrow(PVector position, float tipWidth, float tipLength, float lineWidth, float lineLength, Direction direction)
  {
    Draw.start(position, direction.getAngle());
    {
      float length = tipLength + lineLength;
      float y = -length / 2 + tipLength;
      Applet.get().triangle(-tipWidth / 2, y, tipWidth / 2, y, 0, y - tipLength);
      Applet.get().rectMode(CORNER);
      Applet.get().rect(-lineWidth / 2, y, lineWidth, lineLength);
    }
    Draw.end();
  }

  static void cross(PVector center, float size, float thickness, boolean stroke)
  {
    Draw.start(center);
    {
      if (!stroke)
        Colours.noStroke();
      Applet.get().rectMode(CENTER);
      Applet.get().rect(0, 0, size, thickness);
      Applet.get().rect(0, 0, thickness, size);
    }
    Draw.end();

    if (stroke)
      cross(center, size, thickness, false);
  }

  static void bullet(PVector center, float width, float height, color tipColour, color bodyColour, boolean stroke)
  {
    Draw.start(center);
    {
      PApplet app = Applet.get();
      float tipHeight = height / 3;
      float tipY = (-height + tipHeight * 2) / 2;
      app.rectMode(CENTER);
      app.ellipseMode(CENTER);
      if (!stroke)
        Colours.noStroke();
      else
        app.strokeJoin(BEVEL);

      Colours.fill(tipColour);
      app.ellipse(0, tipY, width, tipHeight * 2);

      Colours.fill(bodyColour);
      float bottomHeight = height / 10; // Bottom
      app.rect(0, height / 2 - bottomHeight / 2, width, bottomHeight);

      float gapHeight = height / 15;
      float bottomOfGap = height / 2 - bottomHeight; // Gap
      float topOfGap = height / 2 - bottomHeight - gapHeight;
      float gapBottomMult = 0.6;
      float edge = width / 2;
      app.quad(-edge * gapBottomMult, bottomOfGap, edge * gapBottomMult, bottomOfGap, edge, topOfGap, -edge, topOfGap);

      float midHeight = topOfGap - tipY;
      float midY = (midHeight - tipHeight) / 2;
      app.rect(0, midY, width, midHeight);
      
      // Force stroke on for the line bc all bullets will have it bc I said so
      app.stroke(0);
      app.strokeWeight(1.5);
      app.line(-width / 2, tipY, width / 2, tipY);

      /*
      float tipHeight = height / 2;
       Colours.noStroke();
       Colours.fill(100);
       Applet.get().rectMode(CENTER);
       Applet.get().rect(0, 0, width, height - tipHeight);
       Applet.get().ellipseMode(CENTER);
       Applet.get().ellipse(0, (-height + tipHeight) / 2, width, tipHeight * 2);
       */
      //float baseY = (-height + tipHeight) / 2;
      //Applet.get().triangle(width / 2, baseY, -width / 2, baseY, 0, -height);
    }
    Draw.end();

    if (stroke)
      bullet(center, width, height, tipColour, bodyColour, false);
  }

  static void trapezoid(PVector center, float bottomWidth, float topWidth, float height, Direction direction)
  {
    float halfBW = bottomWidth / 2;
    float halfTW = topWidth / 2;
    float halfHeight = height / 2;
    Draw.start(center, direction.getAngle());
    {
      Applet.get().quad(halfBW, halfHeight, -halfBW, halfHeight, -halfTW, -halfHeight, halfTW, -halfHeight);
    }
    Draw.end();
  }
}
