static class Colours
{
  //static final color _ = create();
  static final color pureWhite = 255;
  static final color pureBlack = 0;
  static final color menuLight = create(255, 243, 237);
  static final color menuControl = create(219, 217, 215);
  static final color menuDark = create(31, 24, 31);
  static final color paleBlue = create(182, 203, 227);
  static final color lessPaleBlue = create(105, 158, 219); // ???? lmao idk what to name it

  static final color player = create(55, 98, 128);
  static final color selectedPlayer = create(72, 124, 219);
  static final color turnPlayer = create(140, 53, 71);
  static final color turnSelectedPlayer = create(214, 45, 79);

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
