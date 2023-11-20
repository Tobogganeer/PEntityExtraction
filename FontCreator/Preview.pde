// Draws letters to the screen
class Preview
{
  Rect rect;
  float paddingX = 10;
  float paddingY = 20;
  int spaceSize = 4;
  int letterSpacing = 1;
  int rowSpacing = 10; // Default

  Preview(Rect rect)
  {
    this.rect = rect;
  }

  void display(String string, ArrayList<Letter> letters, float size)
  {
    fill(255);
    rect.display();

    fill(0);
    noStroke();
    if (string == null || string.isEmpty())
      drawAll(letters, size);
    else
      drawString(string, letters, size);
  }

  void drawAll(ArrayList<Letter> letters, float size)
  {
    PVector cursor = new PVector(paddingX, paddingY);
    for (int i = 0; i < letters.size(); i++)
    {
      Letter l = letters.get(i);
      drawLetter(l, cursor, size);
      calculateSpacing(cursor, pixelWidth(l, size) + letterSpacing * size, rowSpacing * size);
    }
  }

  void drawString(String string, ArrayList<Letter> letters, float size)
  {
    PVector cursor = new PVector(paddingX, paddingY);
    for (int i = 0; i < string.length(); i++)
    {
      Letter l = findLetter(string.charAt(i), letters);
      if (l == null)
      {
        // Add a null character
        rect(cursor.x, cursor.y, spaceSize * size, (rowSpacing - 1) * size);
        calculateSpacing(cursor, (spaceSize + letterSpacing) * size, rowSpacing * size);
      } else
      {
        // Draw the letter itself
        drawLetter(l, cursor, size);
        calculateSpacing(cursor, pixelWidth(l, size) + letterSpacing * size, rowSpacing * size);
      }
    }
  }

  Letter findLetter(char c, ArrayList<Letter> letters)
  {
    // Should make a dict, don't care enough
    for (Letter l : letters)
    {
      if (c == l.character)
        return l;
    }

    return null;
  }

  void drawLetter(Letter l, PVector pos, float size)
  {
    for (int i = 0; i < l.bitmaps.length; i++)
      BitUtils.drawBitmap(l.bitmaps[i], l.width, pos.x, pos.y + i * size, size);
  }

  void calculateSpacing(PVector pos, float widthToAdd, float height)
  {
    pos.x += widthToAdd;
    // Add and still check with width added to make sure
    // characters won't be halfway off screen
    if (pos.x + widthToAdd > rect.x + rect.w - paddingX)
    {
      pos.x = paddingX;
      pos.y += height;
    }
  }

  float pixelWidth(Letter l, float size)
  {
    return l.width * size;
  }

  float pixelHeight(Letter l, float size)
  {
    return l.width * size;
  }
}
