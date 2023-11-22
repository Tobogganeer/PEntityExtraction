// Will do this if I need it
//enum MenuType
//{
// MainMenu, Setup, Generation,
//}

static enum MenuLayout
{
  Horizontal, Vertical;
}

static enum LayoutMode
{
  // Spread = evenly spread through rect
  // Offset = equal spacing between each
  Spread, Offset, None;
}

static enum Turn
{
  Player, Entity;
}

static enum BoardSize
{
  Small, Medium, Large;
}

static enum Direction
{
  Up, Right, Down, Left;

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
  TopLeft(VerticalTextAlign.Top, HorizontalTextAlign.Left),
    TopCenter(VerticalTextAlign.Top, HorizontalTextAlign.Center),
    TopRight(VerticalTextAlign.Top, HorizontalTextAlign.Right),

    CenterLeft(VerticalTextAlign.Center, HorizontalTextAlign.Left),
    Center(VerticalTextAlign.Center, HorizontalTextAlign.Center),
    CenterRight(VerticalTextAlign.Center, HorizontalTextAlign.Right),

    BottomLeft(VerticalTextAlign.Bottom, HorizontalTextAlign.Left),
    BottomCenter(VerticalTextAlign.Bottom, HorizontalTextAlign.Center),
    BottomRight(VerticalTextAlign.Bottom, HorizontalTextAlign.Right),
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
  Top, Center, Bottom
}

static enum HorizontalTextAlign
{
  Left, Center, Right
}
