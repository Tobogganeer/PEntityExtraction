import java.io.*;

String fontName = "Font.tff"; // Tobo font file, different from ttf lol

void saveFontFile(FontFile font)
{
  if (font == null)
  {
    logAndReturn("Save failed: null font");
    return;
  }

  if (font.letters == null)
  {
    logAndReturn("Save failed: null letter list");
    return;
  }

  if (font.version == null || font.version.isEmpty())
  {
    logAndReturn("Save: version was empty. Setting to 1.0");
    font.version = "1.0";
  }

  JSONObject obj = new JSONObject();
  obj.setString("version", font.version);

  JSONArray letterArray = new JSONArray();

  int objectsAdded = 0;
  for (int i = 0; i < font.letters.size(); i++)
  {
    JSONObject jsonLetter = letterToJSON(font.letters.get(i));
    if (jsonLetter == null)
      continue;
    letterArray.setJSONObject(objectsAdded, jsonLetter);
    objectsAdded++;
  }
  
  obj.setJSONArray("letters", letterArray);
  
  saveJSONObject(obj, fontName);
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
    return logAndReturn("Save failed: null letter! Continuing...");

  if (letter.name == null || letter.name.isEmpty())
    return logAndReturn("Save failed: letter with null/empty name. Continuing...");

  if (letter.width == 0 || letter.height == 0)
    return logAndReturn("Save failed: letter (" + letter.name + ") with 0 width/height. Continuing...");

  if (letter.bitmaps == null)
    return logAndReturn("Save failed: letter (" + letter.name + ") with null bitmaps. Continuing...");

  if (letter.bitmaps.length != letter.height)
    return logAndReturn("Save failed: letter (" + letter.name + ") where height != bitmaps.length. Continuing...");

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

  obj.setJSONArray("bitmaps", arr);

  return obj;
}

static JSONObject logAndReturn(String errorMessage)
{
  Popup.show(errorMessage, 5);
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
