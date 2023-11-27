import java.util.HashSet;

static class CardData
{
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
    String jsonName = obj.getString("name");
    String jsonID = obj.getString("id");
    String jsonDescription = obj.getString("description");
    if (jsonDescription == null)
      // Some cards with no description could omit the key altogether. Keep moving along.
      jsonDescription = "";

    String jsonImagePath = obj.getString("image");
    CardType jsonType = JSON.getEnum(CardType.class, obj.getString("type"));
    int jsonCount;
    if (obj.hasKey("count"))
      jsonCount = obj.getInt("count");
    else
      // If they don't specify a count, just assume it's one. Not the end of the world.
      jsonCount = 1;

    JSONArray jsonTags = obj.getJSONArray("tags");

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

  // TODO: Maybe? Not that hard and would be useful for a card creator program
  JSONObject toJSON()
  {
    return null;
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




// Subclasses

// AIRLOCK, HALL, COMPLEXHALL, CONSUMEABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON, ROOM;

static class AirlockData extends CardData
{
  final int airlockNumber;
  final Connection[] connections;

  AirlockData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

// Could make all these kinda room cards derive from some base RoomData class
// that has a Connection[], but angering the OOP gods makes me happier
// Plus 1 subclass per CardType makes me smile
static class HallData extends CardData
{
  final Connection[] connections;

  HallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class ComplexHallData extends CardData
{
  ComplexHallData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class ConsumeableData extends CardData
{
  ConsumeableData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class EffectData extends CardData
{
  EffectData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    return super.toJSON();
  }

  // No extra data for effect cards
  // Yup, this is it.
  // Nice weather, eh?
}

static class EntityData extends CardData
{
  EntityData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class EntityItemData extends CardData
{
  EntityItemData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class WeaponData extends CardData
{
  WeaponData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}

static class RoomData extends CardData
{
  RoomData(JSONObject obj) throws InvalidCardException
  {
    super(obj);
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();
    // Stuff
    return obj;
  }
}
