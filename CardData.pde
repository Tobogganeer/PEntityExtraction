import java.util.HashSet;

static class CardData
{
  // The identifiers in the json objects
  static final String ID_name = "name";
  static final String ID_id = "id";
  static final String ID_description = "description";
  static final String ID_imagePath = "image";
  static final String ID_type = "type";
  static final String ID_count = "count";
  static final String ID_tags = "tags";
  static final String ID_info = "info";

  final String name;
  final String id;
  final String description;
  final PImage image;
  final String imagePath;
  final CardType type;
  final int count;
  final HashSet<String> tags;

  private CardData(String name, String id, String description, String imagePath, CardType type, int count, String... tags)
  {
    this.name = name.trim();
    this.id = id.toLowerCase().trim(); // ID will always be all lowercase
    this.description = description.trim();
    // Load the image, if the path exists
    this.image = imagePath == null || imagePath.isBlank() ? null : Applet.get().loadImage(imagePath.trim());
    this.imagePath = imagePath == null ? "" : imagePath.trim();
    this.type = type;
    this.count = max(count, 0); // Can't have negative cards
    this.tags = new HashSet<String>();
    if (tags != null)
      for (String tag : tags)
        this.tags.add(tag.trim());
  }

  CardData(JSONObject obj) throws InvalidCardException
  {
    if (obj == null)
      throw new InvalidCardException("Tried to create a card from a null JSONObject.");

    // From testing, a field will just be null if it doesn't exist
    // Or throw a RuntimeError if it is not a string
    String jsonName = obj.getString(ID_name);
    String jsonID = obj.getString(ID_id);
    // Some cards with no description could omit the key altogether. Keep moving along.
    String jsonDescription = obj.getString(ID_description, "");
    String jsonImagePath = obj.getString(ID_imagePath);
    CardType jsonType = JSON.getEnum(CardType.class, obj.getString(ID_type));
    // If they don't specify a count, just assume it's one. Not the end of the world.
    int jsonCount = obj.getInt(ID_type, 1);
    JSONArray jsonTags = obj.getJSONArray(ID_tags);

    // Validation
    // These are non-negotiables
    if (jsonName == null || jsonID == null || jsonType == null)
      throw new InvalidCardException("Card did not have 1 or more required keys: name='" + jsonName + "', id='" + jsonID + "', type='" + jsonType + "'");

    if (jsonName.isBlank())
      throw new InvalidCardException("Card has blank name. id='" + jsonID + "'");

    if (jsonID.isBlank())
      throw new InvalidCardException("Card has blank id. name='" + jsonName + "'");

    String[] tags = null;

    if (jsonTags != null)
    {
      tags = new String[jsonTags.size()];
      for (int i = 0; i < jsonTags.size(); i++)
      {
        // Could use JSONArray.toStringArray(), but this way lets me check each string
        String tag = jsonTags.getString(i);
        if (tag.isBlank())
          throw new InvalidCardException("Card has blank tag. name='" + jsonName + "', tag index=" + i);
        tags[i] = tag;
      }
    }


    // Screw it, I am copying and pasting the other constructor in here
    // So done with java shenanigans (having the call the constructor on the first line)
    // Yes, I understand why that is the case and I don't hate it less
    // I could create some silly subclass "CardDataData" with
    // functions to init it which I then pass to some constructor
    // but I don't care and grrrrr yucky
    // Rant over, copying pasting code, blegh.

    //this(jsonName, jsonID, jsonDescription, jsonImagePath, jsonType, jsonCount, tags);

    this.name = jsonName.trim();
    this.id = jsonID.toLowerCase().trim(); // ID will always be all lowercase
    this.description = jsonDescription.trim();
    // Load the image, if the path exists
    this.imagePath = jsonImagePath == null ? "" : jsonImagePath.trim();
    this.image = imagePath.isBlank() ? null : Applet.get().loadImage(imagePath.trim());
    this.type = jsonType;
    this.count = max(jsonCount, 0); // Can't have negative cards
    this.tags = new HashSet<String>();
    if (tags != null)
      for (String tag : tags)
        this.tags.add(tag.trim());
  }

  JSONObject toJSON()
  {
    JSONObject obj = new JSONObject();

    /*
    final String name;
     final String id;
     final String description;
     final PImage image;
     final String imagePath;
     final CardType type;
     final int count;
     final HashSet<String> tags;
     */

    obj.setString(ID_name, name);
    obj.setString(ID_id, id);
    obj.setString(ID_description, description);
    obj.setString(ID_imagePath, imagePath);
    obj.setString(ID_type, type.name());
    obj.setInt(ID_count, count);
    JSONArray jsonTags = new JSONArray();
    for (String s : tags)
      jsonTags.append(s); // Add each string
    obj.setJSONArray(ID_tags, jsonTags);

    JSONObject info = new JSONObject();
    fillInfo(info);
    if (info.size() > 0)
      // Only add info if there is any
      obj.setJSONObject(ID_info, info);

    return obj;
  }

  // I guess you guys aren't ready for that yet...
  // But your kids are gonna love it
  // (overriden by subclasses)
  void fillInfo(JSONObject info) {
  }


