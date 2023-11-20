import java.util.HashMap;

static class Text
{
  static int characterSpacing = 1; // Spaces between characters
  static int lineSpacing = 2; // Extra spaces between lines
  static VerticalTextAlign vAlign = VerticalTextAlign.Top;
  static HorizontalTextAlign hAlign = HorizontalTextAlign.Left;
  static float boxPadding = 5; // Box borders

  static void align(TextAlign alignment)
  {
    vAlign = alignment.verticalAlign;
    hAlign = alignment.horizontalAlign;
  }

  static void draw(String text, float x, float y, float size)
  {
    draw(text, new PVector(x, y), size);
  }

  static void draw(String text, PVector pos, float size)
  {
    if (text == null || text.isEmpty())
      return;

    pos = pos.copy();

    calculatePosition(text, pos, size);

    drawStringRaw(text, pos.x, pos.y, size, 0, text.length());
  }

  // Will need to be changed for Text.Box(); to handle height
  private static void calculatePosition(String text, PVector pos, float size)
  {
    float height, width;
    switch (vAlign)
    {
    case Top:
      // Unchanged
      break;
    case Center:
      height = calculateHeight(1, size);
      pos.y -= height / 2;
      break;
    case Bottom:
      height = calculateHeight(1, size);
      pos.y -= height;
      break;
    }
    switch (hAlign)
    {
    case Left:
      // Unchanged
      break;
    case Center:
      width = calculateWidth(text, size);
      pos.x -= width / 2;
      break;
    case Right:
      width = calculateWidth(text, size);
      pos.x -= width;
      break;
    }
  }

  // Draws the string from the top left, no bounds checking
  private static void drawStringRaw(String text, float x, float y, float size, int start, int count)
  {
    for (int i = start; i < start + count; i++)
    {
      Letter l = Font.current.get(text.charAt(i));
      l.draw(x, y, size);
      x += l.pxWidth(size) + characterSpacing * size;
    }
  }

  static float calculateWidth(String text, float size)
  {
    if (text == null || text.isEmpty())
      return 0;

    return calculateWidth(text, size, 0, text.length());
  }

  static float calculateWidth(String text, float size, int numCharacters)
  {
    if (text == null || text.isEmpty())
      return 0;

    return calculateWidth(text, size, 0, numCharacters);
  }

  static float calculateWidth(String text, float size, int start, int count)
  {
    if (text == null || text.isEmpty())
      return 0;

    start = Maths.clampi(start, 0, text.length());
    count = Maths.clampi(count, 0, text.length() - start);

    float width = 0;
    for (int i = start; i < start + count; i++)
    {
      width += Font.current.get(text.charAt(i)).pxWidth(size);
      if (i < start + count - 1)
        // Add space between chars
        width += characterSpacing * size;
    }

    return width;
  }

  static float calculateHeight(int numLines, float size)
  {
    // Number of lines * size per line + space between lines
    return numLines * Font.current.tallestCharacter * size + (numLines - 1) * lineSpacing * size;
  }
}

static class Font
{
  static final String fontName = "Font.json";
  static Font current;

  private ArrayList<Letter> letters;
  String version;

  private int tallestCharacter; // Used for line spacing
  private HashMap<Character, Letter> letterMap;
  Letter nullChar;

  Font(ArrayList<Letter> letters, String version)
  {
    this.letters = letters;
    this.version = version;

    linkLetters();
    initNullChar();
  }

  static void load()
  {
    current = IO.loadFont(fontName);
    if (current == null)
      Applet.exit("Font load failed! Closing...");
  }

  // Create the dict of letters and their chars
  private void linkLetters()
  {
    letterMap = new HashMap<Character, Letter>(letters.size());

    for (Letter l : letters)
    {
      if (l == null)
        println("Null letter when creating font map");
      else
      {
        letterMap.put(l.character, l);
        tallestCharacter = max(tallestCharacter, l.height);
      }
    }
  }

  // The 'empty' character
  private void initNullChar()
  {
    nullChar = new Letter("null", ' ', 3, tallestCharacter);
    for (int i = 0; i < nullChar.height; i++)
    {
      if (i == 0 || i == nullChar.height - 1)
        nullChar.bitmaps[i] = 0b111; // Top and bottom
      else
        nullChar.bitmaps[i] = 0b101; // Full black square
    }
  }

  // Returns the letter of the char ch. Never returns null
  Letter get(char ch)
  {
    if (letterMap.containsKey(ch))
      return letterMap.get(ch);
    return nullChar;
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

  float pxWidth(float size)
  {
    return width * size;
  }

  float pxHeight(float size)
  {
    return height * size;
  }

  PVector pxSize(float size)
  {
    return new PVector(pxWidth(size), pxHeight(size));
  }

  void draw(PVector position, float size)
  {
    draw(position.x, position.y, size);
  }

  void draw(float x, float y, float size)
  {
    for (int i = 0; i < bitmaps.length; i++)
      BitUtils.drawBitmap(bitmaps[i], width, x, y + i * size, size);
  }
}
