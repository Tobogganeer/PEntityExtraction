static class Colours
{
  static final color missing = create(255, 0, 255);

  //static final color _ = create();
  static final color pureWhite = 255;
  static final color pureBlack = 0;
  static final color white = 240; // Kinda misleading as they are slightly off
  static final color black = 20;
  static final color menuLight = create(255, 243, 237);
  static final color menuControl = create(219, 217, 215);
  static final color menuDark = create(31, 24, 31);
  static final color paleBlue = create(182, 203, 227);
  static final color lessPaleBlue = create(105, 158, 219); // ???? lmao idk what to name it

  static final color player = create(55, 98, 128);
  static final color selectedPlayer = create(72, 124, 219);
  static final color turnPlayer = create(140, 53, 71);
  static final color turnSelectedPlayer = create(214, 45, 79);

  // AIRLOCK, HALL, COMPLEXHALL, ROOM, CONSUMABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON;
  // Taken straight from the Miro colours
  static final color card_grey = #A8A8A8;
  static final color card_airlock = #AC3636;
  static final color card_hall = #A8A8A8;
  static final color card_hallBorder = #808080;
  static final color card_room = #519872;
  static final color card_startingRoom = #8FD14F;
  static final color card_entity = #AC3636;
  static final color card_smallWeapon = #A1C1E5;
  static final color card_mediumWeapon = #5281CC;
  static final color card_largeWeapon = #414BB2;
  static final color card_consumable = #875C74;
  static final color card_effect = #827191;
  static final color card_entityItem = #FAC710;
  static final color card_entityConsumable = #DDA235;
  static final color card_entityEffect = #CEB269;
  
  static final color airlockYellow = #FAC710;

  static color fromCard(CardData card)
  {
    switch(card.type)
    {
    case CONSUMABLE:
      if (card.hasTag(IDs.Tag.EntityItem))
        return card_entityConsumable; // Border
      else
        return card_consumable; // Border
    case EFFECT:
      if (card.hasTag(IDs.Tag.EntityItem))
        return card_entityEffect; // Border
      else
        return card_effect; // Border
    case ENTITY:
      return card_entity; // Border
    case ENTITYITEM:
      return card_entityItem; // Border
    case WEAPON:
      if (card.hasTag(IDs.Tag.Small))
        return card_smallWeapon; // Border
      else if (card.hasTag(IDs.Tag.Large))
        return card_largeWeapon;
      else
        return card_mediumWeapon; // Default;
    default:
      return missing;
    }
  }

  static color getTileBorder(CardData tile)
  {
    if (tile.type == CardType.ROOM)
      return tile.hasTag(IDs.Tag.StartDiscovered) ? card_startingRoom : card_room;
    return card_hallBorder;
  }

  static color getTileFill(CardData tile)
  {
    if (tile.type == CardType.ROOM)
      return black;
    else if (tile.type == CardType.AIRLOCK)
      return card_airlock;
    return card_grey;
  }

  // https://processing.org/reference/color_datatype.html
  static color create(int r, int g, int b)
  {
    return create(r, g, b, 0xFF);
  }

  static color create(int r, int g, int b, int a)
  {
    int ret = a;
    ret = (ret << 8) | r;
    ret = (ret << 8) | g;
    ret = (ret << 8) | b;
    return ret;
  }

  static int getComponent(int colour, int compIndex)
  {
    compIndex *= 8;
    int val = (colour & (0xFF << compIndex)) >> compIndex;
    if (val < 0)
      return 255;
    return val;
  }

  static int r(int colour)
  {
    return getComponent(colour, 2);
  }

  static int g(int colour)
  {
    return getComponent(colour, 1);
  }

  static int b(int colour)
  {
    return getComponent(colour, 0);
  }

  static int a(int colour)
  {
    return getComponent(colour, 3);
  }

  static void fill(int r, int g, int b)
  {
    fill(create(r, g, b));
  }

  static void fill(int colour)
  {
    Applet.get().fill(colour);
  }

  static void stroke(int colour)
  {
    Applet.get().stroke(colour);
  }

  // This function is gross lol
  static int mix(int a, int b, float t)
  {
    int ra = r(a);
    int ga = g(a);
    int ba = b(a);
    int aa = a(a);
    int rb = r(b);
    int gb = g(b);
    int bb = b(b);
    int ab = a(b);

    return create((int)lerp(ra, rb, t), (int)lerp(ga, gb, t), (int)lerp(ba, bb, t), (int)lerp(aa, ab, t));
  }

  static void strokeWeight(float weight)
  {
    Applet.get().strokeWeight(weight);
  }

  static void noStroke()
  {
    Applet.get().noStroke();
  }
}
