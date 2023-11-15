class Letter
{
  String name;
  char character;
  int width, height;
  int[] bitmaps;

  Letter(String name, char character, int width, int height)
  {
    this.name = name;
    this.character = character;
    this.width = width;
    this.height = height;
    bitmaps = new int[height];
  }

  void initBitmaps()
  {
    if (bitmaps == null || bitmaps.length != height)
      bitmaps = new int[max(height, 0)];
  }
}
