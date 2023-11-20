static class Text
{
  static Font font;
  static int characterSpacing = 1; // Spaces between characters
  static int lineSpacing = 2; // Extra spaces between lines

  static void init()
  {
    font = IO.loadFont(Font.fontName);
    if (font == null)
      Applet.exit("Font load failed! Closing...");
  }
}

static class Font
{
  static final String fontName = "Font.json";

  ArrayList<Letter> letters;
  String version;
  int tallestCharacter; // Used for line spacing

  Font(ArrayList<Letter> letters, String version)
  {
    this.letters = letters;
    this.version = version;
  }
}

static class Letter
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
}
