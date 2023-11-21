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
    int ret = 0xFF;
    ret = (ret << 8) | r;
    ret = (ret << 8) | g;
    ret = (ret << 8) | b;
    return ret;
  }
}
