static class Board
{
  static final int height = 650;
  // TODO: Impl

  Board(BoardSize size)
  {
  }

  void generate()
  {
  }

  void draw()
  {
    Rect window = new Rect(0, 0, Applet.width, height);
    PApplet app = Applet.get();
    
    Draw.start();
    {
      Colours.fill(0);
      window.draw();
    }
    Draw.end();
  }
}
