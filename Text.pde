import java.util.HashMap;

static class Text
{
  static int characterSpacing = 1; // Spaces between characters
  static int lineSpacing = 2; // Extra spaces between lines
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
