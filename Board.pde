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
    TileData topLeft = new TileData("Top Left", "tile.hall.topleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.DOWN));
    TileData topRight = new TileData("Top Right", "tile.hall.topright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.DOWN));
    TileData bottomLeft = new TileData("Bottom Left", "tile.hall.bottomleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.UP)); // Invalid on purpose VVV
    TileData bottomRight = new TileData("Bottom Right", "tile.hall.bottomright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.UP), new Connection(Direction.RIGHT));
    
    // String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Effect[] onDiscovery, Effect[] onFirstEntry, Effect[] onAnyEntry
    Effect[] emptyEffects = new Effect[0];
    RoomData room = new RoomData("Test room", "tile.room.test", null, null, CardType.ROOM, 1, null, emptyEffects, emptyEffects, emptyEffects);

    add(new Tile(new PVectorInt(0, 1), topLeft));
    add(new Tile(new PVectorInt(1, 1), topRight));
    add(new Tile(new PVectorInt(0, 0), bottomLeft));
    add(new Tile(new PVectorInt(1, 0), bottomRight));
    add(new Tile(new PVectorInt(2, 0), bottomRight).rotate(2));
    add(new RoomTile(new PVectorInt(2, -1), room));

    // Init all tiles once they are all placed
    initTiles();

    // Place the players
    initPlayers(new PVectorInt(0, 0));
  }

  // Connects rooms to halls and stores neighbours
  void initTiles()
  {
    for (Tile t : tiles.values())
      t.init(this);
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

  void add(Tile tile)
  {
    tiles.put(tile.position, tile);
  }

  Tile get(PVectorInt position)
  {
    if (!exists(position))
    {
      Popup.show("Tried to get invalid tile: (" + position.x() + ", " + position.y() + ").", 3);
      return null;
    }

    return tiles.get(position);
  }

  Tile get(PVectorInt position, Direction direction)
  {
    PVectorInt targetPos = position.copy().add(direction.getOffset());
    return get(targetPos);
  }

  Tile get(String id)
  {
    id = id.toLowerCase().trim();

    for (Tile t : tiles.values())
      if (t.data.id.equals(id))
        return t;
    return null;
  }

  ArrayList<Tile> getAll(String id)
  {
    id = id.toLowerCase().trim();
    ArrayList<Tile> matchingTiles = new ArrayList<Tile>();

    for (Tile t : tiles.values())
      if (t.data.id.equals(id))
        matchingTiles.add(t);
    return matchingTiles;
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
    return tile.currentPlayers;
  }

  ArrayList<Player> playersOnTile(PVectorInt position)
  {
    if (!exists(position))
      return new ArrayList<Player>();

    return playersOnTile(get(position));
  }
}
