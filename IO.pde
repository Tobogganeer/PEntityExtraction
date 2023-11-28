static class IO
{
  // Loads a JSON object from the data folder
  static JSONObject load(String path)
  {
    try
    {
      return Applet.get().loadJSONObject(path);
    }
    catch (RuntimeException ex)
    {
      // Whoops!
      Popup.show("Load failed: '" + path + "' is not a json object.", 3);
      return null;
    }
  }

  static String concatPath(String... parts)
  {
    return String.join(File.pathSeparator, parts);
  }

  static String dataPath(String... parts)
  {
    return concatPath(Applet.get().sketchPath(), "data", concatPath(parts));
  }

  static boolean exists(String path)
  {
    File file = new File(path);
    return file.exists();
  }

  static boolean dataExists(String... parts)
  {
    return exists(dataPath(parts));
  }



  // ============================= FONT ============================= //

  static Font loadFont(String path)
  {
    JSONObject jsonFont = load(path);

    if (jsonFont == null)
      return null;

    String version = jsonFont.getString("version");
    JSONArray letterArray = jsonFont.getJSONArray("letters");
    ArrayList<Letter> letters = new ArrayList<Letter>();

    for (int i = 0; i < letterArray.size(); i++)
    {
      Letter l = jsonToLetter(letterArray.getJSONObject(i));
      if (l != null)
        letters.add(l);
    }

    Font font = new Font(letters, version);
    println("Successfully loaded '" + path + "' " + version + " (" + letters.size() + " letters)");
    return font;
  }

  private static Letter jsonToLetter(JSONObject json)
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




  // ============================= ENTITY DATA ============================= //
}
