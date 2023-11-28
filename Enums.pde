//import java.util.EnumSet;

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

// The type of card we are reading
static enum CardType
{
  AIRLOCK, HALL, COMPLEXHALL, CONSUMABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON, ROOM;
}

// The types of things a card can do
static enum CardEffectType
{
  NONE,
    DRAW, // Item, Weapon, Entity
    DISCARD,
    DAMAGE, HEAL, RELOAD, ACTION,
    OPTIONAL, MULTI,
    DOOR, // Lock, unlock, lockOrUnlock
    DISCOVERRANDOMROOM,
    TELEPORT, // Player, entity, playerOrEntity
    MOVETOWARDS, // Player, entity
    MOVE,
    SETVARIABLE, // Damage multiplier
    CHANGETURN;
}

static enum EffectTarget
{
  NONE, ANY, ALL, NEAREST, SELF, RANDOM;
}

static enum EffectLocation
{
  NONE, ANY, ONTILE, GATE, BREACH, CENTEROFBOARD;
}

static enum EffectSelector
{
  NONE, PLAYER, ENTITY, PLAYERORENTITY, DOOR, PLAYERWITHLEASTITEMS;
}

// Who is trying to apply the effect
static enum EffectContext
{
  PLAYER, ENTITY, CARD;
}

// Actions that can be given with effects
/*
static enum ActionType
{
  MOVE, ATTACK;
}
*/


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