  boolean hasTag(String tag)
  {
    return tags.contains(tag);
  }
}


static class InvalidCardException extends Exception
{
  public InvalidCardException() {
  }

  public InvalidCardException(String message)
  {
    super(message);
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







// ======================= Subclasses ==============================

// AIRLOCK, HALL, COMPLEXHALL, CONSUMEABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON, ROOM;

static class AirlockData extends CardData
{
  static final String ID_airlockNumber = "airlockNumber";
  static final String ID_connections = "connections";

  final int airlockNumber;
  final Connection[] connections;

  AirlockData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags, int airlockNumber, Connection... connections)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.airlockNumber = airlockNumber;
    this.connections = connections;
  }

  AirlockData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse airlock with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_airlockNumber))
      throw new InvalidCardException("Tried to parse airlock with no airlockNumber.");
    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse airlock with no connections.");

    airlockNumber = info.getInt(ID_airlockNumber);
    JSONArray jsonConnections = info.getJSONArray(ID_connections);
    connections = Connection.fromJSONArray(jsonConnections);
  }

  void fillInfo(JSONObject info)
  {
    info.setInt(ID_airlockNumber, airlockNumber);
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
  }
}

// Could make all these kinda room cards derive from some base RoomData class
// that has a Connection[], but angering the OOP gods makes me happier
// Plus 1 subclass per CardType makes me smile
static class HallData extends CardData
{
  static final String ID_connections = "connections";

  final Connection[] connections;

  HallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse hall with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse hall with no connections.");

    JSONArray jsonConnections = info.getJSONArray(ID_connections);
    connections = Connection.fromJSONArray(jsonConnections);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
  }
}

static class ComplexHallData extends CardData
{
  static final String ID_connections = "connections";
  static final String ID_onFirstEntry = "onFirstEntry";
  static final String ID_onAnyEntry = "onAnyEntry";

  final Connection[] connections;
  final Effect[] onFirstEntry;
  final Effect[] onAnyEntry;

  ComplexHallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse complex hall with no connections.");

    JSONArray jsonConnections = info.getJSONArray(ID_connections);
    connections = Connection.fromJSONArray(jsonConnections);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
  }
}

static class ConsumeableItemData extends CardData
{
  static final String ID_actionCost = "actionCost";
  static final String ID_onUse = "onUse";

  final int actionCost;
  final Effect[] onUse;

  ConsumeableData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_))
      throw new InvalidCardException("Tried to parse ______ with no _______.");
  }

  void fillInfo(JSONObject info)
  {
    // Stuff
  }
}

static class EffectItemData extends CardData
{
  EffectItemData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  // No extra data for effect cards
  // Yup, this is it.
  // Nice weather, eh?
}

static class EntityData extends CardData
{
  static final String ID_health = "health";
  static final String ID_markerImagePath = "markerImage";
  static final String ID_onDiscovery = "onDiscovery";
  static final String ID_onTurn = "onTurn";
  static final String ID_onContact = "onContact";
  static final String ID_onDeath = "onDeath";

  final int health;
  final String markerImagePath;
  final PImage markerImage;
  final Effect[] onDiscovery;
  final Effect[] onTurn;
  final Effect[] onContact;
  final Effect[] onDeath;

  EntityData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_))
      throw new InvalidCardException("Tried to parse ______ with no _______.");
  }

  void fillInfo(JSONObject info)
  {
    // Stuff
  }
}

static class EntityItemData extends CardData
{
  static final String ID_onDiscovery = "onDiscovery";
  static final String ID_onOwnerTurn = "onOwnerTurn";

  final Effect[] onDiscovery;
  final Effect[] onOwnerTurn;

  EntityItemData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_))
      throw new InvalidCardException("Tried to parse ______ with no _______.");
  }

  void fillInfo(JSONObject info)
  {
    // Stuff
  }
}

static class WeaponData extends CardData
{
  static final String ID_damage = "damage";
  static final String ID_minRange = "minRange";
  static final String ID_maxRange = "maxRange";
  static final String ID_attacksPerAction = "attacksPerAction";
  static final String ID_ammoPerAttack = "ammoPerAttack";
  static final String ID_melee = "melee";
  static final String ID_hitsAllOnTile = "hitsAllOnTile";

  final int damage;
  final int minRange;
  final int maxRange;
  final int attacksPerAction;
  final int ammoPerAttack;
  final boolean melee;
  final boolean hitsAllOnTile;

  WeaponData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_))
      throw new InvalidCardException("Tried to parse ______ with no _______.");
  }

  void fillInfo(JSONObject info)
  {
    // Stuff
  }
}

static class RoomData extends CardData
{
  static final String ID_connections = "connections";
  static final String ID_onDiscovery = "onDiscovery";
  static final String ID_onFirstEntry = "onFirstEntry";
  static final String ID_onAnyEntry = "onAnyEntry";

  final Connection[] connections;
  final Effect[] onDiscovery;
  final Effect[] onFirstEntry;
  final Effect[] onAnyEntry;

  RoomData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ______ with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse room with no connections.");

    JSONArray jsonConnections = info.getJSONArray(ID_connections);
    connections = Connection.fromJSONArray(jsonConnections);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
  }
}
