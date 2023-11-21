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
}
