static class Tile
{
  static final float pixelSize = 350;
  static final float connectionWidthB = 250;
  static final float connectionWidthT = 150;
  static final float connectionHeight = 40;

  static final float playerDrawOffset = 70;

  final PVectorInt position;
  final HashSet<Player> visitedBy;
  final CardData data;

  Connection[] connections; // These are rotated and should be used instead of data.connections[]
  Tile[] neighbours; // Tiles that we are connected to

  final ArrayList<Player> currentPlayers;
  final ArrayList<Entity> currentEntities;

  Tile(PVectorInt position, CardData data)
  {
    this.position = position;
    this.visitedBy = new HashSet<Player>();
    this.data = data;

    // Rooms don't have pre-set connections, so only init them if we are a hall
    if (data instanceof TileData)
    {
      TileData tileData = (TileData)data;
      this.connections = new Connection[tileData.connections.length];
      for (int i = 0; i < connections.length; i++)
        connections[i] = tileData.connections[i].copy();
    }

    currentPlayers = new ArrayList<Player>();
    currentEntities = new ArrayList<Entity>();
  }

  // Called after all tiles have been placed and created
  void init(Board board)
  {
    boolean isRoom = data.type == CardType.ROOM;

    ArrayList<Tile> neighbourList = new ArrayList<Tile>();
    for (Direction d : Direction.values())
    {
      // If there is a tile in this direction
      if (board.exists(position, d))
      {
        Tile other = board.get(position, d);
        // If we both connect together
        if (connectsTo(other))
          neighbourList.add(other);
        // If we are a room and it connects to us
        else if (isRoom && other.hasConnection(d.opposite()))
          neighbourList.add(other);
        // If it is a room and we connect to it
        else if (hasConnection(d) && other.data.type == CardType.ROOM)
          neighbourList.add(other);
      }
    }

    neighbours = neighbourList.toArray(new Tile[0]);

    // If we are a room, connect to all neighbours
    if (isRoom)
    {
      // TODO: Maybe make rooms only connect to one hall, instead of all of them?
      connections = new Connection[neighbours.length];
      for (int i = 0; i < connections.length; i++)
        connections[i] = new Connection(position.dir(neighbours[i].position), ConnectionType.NORMAL);
    }
  }

  // Called when a player/entity moves onto/off of this tile
  void update()
  {
    // Go through all players
    for (Player p : Game.players())
    {
      // Did they just move to this tile?
      if (p.position.equals(position) && !currentPlayers.contains(p))
      {
        currentPlayers.add(p);
        onEntry(p);
        // Have they visited yet?
        if (!hasVisited(p))
        {
          visitedBy.add(p);
          onFirstEntry(p);
        }
      }

      // Did they just move off of this tile?
      else if (!p.position.equals(position) && currentPlayers.contains(p))
      {
        // Remove them from the list
        currentPlayers.remove(p);
      }
    }

    for (Entity e : Game.entities())
    {
      // Just moved to this tile
      if (e.position.equals(position) && !currentEntities.contains(e))
      {
        currentEntities.add(e);
        onEntry(e);
      }

      // Just moved off
      else if (!e.position.equals(position) && currentEntities.contains(e))
      {
        // Remove them from the list
        currentEntities.remove(e);
      }
    }
  }

  // Overriden by subclasses
  void onFirstEntry(Player player) {
  }

  void onEntry(Player player) {
  }

  void onEntry(Entity entity)
  {
    // There are players on this tile
    if (currentPlayers.size() > 0)
    {
      for (Player p : currentPlayers)
      {
        // onContact effects are applied in the player context
        Context ctx = new Context(ContextType.PLAYER, null, this, p, entity);
        for (Effect e : entity.data.onContact)
        {
          // Apply all onContact effects to each player
          p.executeEffect(e, ctx);
        }
      }
    }
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
    drawConnections();
  }

  void drawConnections()
  {
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
    if (connections == null)
      return null;

    for (Connection c : connections)
    {
      if (c.direction == dir)
        return c;
    }
    return null;
  }

  // Checks if we can travel in this direction (tile exists and connections aren't locked)
  boolean canTravel(Direction dir)
  {
    if (!Game.board().exists(position, dir))
      return false;
    Tile other = Game.board().get(position, dir);
    if (!connectsTo(other))
      return false;
    return isPathClearToNeighbour(other);
  }

