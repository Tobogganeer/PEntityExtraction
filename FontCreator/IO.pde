import java.io.*;

String fontName = "Font.tff"; // Tobo font file, different from ttf lol

void saveFontFile(FontFile font)
{
  
}

static FontFile loadFontFile()
{
  return null;
}

// Just used to store the letters and version in one place
static class FontFile
{
  ArrayList<Letter> letters;
  String version;

  FontFile(ArrayList<Letter> letters, String version)
  {
    this.letters = letters;
    this.version = version;
  }
}
