FontFile font;

void setup()
{
  font = loadFontFile();
  size(400, 400);
  noStroke();
}

void draw()
{
  background(255);

  for (int i = 0; i < font.letters.size(); i++)
  {
    float x = 10 + i * 12;
    float count = (float)Math.floor(x / 380);
    x %= 380;
    float y = 40 + 24 * count;
    drawLetter(font.letters.get(i), x, y, 2);
  }
}

void drawLetter(Letter l, float x, float y, float size)
{
  for (int i = 0; i < l.bitmaps.length; i++)
  {
    fill(0);
    BitUtils.drawBitmap(this, l.bitmaps[i], l.width, x, y + i * size, size);
  }
}

void mousePressed()
{
  font = loadFontFile();
}