  // Assumes that neighbour is next to and connected to this tile, and just checks if the path is locked
  // Intent is to be used for pathfinding to avoid the cost of canTravel() when we are just
  // checking our neighbour array
  boolean isPathClearToNeighbour(Tile neighbour)
  {
    Direction dir = position.dir(neighbour.position);
    return !getConnection(dir).isLocked() && !neighbour.getConnection(dir.opposite()).isLocked();
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







// ============================================== Subclasses =====================================================

// AIRLOCK, HALL, COMPLEXHALL, ROOM

static class AirlockTile extends Tile
{
  AirlockData airlockData;

  AirlockTile(PVectorInt position, AirlockData data)
  {
    super(position, data);
    this.airlockData = data;
  }

  void update()
  {
    super.update();

    // Get the other airlock
    Tile otherAirlock;
    if (airlockData.airlockNumber == 1)
      otherAirlock = Game.board().get(IDs.Tile.Airlock.Airlock2);
    else
      otherAirlock = Game.board().get(IDs.Tile.Airlock.Airlock1);

    // We need both airlocks! If the other one doesn't exist, something is very wrong
    if (otherAirlock == null)
    {
      Popup.show("Error: Didn't find other airlock? Source: " + airlockData.id, 5);
      Game.end();
      return;
    }

    // Something is on the other airlock
    boolean otherAirlockIsOccupied = otherAirlock.currentPlayers.size() > 0 || otherAirlock.currentEntities.size() > 0;
    //if (otherAirlockIsOccupied)
    //  println("Airlock " + airlockData.airlockNumber + ": Other occupied? " + otherAirlockIsOccupied);
    for (Connection c : connections)
    {
      if (c.type == ConnectionType.AIRLOCK)
        c.locked = otherAirlockIsOccupied;
    }
  }

  void draw()
  {
    // TODO: Custom drawing
    super.draw();
  }
}

static class HallTile extends Tile
{
  HallData hallData;

  HallTile(PVectorInt position, HallData data)
  {
    super(position, data);
    this.hallData = data;
  }

  void draw()
  {
    // TODO: Custom drawing
    super.draw();
  }
}

static class ComplexHallTile extends Tile
{
  ComplexHallData complexHallData;

  ComplexHallTile(PVectorInt position, ComplexHallData data)
  {
    super(position, data);
    this.complexHallData = data;
  }

  void onFirstEntry(Player player)
  {
    Context ctx = new Context(player, this);
    for (Effect e : complexHallData.onFirstEntry)
      player.executeEffect(e, ctx);
  }

  void onEntry(Player player)
  {
    Context ctx = new Context(player, this);
    for (Effect e : complexHallData.onAnyEntry)
      player.executeEffect(e, ctx);
  }

  void draw()
  {
    // TODO: Custom drawing
    super.draw();
  }
}

static class RoomTile extends Tile
{
  RoomData roomData;
  boolean discovered;

  RoomTile(PVectorInt position, RoomData data)
  {
    super(position, data);
    this.roomData = data;
  }

  void discover(Player player)
  {
    discovered = true;

    // player might be null here, and that's okay!
    Context ctx = new Context(player, this);
    for (Effect e : roomData.onFirstEntry)
      EffectExecutor.execute(e, ctx);

    // Clear the players that have visited us so onFirstEntry effects work
    visitedBy.clear();
    // Update the tile: See what players have entered, etc
    update();
  }

  void onFirstEntry(Player player)
  {
    // No effects if we aren't flipped yet
    if (!discovered)
      return;

    Context ctx = new Context(player, this);
    for (Effect e : roomData.onFirstEntry)
      player.executeEffect(e, ctx);
  }

  void onEntry(Player player)
  {
    if (!discovered)
      return;

    Context ctx = new Context(player, this);
    for (Effect e : roomData.onAnyEntry)
      player.executeEffect(e, ctx);
  }

  void draw()
  {
    // TODO: Custom drawing
    if (discovered)
      super.draw();
    else
    {
      Colours.fill(255);
      rect().draw(30);
      Colours.fill(180);
      Text.align(TextAlign.CENTER);
      Text.label("Undiscovered Room", 0, 0, 3);

      drawConnections();
    }
  }
}
