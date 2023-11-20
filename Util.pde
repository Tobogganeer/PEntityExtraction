static class GlobalPApplet
{
  // This exists so I can access it even in static classes
  // A truly global variable
  static PApplet instance;

  static void init(PApplet applet)
  {
    instance = applet;
  }
}
