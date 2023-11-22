import java.util.EnumSet;

// Will do this if I need it
//enum MenuType
//{
// MainMenu, Setup, Generation,
//}

static enum MenuLayout
{
  HORIZONTAL, VERTICAL;
}

static enum LayoutMode
{
  // Spread = evenly spread through rect
  // Offset = equal spacing between each
  SPREAD, OFFSET, NONE;
}

static enum Turn
{
  PLAYER, ENTITY;
}

static enum BoardSize
{
  SMALL, MEDIUM, LARGE;
}

static enum ConnectionType
{
  NORMAL, LOCKABLE, AIRLOCK;
}

// The type of data we are reading
static enum DataType
{
  AIRLOCK, HALL, COMPLEXHALL, CONSUMEABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON;

  final String jsonValue;

  private DataType()
  {
    this.jsonValue = name().toLowerCase();
  }

  // Credit: JoseMi
  // https://stackoverflow.com/questions/604424/how-to-get-an-enum-value-from-a-string-value-in-java
  static DataType fromJSON(String json)
  {
    for (DataType type : DataType.values())
    {
      if (type.jsonValue.equalsIgnoreCase(json))
      {
        return type;
      }
    }
    return null;
  }
}

// Tags that the data might have
static enum DataTag
{
  NONE(0);

  final int flag;
  final String jsonValue;

  private DataTag(int flag)
  {
    this.flag = flag;
    this.jsonValue = name().toLowerCase();
  }

  static boolean hasTag(int flags, DataTag tag)
  {
    return (flags & tag.flag) == tag.flag;
  }

  // Turn the bitfield into a list a DataTags
  // Credit: soappatrol
  // https://stackoverflow.com/questions/5346477/implementing-a-bitfield-using-java-enums
  static EnumSet<DataTag> getTags(int flags)
  {
    EnumSet tags = EnumSet.noneOf(DataTag.class);
    for (DataTag tag : DataTag.values())
    {
      if (hasTag(flags, tag))
        tags.add(tag);
    }

    return tags;
  }

  // Turn the set of tags into a bitfield
  // Credit: soappatrol
  // https://stackoverflow.com/questions/5346477/implementing-a-bitfield-using-java-enums
  static int getFlags(EnumSet<DataTag> tags)
  {
    int flags = 0;
    for (DataTag tag : tags)
      flags |= tag.flag;
    return flags;
  }

  // Credit: JoseMi
  // https://stackoverflow.com/questions/604424/how-to-get-an-enum-value-from-a-string-value-in-java
  static DataTag fromJSON(String json)
  {
    for (DataTag tag : DataTag.values())
    {
      if (tag.jsonValue.equalsIgnoreCase(json))
      {
        return tag;
      }
    }
    return null;
  }
}


static enum Direction
{
  UP, RIGHT, DOWN, LEFT;

  static Direction rotate(Direction dir, int count)
  {
    return from(dir.ordinal() + count);
  }

  boolean oppositeTo(Direction other)
  {
    return opposites(this, other);
  }

  static boolean opposites(Direction a, Direction b)
  {
    // Check if both are even or odd
    return a.ordinal() != b.ordinal() && a.ordinal() % 2 == b.ordinal() % 2;
  }

  static Direction from(int rotation)
  {
    // Clamp between -4 and 4
    rotation %= 4;

    // Handle negatives
    if (rotation < 0)
      rotation += 4;

    return values()[rotation];
  }

  float getAngle()
  {
    return ordinal() * 90;
  }
}

static enum TextAlign
{
  TOPLEFT(VerticalTextAlign.TOP, HorizontalTextAlign.LEFT),
    TOPCENTER(VerticalTextAlign.TOP, HorizontalTextAlign.CENTER),
    TOPRIGHT(VerticalTextAlign.TOP, HorizontalTextAlign.RIGHT),

    CENTERLEFT(VerticalTextAlign.CENTER, HorizontalTextAlign.LEFT),
    CENTER(VerticalTextAlign.CENTER, HorizontalTextAlign.CENTER),
    CENTERRIGHT(VerticalTextAlign.CENTER, HorizontalTextAlign.RIGHT),

    BOTTOMLEFT(VerticalTextAlign.BOTTOM, HorizontalTextAlign.LEFT),
    BOTTOMCENTER(VerticalTextAlign.BOTTOM, HorizontalTextAlign.CENTER),
    BOTTOMRIGHT(VerticalTextAlign.BOTTOM, HorizontalTextAlign.RIGHT),
    ;

  HorizontalTextAlign horizontalAlign;
  VerticalTextAlign verticalAlign;

  private TextAlign(VerticalTextAlign v, HorizontalTextAlign h)
  {
    this.horizontalAlign = h;
    this.verticalAlign = v;
  }
}

static enum VerticalTextAlign
{
  TOP, CENTER, BOTTOM
}

static enum HorizontalTextAlign
{
  LEFT, CENTER, RIGHT
}
