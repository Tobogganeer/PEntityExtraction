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

  static void strokeWeight(float weight)
  {
    Applet.get().strokeWeight(weight);
  }

  static void noStroke()
  {
    Applet.get().noStroke();
  }
}
