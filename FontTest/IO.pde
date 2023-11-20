import java.io.*;

String fontName = "Font.json";

FontFile loadFontFile()
{
  JSONObject jsonFont;
  try
  {
    // Try and load it
    jsonFont = loadJSONObject(fontName);
  }
  catch (RuntimeException ex)
  {
    // Whoops!
    //Popup.show("Load failed: '" + file.getName() + "' is not a valid font file.", 5);
    return null;
  }

  String version = jsonFont.getString("version");
  JSONArray letterArray = jsonFont.getJSONArray("letters");
  ArrayList<Letter> letters = new ArrayList<Letter>();

  for (int i = 0; i < letterArray.size(); i++)
  {
    Letter l = jsonToLetter(letterArray.getJSONObject(i));
    if (l != null)
      letters.add(l);
  }

  FontFile font = new FontFile(letters, version);
  return font;
  //Popup.show("Successfully loaded '" + file.getName() + "' (" + letters.size() + " letters)", 3);
}

Letter jsonToLetter(JSONObject json)
{
  String name = json.getString("name");
  String character = json.getString("character");
  int w = json.getInt("width");
  int h = json.getInt("height");

  Letter l = new Letter(name, character.charAt(0), w, h);
  JSONArray bitmaps = json.getJSONArray("bitmaps");

  for (int i = 0; i < l.bitmaps.length; i++)
  {
    l.bitmaps[i] = bitmaps.getInt(i);
  }

  return l;
}

static JSONObject logAndReturn(String errorMessage)
{
  //Popup.show(errorMessage, 5);
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
