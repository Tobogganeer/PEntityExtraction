// Will do this if I need it
//enum MenuType
//{
// MainMenu, Setup, Generation,
//}

enum MenuLayout
{
  Horizontal, Vertical;
}

enum Direction
{
  Up(0), Right(1), Down(2), Left(3);

  private int val;

  private Direction(int val)
  {
    this.val = val;
  }

  static Direction rotate(Direction dir, int count)
  {
    return from(dir.val + count);
  }

  boolean oppositeTo(Direction other)
  {
    return opposites(this, other);
  }

  static boolean opposites(Direction a, Direction b)
  {
    // Check if both are even or odd
    return a.val != b.val && a.val % 2 == b.val % 2;
  }

  static Direction from(int rotation)
  {
    // Clamp between -4 and 4
    rotation %= 4;

    // Handle negatives
    if (rotation < 0)
      rotation += 4;

    switch (rotation)
    {
    case 0:
      return Direction.Up;
    case 1:
      return Direction.Right;
    case 2:
      return Direction.Down;
    case 3:
      return Direction.Left;
    default:
      throw new IllegalArgumentException("rotation");
    }
  }
}

enum TextAlign
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

enum VerticalTextAlign
{
  Top, Center, Bottom
}

enum HorizontalTextAlign
{
  Left, Center, Right
}
