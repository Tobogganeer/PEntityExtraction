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

  float targetZoom;
  PVector targetPan;

  float zoom;
  PVector pan;
  HashMap<PVectorInt, Tile> tiles;
  PathMapCache pathMapCache;

  Board()
  {
    targetZoom = 0.5;
    targetPan = new PVector();

    zoom = targetZoom;
    pan = targetPan.copy();
    tiles = new HashMap<PVectorInt, Tile>();
    pathMapCache = new PathMapCache(this);
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

    panTo(get(IDs.Tile.Room.Gate).position);

    // Place the players
    initPlayers(get(IDs.Tile.Room.Gate).position);
    Game.current.spawnEntity(new PVectorInt(-2, 0), EntityData.all.get(IDs.Entity.Lank));

    flipStartingTiles();

    // Update them tiles
    updateTiles();

    // Generate path map cache
    pathMapCache.calculatePaths();
  }

  // Connects rooms to halls and stores neighbours
  void initTiles()
  {
    for (Tile t : tiles.values())
      t.init(this);
  }

  void flipStartingTiles()
  {
    for (Tile t : tiles.values())
    {
      if (t.data.hasTag(IDs.Tag.StartDiscovered))
        ((RoomTile)t).discover(null);
    }
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
    for (Tile t : tiles.values())
      t.postUpdate(); // Dang airlocks
  }

  void updateActualPaths()
  {
    pathMapCache.calculateActualPaths();
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

        drawEntities(t); // Draw entities underneath players
        drawPlayers(t);
      }
      Draw.end();
    }
  }

  void drawPlayers(Tile t)
  {
    ArrayList<Player> players = t.currentPlayers;
    for (int i = 0; i < players.size(); i++)
    {
      //PVector offset = Maths.getVertex(i, playersOnThisTile.size());
      // Keep a constant offset, even when solo
      PVector offset = Maths.getVertex(players.get(i).playerNumber, Game.numPlayers());
      offset.mult(Tile.playerDrawOffset);
      players.get(i).draw(offset);
    }
  }

  void drawEntities(Tile t)
  {
    ArrayList<Entity> entities = t.currentEntities;
    for (int i = 0; i < entities.size(); i++)
    {
      // Only offset based on entities on this tile
      PVector offset = Maths.getVertex(entities.get(i).colourIndex, entities.size());
      offset.mult(Tile.entityDrawOffset);
      entities.get(i).draw(offset);
    }
  }


  // =========================================================== Input =========================================================== //

  void updateZoomAndPan()
  {
    targetPan.add(desiredInput.copy().mult(Time.deltaTime * 450));
    targetZoom += desiredZoom * Time.deltaTime;
    targetZoom = constrain(targetZoom, 0.2, 1.5); // These were found to be good values

    zoom = lerp(zoom, targetZoom, Time.deltaTime * 10);
    pan = PVector.lerp(pan, targetPan, Time.deltaTime * 10);
  }

  void panTo(PVectorInt position)
  {
    PVector newPan = position.copy().vec.mult(Tile.pixelSize);
    newPan.x = -newPan.x;
    targetPan = newPan;
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
}
