static class Board
{
  // TODO: Impl

  Board(BoardSize size)
  {
  }

  void generate()
  {
  }

  void draw(Rect window)
  {
    PApplet app = Applet.get();
    
    Draw.start();
    {
      Colours.fill(0);
      window.draw();
    }
    Draw.end();
  }
}
