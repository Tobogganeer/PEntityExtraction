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
    this.imagePath = imagePath == null ? "" : imagePath.trim();
    this.image = Applet.get().loadImage(this.imagePath);
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







// ============================================== Subclasses =====================================================

// AIRLOCK, HALL, COMPLEXHALL, CONSUMEABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON, ROOM;

static class AirlockData extends CardData
{
  static final String ID_airlockNumber = "airlockNumber";
  static final String ID_connections = "connections";

  final int airlockNumber;
  final Connection[] connections;

  static final HashMap<String, AirlockData> all = new HashMap<String, AirlockData>();

  static void create(JSONObject obj)
  {
    try
    {
      AirlockData data = new AirlockData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(AirlockData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

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
      throw new InvalidCardException("Tried to parse AirlockData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_airlockNumber))
      throw new InvalidCardException("Tried to parse AirlockData with no airlockNumber.");
    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse AirlockData with no connections.");

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

  static final HashMap<String, HallData> all = new HashMap<String, HallData>();

  static void create(JSONObject obj)
  {
    try
    {
      HallData data = new HallData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(HallData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  HallData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Connection... connections)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.connections = connections;
  }

  HallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse HallData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse HallData with no connections.");

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

  static final HashMap<String, ComplexHallData> all = new HashMap<String, ComplexHallData>();

  static void create(JSONObject obj)
  {
    try
    {
      ComplexHallData data = new ComplexHallData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(ComplexHallData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  ComplexHallData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Connection[] connections, Effect[] onFirstEntry, Effect[] onAnyEntry)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.connections = connections;
    this.onFirstEntry = onFirstEntry;
    this.onAnyEntry = onAnyEntry;
  }

  ComplexHallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ComplexHallData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_connections))
      throw new InvalidCardException("Tried to parse ComplexHallData with no connections.");

    JSONArray jsonConnections = info.getJSONArray(ID_connections);
    connections = Connection.fromJSONArray(jsonConnections);
    JSONArray jsonOnFirstEntry = info.getJSONArray(ID_onFirstEntry);
    JSONArray jsonOnAnyEntry = info.getJSONArray(ID_onAnyEntry);

    onFirstEntry = jsonOnFirstEntry == null ? new Effect[0] : Effect.fromJSONArray(jsonOnFirstEntry);
    onAnyEntry = jsonOnAnyEntry == null ? new Effect[0] : Effect.fromJSONArray(jsonOnAnyEntry);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
    info.setJSONArray(ID_onFirstEntry, Effect.toJSONArray(onFirstEntry));
    info.setJSONArray(ID_onAnyEntry, Effect.toJSONArray(onAnyEntry));
  }
}

static class ConsumeableItemData extends CardData
{
  static final String ID_actionCost = "actionCost";
  static final String ID_onUse = "onUse";

  final int actionCost;
  final Effect[] onUse;

  static final HashMap<String, ConsumeableItemData> all = new HashMap<String, ConsumeableItemData>();

  static void create(JSONObject obj)
  {
    try
    {
      ConsumeableItemData data = new ConsumeableItemData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(ConsumeableItemData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  ConsumeableItemData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags, int actionCost, Effect[] onUse)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.actionCost = actionCost;
    this.onUse = onUse;
  }

  ConsumeableItemData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse ConsumeableItemData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    actionCost = info.getInt(ID_actionCost, 1); // Default cost of 1 action
    JSONArray jsonOnUse = info.getJSONArray(ID_onUse);

    onUse = jsonOnUse == null ? new Effect[0] : Effect.fromJSONArray(jsonOnUse);
  }

  void fillInfo(JSONObject info)
  {
    info.setInt(ID_actionCost, actionCost);
    info.setJSONArray(ID_onUse, Effect.toJSONArray(onUse));
  }
}

static class EffectItemData extends CardData
{
  static final HashMap<String, EffectItemData> all = new HashMap<String, EffectItemData>();

  static void create(JSONObject obj)
  {
    try
    {
      EffectItemData data = new EffectItemData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(EffectItemData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  EffectItemData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags)
  {
    super(name, id, description, imagePath, type, count, tags);
  }

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

  static final HashMap<String, EntityData> all = new HashMap<String, EntityData>();

  static void create(JSONObject obj)
  {
    try
    {
      EntityData data = new EntityData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(EntityData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  EntityData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags,
    int health, String markerImagePath, Effect[] onDiscovery, Effect[] onTurn, Effect[] onContact, Effect[] onDeath)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.health = health;
    this.markerImagePath = markerImagePath.trim();
    this.markerImage = Applet.get().loadImage(this.markerImagePath);
    this.onDiscovery = onDiscovery;
    this.onTurn = onTurn;
    this.onContact = onContact;
    this.onDeath = onDeath;
  }

  EntityData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse EntityData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_health))
      throw new InvalidCardException("Tried to parse EntityData with no health.");

    health = info.getInt(ID_health);
    markerImagePath = info.getString(ID_markerImagePath, "").trim();
    markerImage = Applet.get().loadImage(markerImagePath);
    JSONArray jsonOnDiscovery = info.getJSONArray(ID_onDiscovery);
    JSONArray jsonOnTurn = info.getJSONArray(ID_onTurn);
    JSONArray jsonOnContact = info.getJSONArray(ID_onContact);
    JSONArray jsonOnDeath = info.getJSONArray(ID_onDeath);

    onDiscovery = jsonOnDiscovery == null ? new Effect[0] : Effect.fromJSONArray(jsonOnDiscovery);
    onTurn = jsonOnTurn == null ? new Effect[0] : Effect.fromJSONArray(jsonOnTurn);
    onContact = jsonOnContact == null ? new Effect[0] : Effect.fromJSONArray(jsonOnContact);
    onDeath = jsonOnDeath == null ? new Effect[0] : Effect.fromJSONArray(jsonOnDeath);
  }

  void fillInfo(JSONObject info)
  {
    info.setInt(ID_health, health);
    info.setString(ID_markerImagePath, markerImagePath);
    info.setJSONArray(ID_onDiscovery, Effect.toJSONArray(onDiscovery));
    info.setJSONArray(ID_onTurn, Effect.toJSONArray(onTurn));
    info.setJSONArray(ID_onContact, Effect.toJSONArray(onContact));
    info.setJSONArray(ID_onDeath, Effect.toJSONArray(onDeath));
  }
}

static class EntityItemData extends CardData
{
  static final String ID_onDiscovery = "onDiscovery";
  static final String ID_onOwnerTurn = "onOwnerTurn";

  final Effect[] onDiscovery;
  final Effect[] onOwnerTurn;

  static final HashMap<String, EntityItemData> all = new HashMap<String, EntityItemData>();

  static void create(JSONObject obj)
  {
    try
    {
      EntityItemData data = new EntityItemData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(EntityItemData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  EntityItemData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags, Effect[] onDiscovery, Effect[] onOwnerTurn)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.onDiscovery = onDiscovery;
    this.onOwnerTurn = onOwnerTurn;
  }

  EntityItemData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse EntityItemData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    JSONArray jsonOnDiscovery = info.getJSONArray(ID_onDiscovery);
    JSONArray jsonOnOwnerTurn = info.getJSONArray(ID_onOwnerTurn);

    onDiscovery = jsonOnDiscovery == null ? new Effect[0] : Effect.fromJSONArray(jsonOnDiscovery);
    onOwnerTurn = jsonOnOwnerTurn == null ? new Effect[0] : Effect.fromJSONArray(jsonOnOwnerTurn);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_onDiscovery, Effect.toJSONArray(onDiscovery));
    info.setJSONArray(ID_onOwnerTurn, Effect.toJSONArray(onOwnerTurn));
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

  static final HashMap<String, WeaponData> all = new HashMap<String, WeaponData>();

  static void create(JSONObject obj)
  {
    try
    {
      WeaponData data = new WeaponData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(WeaponData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  WeaponData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags,
    int damage, int minRange, int maxRange, int attacksPerAction, int ammoPerAttack, boolean melee, boolean hitsAllOnTile)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.damage = damage;
    this.minRange = minRange;
    this.maxRange = maxRange;
    this.attacksPerAction = attacksPerAction;
    this.ammoPerAttack = ammoPerAttack;
    this.melee = melee;
    this.hitsAllOnTile = hitsAllOnTile;
  }

  WeaponData(JSONObject obj) throws InvalidCardException
  {
    super(obj);

    if (!obj.hasKey(ID_info))
      throw new InvalidCardException("Tried to parse WeaponData with no info.");

    JSONObject info = obj.getJSONObject(ID_info);

    if (!info.hasKey(ID_damage))
      throw new InvalidCardException("Tried to parse WeaponData with no damage.");
    if (!info.hasKey(ID_maxRange))
      throw new InvalidCardException("Tried to parse WeaponData with no max range.");
    if (!info.hasKey(ID_attacksPerAction))
      throw new InvalidCardException("Tried to parse WeaponData with no attacks per action.");
    if (!info.hasKey(ID_hitsAllOnTile))
      throw new InvalidCardException("Tried to parse WeaponData with no hits all on tile-flag.");

    damage = info.getInt(ID_damage);
    minRange = info.getInt(ID_minRange, 0); // Optional
    maxRange = info.getInt(ID_maxRange);
    attacksPerAction = info.getInt(ID_attacksPerAction);
    ammoPerAttack = info.getInt(ID_ammoPerAttack, 1); // Optional
    melee = info.getBoolean(ID_melee);
    hitsAllOnTile = info.getBoolean(ID_hitsAllOnTile, false); // Optional
  }

  void fillInfo(JSONObject info)
  {
    info.setInt(ID_damage, damage);
    info.setInt(ID_minRange, minRange);
    info.setInt(ID_maxRange, maxRange);
    info.setInt(ID_attacksPerAction, attacksPerAction);
    info.setInt(ID_ammoPerAttack, ammoPerAttack);
    info.setBoolean(ID_melee, melee);
    info.setBoolean(ID_hitsAllOnTile, hitsAllOnTile);
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

  static final HashMap<String, RoomData> all = new HashMap<String, RoomData>();

  static void create(JSONObject obj)
  {
    try
    {
      RoomData data = new RoomData(obj);
      create(data);
    }
    catch (InvalidCardException ex)
    {
      Popup.show("Failed to add card. Reason: " + ex.getMessage(), 5);
    }
  }

  static void create(RoomData data)
  {
    if (data == null)
      return;
    all.put(data.id, data);
  }

  RoomData(String name, String id, String description, String imagePath, CardType type, int count, String[] tags,
    Connection[] connections, Effect[] onDiscovery, Effect[] onFirstEntry, Effect[] onAnyEntry)
  {
    super(name, id, description, imagePath, type, count, tags);
    this.connections = connections;
    this.onDiscovery = onDiscovery;
    this.onFirstEntry = onFirstEntry;
    this.onAnyEntry = onAnyEntry;
  }

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
    JSONArray jsonOnDiscovery = info.getJSONArray(ID_onDiscovery);
    JSONArray jsonOnFirstEntry = info.getJSONArray(ID_onFirstEntry);
    JSONArray jsonOnAnyEntry = info.getJSONArray(ID_onAnyEntry);

    onDiscovery = jsonOnDiscovery == null ? new Effect[0] : Effect.fromJSONArray(jsonOnDiscovery);
    onFirstEntry = jsonOnFirstEntry == null ? new Effect[0] : Effect.fromJSONArray(jsonOnFirstEntry);
    onAnyEntry = jsonOnAnyEntry == null ? new Effect[0] : Effect.fromJSONArray(jsonOnAnyEntry);
  }

  void fillInfo(JSONObject info)
  {
    info.setJSONArray(ID_connections, Connection.toJSONArray(connections));
    info.setJSONArray(ID_onDiscovery, Effect.toJSONArray(onDiscovery));
    info.setJSONArray(ID_onFirstEntry, Effect.toJSONArray(onFirstEntry));
    info.setJSONArray(ID_onAnyEntry, Effect.toJSONArray(onAnyEntry));
  }
}
