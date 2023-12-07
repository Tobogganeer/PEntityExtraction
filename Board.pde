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
    add(new Tile[]
      {
      new HallTile(new PVectorInt(0, 0), HallData.all.get(IDs.Tile.Hall._4Hall)),
      new HallTile(new PVectorInt(0, 1), HallData.all.get(IDs.Tile.Hall.Straight2Hall)).rotate(1),
      new HallTile(new PVectorInt(-1, 0), HallData.all.get(IDs.Tile.Hall._3Hall)),
      new HallTile(new PVectorInt(0, -1), HallData.all.get(IDs.Tile.Hall._3Hall)).rotate(1),
      new HallTile(new PVectorInt(0, -2), HallData.all.get(IDs.Tile.Hall._3Hall)),
      new HallTile(new PVectorInt(-1, -2), HallData.all.get(IDs.Tile.Hall._4Hall)),
      new HallTile(new PVectorInt(-1, -3), HallData.all.get(IDs.Tile.Hall.Lockable3Hall)),
      new HallTile(new PVectorInt(-2, -3), HallData.all.get(IDs.Tile.Hall.Corner2Hall)).rotate(1),
      new ComplexHallTile(new PVectorInt(0, -3), ComplexHallData.all.get(IDs.Tile.ComplexHall.Lockers)).rotate(2),
      new ComplexHallTile(new PVectorInt(1, -1), ComplexHallData.all.get(IDs.Tile.ComplexHall.Bunks)),
      new AirlockTile(new PVectorInt(1, 0), AirlockData.all.get(IDs.Tile.Airlock.Airlock1)),
      new AirlockTile(new PVectorInt(2, 0), AirlockData.all.get(IDs.Tile.Airlock.Airlock2)),
      new RoomTile(new PVectorInt(-1, 1), RoomData.all.get(IDs.Tile.Room.Breach)),
      new RoomTile(new PVectorInt(1, -2), RoomData.all.get(IDs.Tile.Room.Gate)),
      new RoomTile(new PVectorInt(0, 2), RoomData.all.get(IDs.Tile.Room.StorageRoom)),
      new RoomTile(new PVectorInt(3, 0), RoomData.all.get(IDs.Tile.Room.StorageRoom)),
      new RoomTile(new PVectorInt(2, -1), RoomData.all.get(IDs.Tile.Room.StorageRoom)),
      new RoomTile(new PVectorInt(-2, 0), RoomData.all.get(IDs.Tile.Room.Medbay)),
      new RoomTile(new PVectorInt(0, -4), RoomData.all.get(IDs.Tile.Room.Medbay)),
      new RoomTile(new PVectorInt(-1, -1), RoomData.all.get(IDs.Tile.Room.Cafeteria)),
      new RoomTile(new PVectorInt(-2, -2), RoomData.all.get(IDs.Tile.Room.Cafeteria)),
      new RoomTile(new PVectorInt(-2, -4), RoomData.all.get(IDs.Tile.Room.Cafeteria)),
      });

    // Init all tiles once they are all placed
    initTiles();
    
    panTo(get(IDs.Tile.Room.Gate));

    // Place the players
    initPlayers(get(IDs.Tile.Room.Gate).position);

    flipStartingTiles();

    // Update them tiles
    updateTiles();
  }

  // Connects rooms to halls and stores neighbours
  void initTiles()
  {
    for (Tile t : tiles.values())
      t.init(this);
  }

  void flipStartingTiles()
  {
    ((RoomTile)get(IDs.Tile.Room.Breach)).discover(null);
    ((RoomTile)get(IDs.Tile.Room.Gate)).discover(null);
  }

  // Places all players on this tile
  void initPlayers(PVectorInt position)
  {
    for (Player p : Game.players())
      p.init(position.copy());
  }


  // =========================================================== Gameplay =========================================================== //

  void updateTiles()
  {
    for (Tile t : tiles.values())
      t.update();
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

      Draw.start(pan.x * zoom + centerX, pan.y * zoom + centerY, 0, zoom); // Board pan/zoom
      {
        //Draw.startScale(zoom);
        drawTiles();
        //Draw.end();
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
    pan.add(desiredInput.copy().mult(Time.deltaTime * 450));
    zoom += desiredZoom * Time.deltaTime;
    zoom = constrain(zoom, 0.2, 1.5); // These were found to be good values
  }
  
  void panTo(Tile t)
  {
    PVector newPan = t.position.copy().vec.mult(Tile.pixelSize);
    newPan.x = -newPan.x;
    pan = newPan;
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

  void add(ArrayList<Tile> tiles)
  {
    for (Tile t : tiles)
      add(t);
  }

  void add(Tile[] tiles)
  {
    for (Tile t : tiles)
      add(t);
  }

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
