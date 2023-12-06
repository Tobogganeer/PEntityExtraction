static class Board
{
  // Just shoving these here for now. Probably fine, eh?
  static PVector desiredInput = new PVector();
  static float desiredZoom;

  static final int pixelHeight = 650;
  static final float centerX = Applet.width / 2;
  static final float centerY = pixelHeight / 2;
  static PVector centerPixel() { // Yeah I am putting it up here. Fight me.
    return new PVector(centerX, centerY);
  }

  float zoom;
  PVector pan;
  HashMap<PVectorInt, Tile> tiles;

  Board()
  {
    zoom = 0.5;
    pan = new PVector();
    tiles = new HashMap<PVectorInt, Tile>();
  }

  // =========================================================== Setup =========================================================== //

  void generate(BoardSize size)
  {
    // TODO: Actual level generation
    // String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Connection... connections
    TileData topLeft = new TileData("Top Left", "hall.topleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.DOWN));
    TileData topRight = new TileData("Top Right", "hall.topright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.DOWN));
    TileData bottomLeft = new TileData("Bottom Left", "hall.bottomleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.UP)); // Invalid on purpose VVV
    TileData bottomRight = new TileData("Bottom Right", "hall.bottomright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.UP), new Connection(Direction.RIGHT));

    tiles.put(new PVectorInt(0, 1), new Tile(new PVectorInt(0, 1), topLeft));
    tiles.put(new PVectorInt(1, 1), new Tile(new PVectorInt(1, 1), topRight));
    tiles.put(new PVectorInt(0, 0), new Tile(new PVectorInt(0, 0), bottomLeft));
    tiles.put(new PVectorInt(1, 0), new Tile(new PVectorInt(1, 0), bottomRight));
    tiles.put(new PVectorInt(2, 0), new Tile(new PVectorInt(2, 0), bottomRight).rotate(2));

    // Place the players
    initPlayers(new PVectorInt(0, 0));
  }

  // Places all players on this tile
  void initPlayers(PVectorInt position)
  {
    for (Player p : Game.players())
      p.init(position.copy());
  }


  // =========================================================== Drawing =========================================================== //

  void draw()
  {
    updateZoomAndPan();

    Rect window = new Rect(0, 0, Applet.width, pixelHeight);
    //PApplet app = Applet.get();

    Draw.start(); // Window
    {
      Colours.fill(0);
      window.draw();

      Draw.start(pan.x + centerX, pan.y + centerY, 0, zoom); // Board pan/zoom
      {
        drawTiles();
      }
      Draw.end(); // Board pan/zoom
    }
    Draw.end(); // Window
  }

  void drawTiles()
  {
    for (Tile t : tiles.values())
    {
      Draw.start(getWorldPosition(t.position));
      {
        t.draw();
        ArrayList<Player> playersOnThisTile = playersOnTile(t.position);
        for (int i = 0; i < playersOnThisTile.size(); i++)
        {
          //PVector offset = Maths.getVertex(i, playersOnThisTile.size());
          // Keep a constant offset, even when solo
          PVector offset = Maths.getVertex(playersOnThisTile.get(i).playerNumber, Game.numPlayers());
          offset.mult(Tile.playerDrawOffset);
          playersOnThisTile.get(i).draw(offset);
        }
      }
      Draw.end();
    }
  }


  // =========================================================== Input =========================================================== //

  void updateZoomAndPan()
  {
    pan.add(desiredInput.copy().mult(Time.deltaTime * 250 * zoom));
    zoom += desiredZoom * Time.deltaTime;
  }


  // =========================================================== Maths =========================================================== //

  PVector getWorldPosition(PVectorInt position)
  {
    if (position == null) return new PVector();

    PVector wp = position.vec.copy().mult(Tile.pixelSize);
    wp.y = -wp.y; // Invert y so positive is up
    return wp;
  }


  // =========================================================== Tiles =========================================================== //

  Tile getTile(PVectorInt position)
  {
    if (!tiles.containsKey(position))
    {
      Popup.show("Tried to get invalid tile: (" + position.x() + ", " + position.y() + ").", 3);
      return null;
    }

    return tiles.get(position);
  }

  Tile getTile(PVectorInt position, Direction direction)
  {
    PVectorInt targetPos = position.copy().add(direction.getOffset());
    return getTile(targetPos);
  }

  boolean exists(PVectorInt position)
  {
    return tiles.containsKey(position);
  }

  boolean exists(PVectorInt position, Direction direction)
  {
    PVectorInt targetPos = position.copy().add(direction.getOffset());
    return tiles.containsKey(targetPos);
  }


  // =========================================================== Players =========================================================== //

  ArrayList<Player> playersOnTile(Tile tile)
  {
    if (tile == null)
      return new ArrayList<Player>();
    return playersOnTile(tile.position);
  }

  ArrayList<Player> playersOnTile(PVectorInt position)
  {
    ArrayList<Player> localPlayers = new ArrayList<Player>();

    if (position == null)
      return localPlayers;

    for (Player p : Game.players())
    {
      if (p.position.equals(position))
        localPlayers.add(p);
    }

    return localPlayers;
  }
}
