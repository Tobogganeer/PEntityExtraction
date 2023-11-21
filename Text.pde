static class Text
{
  static int characterSpacing = 1; // Spaces between characters
  static int lineSpacing = 1; // Extra spaces between lines
  static VerticalTextAlign vAlign = VerticalTextAlign.Top;
  static HorizontalTextAlign hAlign = HorizontalTextAlign.Left;
  static color colour = 0;
  static color strokeColour = 0;
  static float strokeWeight = 0;

  static void align(TextAlign alignment)
  {
    vAlign = alignment.verticalAlign;
    hAlign = alignment.horizontalAlign;
  }

  static void label(String text, float x, float y, float size)
  {
    label(text, new PVector(x, y), size);
  }

  static void label(String text, PVector pos, float size)
  {
    if (text == null || text.isEmpty())
      return;

    PVector anchor = calculatePosition(text, 0, text.length(), pos, size);

    drawStringRaw(text, anchor.x, anchor.y, size, 0, text.length());
  }

  static void box(String text, Rect rect, float size)
  {
    box(text, rect, size, 0);
  }

  static void box(String text, Rect rect, float size, float padding)
  {
    if (text == null || text.isEmpty())
      return;

    if (rect == null || rect.w == 0 || rect.h == 0)
      return;

    rect = Rect.shrink(rect, padding, padding);

    int lines = numLines(text, rect, size);
    float totalHeight = calculateHeight(lines, size, true);
    // Limit total lines to fit within the rect
    while (totalHeight > 0 && totalHeight > rect.h && lines > 0)
    {
      lines--;
      totalHeight = calculateHeight(lines, size, true);
    }

    // Are we clipping any content off?
    //boolean clipContent = totalHeight > rect.h;

    // Make sure we draw at least one line
    lines = max(lines, 1);

    int charIndex = 0; // Where in the string we are currently
    PVector pos = calculateAnchorPosition(rect); // The position on the rect to start at
    for (int i = 0; i < lines; i++)
    {
      // How many letters should be drawn on this line
      int lettersOnThisLine = numCharactersThatFitWidth(text, size, rect.w, charIndex);
      // Where the top left of that substring should be
      PVector anchor = calculatePosition(text, charIndex, lettersOnThisLine, pos, size);
      // How high that specific line should be drawn
      float y = getBoxLineHeight(anchor.y, size, i, totalHeight);
      // Draw it and move the current letter forward
      drawStringRaw(text, anchor.x, y, size, charIndex, lettersOnThisLine);
      charIndex += lettersOnThisLine;
    }
  }

  // Returns the height of a specific line, taking anchoring into account
  static float getBoxLineHeight(float anchorY, float size, int lineIndex, float totalHeight)
  {
    // Where the default anchor height would be
    float y = anchorY + calculateHeight(lineIndex, size, false);
    float lineHeight = calculateHeight(1, size, true);
    if (vAlign == VerticalTextAlign.Bottom)
      y = y - totalHeight + lineHeight; // Move the anchor to the bottom of the rect & letter
    else if (vAlign == VerticalTextAlign.Center)
      y = y - totalHeight / 2 + lineHeight / 2; // Move the anchor halfway down the rect & letter
    return y;
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
      // How many characters fit on this line?
      int chars = numCharactersThatFitWidth(text, size, rect.w, index);
      if (chars == 0)
        break; // None, get outta here
      // At least one, that's a new line
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
      // Newline! Send 'er right back
      if (text.charAt(i) == '\n')
        return chars + 1;

      // Pixel width
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
    Draw.start();
    {
      PApplet app = Applet.get();
      app.fill(colour);
      if (strokeWeight > 0)
      {
        app.stroke(strokeColour);
        app.strokeWeight(strokeWeight);
      } else
        app.noStroke();

      for (int i = start; i < start + count; i++)
      {
        Letter l = Font.current.get(text.charAt(i));
        l.draw(x, y, size);
        x += l.pxWidth(size) + characterSpacing * size;
      }
    }
    Draw.end();
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

    start = constrain(start, 0, text.length());
    count = constrain(count, 0, text.length() - start);

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

    // Add newline character
    letters.add(new Letter("newline", '\n', 0, 1));

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
