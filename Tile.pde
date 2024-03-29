static class Tile
{
  static final float pixelSize = 350;
  private static final float connectionWidthB = 200;
  private static final float connectionWidthT = 120;
  private static final float connectionHeight = 30;
  private static final float borderPadding = 48;
  private static final float elementPadding = 20;
  private static final float nameHeight = 50;

  private static final Rect rect = new Rect(-pixelSize / 2, -pixelSize / 2, pixelSize, pixelSize);
  private static final Rect contentRect = Rect.shrink(rect, borderPadding);
  private static final Rect hallNameRect = Rect.shrink(contentRect, elementPadding, 200);
  private static final Rect complexHallNameRect = hallNameRect.copy().setHeight(nameHeight).changeCenterY(-20);
  private static final Rect complexHallDescriptionRect = new Rect(complexHallNameRect.x, complexHallNameRect.y + complexHallNameRect.h + elementPadding, complexHallNameRect.w, contentRect.h + complexHallNameRect.y - nameHeight - elementPadding * 2);
  private static final Rect roomNameRect = Rect.shrink(contentRect, elementPadding).setHeight(nameHeight);
  private static final Rect roomDescriptionRect = new Rect(roomNameRect.x, roomNameRect.y + roomNameRect.h + elementPadding, roomNameRect.w, contentRect.h - nameHeight - elementPadding * 2);

  static final float playerDrawOffset = 70;
  static final float entityDrawOffset = 120;

  final PVectorInt position;
  final HashSet<Player> visitedBy;
  final CardData data;

  final Rect nameRect;
  final Rect descriptionRect;

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

    // Could the following be in subclasses? Yes. Should it be? idk lol
    if (data.type == CardType.COMPLEXHALL || data.type == CardType.AIRLOCK)
    {
      nameRect = complexHallNameRect;
      descriptionRect = complexHallDescriptionRect;
    } else if (data.type == CardType.ROOM)
    {
      nameRect = roomNameRect;
      descriptionRect = roomDescriptionRect;
    } else
    {
      // Halls
      nameRect = hallNameRect;
      descriptionRect = null;
    }
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

  void postUpdate() {
  }



  Tile rotate(int count)
  {
    for (Connection c : connections)
      c.rotate(count);
    return this;
  }

  static Rect rect()
  {
    return rect.copy();
  }

  void draw()
  {
    Draw.start();
    {
      drawPanels();
      drawName();
      drawDescription();
      drawConnections();
    }
    Draw.end();
  }

  void drawPanels()
  {
    Colours.stroke(0);
    Colours.strokeWeight(2); // Black outline
    Colours.fill(Colours.getTileBorder(data)); // Fill bg colour
    rect.draw(20);

    Colours.noStroke();
    Colours.fill(Colours.getTileFill(data));
    contentRect.draw(20); // Backdrop


    Colours.fill(Colours.white);
    nameRect.draw(10);
    if (descriptionRect != null)
      descriptionRect.draw(10);
  }

  void drawName()
  {
    Text.colour = 0;
    Text.align(TextAlign.CENTER);
    Text.strokeWeight = 0.5; // Bold it a bit
    Text.box(data.name, nameRect, 4, 5);
  }

  void drawDescription()
  {
    if (descriptionRect == null)
      return;

    Text.colour = 0;
    Text.align(TextAlign.TOPLEFT);
    Text.strokeWeight = 0;
    Text.box(data.description, descriptionRect, 2, 5);
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


    // ConnectionType.AIRLOCK is used for the special airlock doors that can be locked. I want to colour the connections
    // *between* airlocks black, so check if we are an airlock but *not* drawing the airlock connections.
    boolean isAirlockConn = data.type == CardType.AIRLOCK && c.type == ConnectionType.NORMAL;
    // Airlock connection stroke is grey
    Colours.stroke(isAirlockConn ? Colours.card_hallBorder : Colours.black);
    Colours.strokeWeight(2); // Outline
    Colours.fill(isAirlockConn ? Colours.black : Colours.white);
    Shapes.trapezoid(center, connectionWidthB, connectionWidthT, connectionHeight, c.direction.opposite());

    Draw.start();
    {
      float iconSize = 20;

      if (c.type == ConnectionType.LOCKABLE)
      {
        // TODO: Lock icon
        Applet.get().rectMode(CENTER);
        Colours.fill(Colours.black);
        Applet.get().rect(center.x, center.y, iconSize, iconSize);
      } else
      {
        // Airlock arrows are yellow
        Colours.fill(isAirlockConn ? Colours.airlockYellow : Colours.black);
        // Fix the coordinates, and we don't care about editing these vars - won't be used anymore
        offset.y = -offset.y;
        Shapes.triangle(center.sub(offset.mult(iconSize / 2)), iconSize, iconSize, c.direction);
      }
    }
    Draw.end();
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

  Direction dir(Tile other)
  {
    if (!position.alignedWith(other.position))
      return null;
    return position.dir(other.position);
  }

  boolean is(String id)
  {
    return data.id.equals(id);
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

  void postUpdate()
  {
    super.postUpdate();

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

    // Something is in the other airlock
    boolean otherAirlockIsOccupied = otherAirlock.currentPlayers.size() > 0 || otherAirlock.currentEntities.size() > 0;
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
      Colours.stroke(0);
      Colours.strokeWeight(2); // Black outline
      Colours.fill(Colours.card_room);
      Tile.rect.draw(20);
      Colours.fill(Colours.black);
      Rect.shrink(Tile.rect, Tile.borderPadding * 3).draw(20);
      Colours.fill(Colours.white);
      Rect.shrink(Tile.rect, Tile.borderPadding * 4, 250).draw(20);
      Text.align(TextAlign.CENTER);
      Text.label("Room", 0, -10, 5);
      Text.label("(Undiscovered)", 0, 20, 2);

      drawConnections();
    }
  }
}
