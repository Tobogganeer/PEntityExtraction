static class Board
{
  // Just shoving these here for now. Probably fine, eh?
  static PVector desiredInput = new PVector();
  static float desiredZoom;

  static final int pixelHeight = 650;
  static final float centerX = Applet.width / 2;
  static final float centerY = pixelHeight / 2;
  static PVector centerPixel()
  {
    return new PVector(centerX, centerY);
  }

  float zoom;
  PVector pan;
  HashMap<PVectorInt, Tile> tiles;

  Board()
  {
    zoom = 1;
    pan = new PVector();
    tiles = new HashMap<PVectorInt, Tile>();
  }

  void generate(BoardSize size)
  {
    // TODO: Actual level generation
    // String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Connection... connections
    TileData topLeft = new TileData("Top Left", "hall.topleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.DOWN));
    TileData topRight = new TileData("Top Right", "hall.topright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.DOWN));
    TileData bottomLeft = new TileData("Bottom Left", "hall.bottomleft", null, null, CardType.HALL, 1, null, new Connection(Direction.RIGHT), new Connection(Direction.UP));
    TileData bottomRight = new TileData("Bottom Right", "hall.bottomright", null, null, CardType.HALL, 1, null, new Connection(Direction.LEFT), new Connection(Direction.UP));

    tiles.put(new PVectorInt(0, 1), new Tile(new PVectorInt(0, 1), topLeft));
    tiles.put(new PVectorInt(1, 1), new Tile(new PVectorInt(1, 1), topRight));
    tiles.put(new PVectorInt(0, 0), new Tile(new PVectorInt(0, 0), bottomLeft));
    tiles.put(new PVectorInt(1, 0), new Tile(new PVectorInt(1, 0), bottomRight));
  }

  void draw()
  {
    updateZoomAndPan();

    Rect window = new Rect(0, 0, Applet.width, pixelHeight);
    //PApplet app = Applet.get();

    Draw.start();
    {
      Colours.fill(0);
      window.draw();

      for (Tile t : tiles.values())
      {
        Draw.start(getBoardPosition(getWorldPosition(t.position)), 0, zoom);
        {
          t.draw();
        }
        Draw.end();
      }
    }
    Draw.end();
  }

  PVector getWorldPosition(PVectorInt position)
  {
    return position.vec.copy().mult(Tile.pixelSize);
  }

  PVector getBoardPosition(PVector position)
  {
    position = position.copy();
    position.y = -position.y; // Invert y so positive is up
    // Haven't tested but I think adding the pan before zooming makes more sense
    return position.add(pan).mult(zoom).add(centerPixel());
  }

  void updateZoomAndPan()
  {
    pan.add(desiredInput.copy().mult(Time.deltaTime * 100));
    zoom += desiredZoom * Time.deltaTime;
  }
}

static class Tile
{
  static final float pixelSize = 350;
  static final float connectionWidthB = 250;
  static final float connectionWidthT = 150;
  static final float connectionHeight = 40;

  final PVectorInt position;
  final HashSet<Player> visitedBy;
  final TileData data;

  Tile(PVectorInt position, TileData data)
  {
    this.position = position;
    this.visitedBy = new HashSet<Player>();
    this.data = data;
  }

  Rect rect()
  {
    return new Rect(-pixelSize / 2, -pixelSize / 2, pixelSize, pixelSize);
  }

  void draw()
  {
    // TODO: Change this/remove the body and make subclasses override it
    Colours.fill(255);
    rect().draw(30);
    Colours.fill(180);
    Text.align(TextAlign.CENTER);
    Text.label(data.name, 0, 0, 3);
    for (Connection c : data.connections)
      drawConnection(c);
  }

  void drawConnection(Connection c)
  {
    PVector offset = c.direction.getOffset();
    // Near the border but with an offset so it isn't hanging over the side
    PVector center = offset.copy().mult(pixelSize / 2).sub(offset.copy().mult(connectionHeight / 2));
    center.y = -center.y; // Coords are upside-down
    Shapes.trapezoid(center, connectionWidthB, connectionWidthT, connectionHeight, c.direction.opposite());
  }

  boolean hasVisited(Player player)
  {
    return visitedBy.contains(player);
  }

  boolean hasConnection(Direction dir)
  {
    for (Connection c : data.connections)
      if (c.direction == dir)
        return true;
    return false;
  }
}



static class Connection
{
  static final String ID_direction = "direction";
  static final String ID_type = "type";

  Direction direction;
  ConnectionType type;

  Connection(Direction direction, ConnectionType type)
  {
    this.direction = direction;
    this.type = type;
  }

  Connection(Direction direction)
  {
    this.direction = direction;
    this.type = ConnectionType.NORMAL;
  }

  Connection(JSONObject obj) throws InvalidCardException
  {
    if (!obj.hasKey(ID_direction))
      throw new InvalidCardException("Tried to parse Connection that didn't have a direction.");

    direction = JSON.getEnum(Direction.class, obj.getString(ID_direction));
    // If they don't include a type, assume it is just a normal door
    type = JSON.getEnum(ConnectionType.class, obj.getString(ID_type, ConnectionType.NORMAL.name()));

    if (direction == null || type == null)
      throw new InvalidCardException("Tried to parse Connection with an invalid direction/type.");
  }

  boolean canConnectTo(Connection connection)
  {
    return this.direction.oppositeTo(connection.direction);
  }

  JSONObject toJSON()
  {
    JSONObject obj = new JSONObject();

    obj.setString(ID_direction, direction.name());
    obj.setString(ID_type, type.name());

    return obj;
  }

  static Connection[] fromJSONArray(JSONArray jsonConnections) throws InvalidCardException
  {
    Connection[] connections = new Connection[jsonConnections.size()];
    for (int i = 0; i < connections.length; i++)
      connections[i] = new Connection(jsonConnections.getJSONObject(i));
    return connections;
  }

  static JSONArray toJSONArray(Connection[] conns)
  {
    JSONArray jsonConnections = new JSONArray();
    if (conns == null || conns.length == 0)
      return jsonConnections;

    for (Connection c : conns)
      jsonConnections.append(c.toJSON());
    return jsonConnections;
  }
}
