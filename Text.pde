import java.util.HashMap;

static class Text
{
  static int characterSpacing = 1; // Spaces between characters
  static int lineSpacing = 0; // Extra spaces between lines
  static VerticalTextAlign vAlign = VerticalTextAlign.Top;
  static HorizontalTextAlign hAlign = HorizontalTextAlign.Left;

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

    PVector anchor = calculatePosition(text, 0, text.length(), pos, size);

    drawStringRaw(text, anchor.x, anchor.y, size, 0, text.length());
  }

  static void box(String text, Rect rect, float size)
  {
    if (text == null || text.isEmpty())
      return;

    if (rect == null || rect.w == 0 || rect.h == 0)
      return;

    // If you want padding, add it yourself. This will provide better control.
    // Probs gonna add a TextBox class after to draw the rect etc anyways
    //rect = new Rect(rect.x + boxPadding, rect.y + boxPadding, rect.w - boxPadding * 2, rect.h - boxPadding * 2);
    int lines = numLines(text, rect, size);
    float totalHeight = calculateHeight(lines, size, true);
    //boolean clipContent = totalHeight > rect.h;
    while (totalHeight > 0 && totalHeight > rect.h && lines > 0)
    {
      lines--;
      totalHeight = calculateHeight(lines, size, true);
    }

    // Make sure we draw at least one line
    lines = max(lines, 1);
    int charIndex = 0;
    PVector pos = calculateAnchorPosition(rect);
    for (int i = 0; i < lines; i++)
    {
      int lettersOnThisLine = numCharactersThatFitWidth(text, size, rect.w, charIndex);
      PVector anchor = calculatePosition(text, charIndex, lettersOnThisLine, pos, size);
      drawStringRaw(text, anchor.x, anchor.y + calculateHeight(i, size, false), size, charIndex, lettersOnThisLine);
      charIndex += lettersOnThisLine;
    }

    //draw(text + lines, rect.x, rect.y, size);
  }

  // Gets how many lines this text will take up inside of the rect
  static int numLines(String text, Rect rect, float size)
  {
    if (text == null || text.isEmpty())
      return 0;

    int lines = 0;
    int index = 0;
    while (index < text.length())
    {
      int chars = numCharactersThatFitWidth(text, size, rect.w, index);
      if (chars == 0)
        break;
      lines++;
      index += chars;
    }

    return lines;
  }

  // Verbose, self explanatory name lol
  private static int numCharactersThatFitWidth(String text, float size, float maxWidth, int start)
  {
    int chars = 0;
    float width = 0;
    for (int i = start; i < text.length(); i++)
    {
      width += charSize(text, size, i);
      if (width > maxWidth)
        return chars;
      chars++;
    }

    return chars;
  }

  // Returns the point where the text should be anchored on the rect
  private static PVector calculateAnchorPosition(Rect rect)
  {
    PVector res = new PVector();

    switch (vAlign)
    {
    case Top:
      res.y = rect.y;
      break;
    case Center:
      res.y = rect.centerY();
      break;
    case Bottom:
      res.y = rect.y + rect.h;
      break;
    }
    switch (hAlign)
    {
    case Left:
      res.x = rect.x;
      break;
    case Center:
      res.x = rect.centerX();
      break;
    case Right:
      res.x = rect.x + rect.w;
      break;
    }

    return res;
  }

  // Calculates the x and y position of a substring according to the current alignment
  private static PVector calculatePosition(String text, int start, int count, PVector pos, float size)
  {
    float height, width;
    PVector res = pos.copy();
    switch (vAlign)
    {
    case Top:
      res.y += size;
      break;
    case Center:
      height = calculateHeight(1, size, true);
      res.y -= height / 2;
      break;
    case Bottom:
      height = calculateHeight(1, size, true);
      res.y -= height;
      break;
    }
    switch (hAlign)
    {
    case Left:
      res.x += size;
      break;
    case Center:
      width = calculateWidth(text, size, start, count);
      res.x -= width / 2;
      break;
    case Right:
      width = calculateWidth(text, size, start, count);
      res.x -= width;
      break;
    }
    
    return res;
  }

  // Draws the string from the top left, no bounds checking
  private static void drawStringRaw(String text, float x, float y, float size, int start, int count)
  {
    count = min(count, text.length() - start); // Clamp it
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

  static float calculateWidth(String text, float size, int start, int count)
  {
    if (text == null || text.isEmpty())
      return 0;

    start = Maths.clampi(start, 0, text.length());
    count = Maths.clampi(count, 0, text.length() - start);

    float width = 0;
    for (int i = start; i < start + count; i++)
    {
      width += charSize(text, size, i);
    }

    return width;
  }

  // Calculates the size of 1 character, accounting for the space between characters
  static float charSize(String text, float size, int index)
  {
    float width = Font.current.get(text.charAt(index)).pxWidth(size);
    if (index < text.length() - 1)
      // Add space between chars
      width += characterSpacing * size;
    return width;
  }

  static float calculateHeight(int numLines, float size, boolean removeLastSpace)
  {
    if (numLines == 0) return 0;
    // Number of lines * size per line + space between lines
    return numLines * (Font.current.tallestCharacter + lineSpacing) * size - (removeLastSpace ? lineSpacing * size : 0);
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
    // TODO: Add newline character
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
