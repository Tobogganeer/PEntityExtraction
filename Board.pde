static class Board
{
  static final int pixelHeight = 650;
  // TODO: Impl

  Board(BoardSize size)
  {
  }

  void generate()
  {
  }

  void draw()
  {
    Rect window = new Rect(0, 0, Applet.width, pixelHeight);
    PApplet app = Applet.get();

    Draw.start();
    {
      Colours.fill(0);
      window.draw();
    }
    Draw.end();
  }
}

static class Tile
{
  PVectorInt position;
  HashSet<Player> visitedBy;
  CardData data;
  
  void display() {
    
  }
}
