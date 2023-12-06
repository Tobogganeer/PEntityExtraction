static class Tile
{
  static final float pixelSize = 350;
  static final float connectionWidthB = 250;
  static final float connectionWidthT = 150;
  static final float connectionHeight = 40;

  static final float playerDrawOffset = 70;

  final PVectorInt position;
  final HashSet<Player> visitedBy;
  final TileData data;
  final Connection[] connections; // These are rotated and should be used instead of data.connections[]

  Tile(PVectorInt position, TileData data)
  {
    this.position = position;
    this.visitedBy = new HashSet<Player>();
    this.data = data;
    this.connections = new Connection[data.connections.length];
    for (int i = 0; i < connections.length; i++)
      connections[i] = data.connections[i].copy();
  }

  Tile rotate(int count)
  {
    for (Connection c : connections)
      c.rotate(count);
    return this;
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
    for (Connection c : connections)
      drawConnection(c);
  }

  void drawConnection(Connection c)
  {
    PVector offset = c.direction.getOffset();
    // Near the border but with an offset so it isn't hanging over the side
    PVector center = offset.copy().mult(pixelSize / 2).sub(offset.copy().mult(connectionHeight / 2));
    center.y = -center.y; // Coords are upside-down
    Shapes.trapezoid(center, connectionWidthB, connectionWidthT, connectionHeight, c.direction.opposite());
    // TODO: Draw connection icon
  }

  boolean hasVisited(Player player)
  {
    return visitedBy.contains(player);
  }

  boolean connectsTo(Tile other)
  {
    if (!position.adjacentTo(other.position))
      return false;
    Direction dir = position.dir(other.position); // Won't be null because we are adjacent
    return hasConnection(dir) && other.hasConnection(dir.opposite());
  }

  boolean hasConnection(Direction dir)
  {
    return getConnection(dir) != null;
  }

  Connection getConnection(Direction dir)
  {
    for (Connection c : connections)
      if (c.direction == dir)
        return c;
    return null;
  }

  // Checks if we can travel in this direction (tile exists and connections aren't locked)
  boolean canTravel(Direction dir)
  {
    if (!Game.board().exists(position, dir))
      return false;
    Tile other = Game.board().getTile(position, dir);
    if (!connectsTo(other))
      return false;
    return !getConnection(dir).isLocked() && !other.getConnection(dir.opposite()).isLocked();
  }
}



static class Connection
{
  static final String ID_direction = "direction";
  static final String ID_type = "type";

  Direction direction;
  ConnectionType type;
  boolean locked;

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

  Connection copy()
  {
    return new Connection(direction, type);
  }

  void rotate(int count)
  {
    direction = Direction.rotate(direction, count);
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

  boolean isLocked()
  {
    return locked && (type == ConnectionType.LOCKABLE || type == ConnectionType.AIRLOCK);
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
