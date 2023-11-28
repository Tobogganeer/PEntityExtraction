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

  static void cross(PVector center, float size, float thickness)
  {
    Draw.start(center);
    {
      Applet.get().rectMode(CENTER);
      Applet.get().rect(0, 0, size, thickness);
      Applet.get().rect(0, 0, thickness, size);
    }
    Draw.end();
  }

  static void bullet(PVector center, float width, float height)
  {
    Draw.start(center);
    {
      float tipHeight = height / 3;
      Applet.get().rectMode(CENTER);
      Applet.get().rect(0, 0, width, height - tipHeight);
      Applet.get().triangle(width / 2, height - tipHeight, -width / 2, height - tipHeight, 0, height);
    }
    Draw.end();
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
