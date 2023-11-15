import java.io.*;

String fontName = "data" + File.separator + "Font.json";

FontLoadedCallback fontLoadedCallback;

void saveFontFile(FontFile font)
{
  // Do a bunch of null checks
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

  // Save the values into a json object
  JSONObject obj = new JSONObject();
  obj.setString("version", font.version);

  JSONArray letterArray = new JSONArray();

  // How many objects we have actually added (to have accurate indices)
  int objectsAdded = 0;
  for (int i = 0; i < font.letters.size(); i++)
  {
    JSONObject jsonLetter = letterToJSON(font.letters.get(i));
    // Didn't convert right
    if (jsonLetter == null)
      continue; // So keep going
    letterArray.setJSONObject(objectsAdded, jsonLetter);
    objectsAdded++;
  }

  obj.setJSONArray("letters", letterArray);

  // Save that sucker
  saveJSONObject(obj, fontName);

  Popup.show("Saved '" + fontName + "'.", 3);

  // Tried to open the file here but to no avail :P
  // https://processing.org/reference/launch_.html
  // Not really working
  //exec("explorer.exe \"" + sketchPath() + File.separator + "data" + File.separator + "\"");
}

void loadFontFile(FontLoadedCallback callback)
{
  // Give them a default
  File file = new File(sketchPath() + File.separator + fontName);

  // https://processing.org/reference/selectInput_.html
  // Let them choose a file
  selectInput("Select a font file:", "fontWasLoaded", file);

  // Store the code to call in the end
  fontLoadedCallback = callback;
}

void fontWasLoaded(File file)
{
  // No file selected
  if (file == null)
  {
    fontLoadedCallback = null;
    return;
  }

  JSONObject jsonFont;
  try
  {
    // Try and load it
    jsonFont = loadJSONObject(file.getAbsolutePath());
  }
  catch (RuntimeException ex)
  {
    // Whoops!
    Popup.show(file.getName() + " is not a valid font file.", 5);
    fontLoadedCallback = null;
    return;
  }


  //fontLoadedCallback.onFontLoaded();
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
