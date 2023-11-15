import java.io.*;

String fontName = "Font.tff"; // Tobo font file, different from ttf lol

void saveFontFile(FontFile font)
{
}

FontFile loadFontFile()
{
  return null;
}

static JSONObject letterToJSON(Letter letter)
{
  /*
  Letter data layout
   
   String name;
   char character;
   int width, height;
   int[] bitmaps;
   */

  if (letter == null)
  {
    // Don't crash the program! Keep going
    //throw new IllegalArgumentException("letter was null!");
    Popup.show("Tried to save a null letter! Continuing...", 3);
    return new JSONObject();
  }
  
  if (letter.name.isEmpty())
  {
    Popup.show("Tried to save letter with no name! Continuing...", 3);
    return new JSONObject();
  }

  JSONObject obj = new JSONObject();

  obj.setString("name", letter.name);
  obj.setString("character", Character.toString(letter.character));
  obj.setInt("width", letter.width);
  obj.setInt("height", letter.height);

  JSONArray arr = new JSONArray();
  for (int i = 0; i < letter.bitmaps.length; i++)
  {
    arr.setInt(i, letter.bitmaps[i]);
  }

  return obj;
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
