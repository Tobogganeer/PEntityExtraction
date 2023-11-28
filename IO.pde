static class IO
{
  // Loads a JSON object from the data folder
  static JSONObject load(String pathFromData)
  {
    if (!exists(pathFromData))
    {
      Popup.show("Load failed: '" + pathFromData + "' does not exist.", 3);
      return null;
    }

    try
    {
      return Applet.get().loadJSONObject(pathFromData);
    }
    catch (RuntimeException ex)
    {
      // Whoops!
      Popup.show("Load failed: '" + pathFromData + "' is not a json object.", 3);
      return null;
    }
  }

  // Loads a JSON array from the data folder
  // TODO: Support loading arrays of cards from disk
  /*
  static JSONArray loadArray(String pathFromData)
  {
    if (!exists(pathFromData))
    {
      Popup.show("Load failed: '" + pathFromData + "' does not exist.", 3);
      return null;
    }

    try
    {
      return Applet.get().loadJSONArray(pathFromData);
    }
    catch (RuntimeException ex)
    {
      // Whoops!
      Popup.show("Load failed: '" + pathFromData + "' is not a json object.", 3);
      return null;
    }
  }
  */

  // Loads all JSON objects from the specified subdirectory of the data folder
  static ArrayList<JSONObject> loadAll(String... subPath)
  {
    ArrayList<JSONObject> objects = new ArrayList<JSONObject>();

    File folder = new File(dataPath(subPath));
    if (!folder.exists() || !folder.isDirectory())
    {
      Popup.show("'" + folder.getPath() + "' is not a valid directory.", 3);
      return objects;
    }

    // https://stackoverflow.com/questions/5694385/getting-the-filenames-of-all-files-in-a-folder
    File[] files = folder.listFiles();
    String dataFolderPath = dataPath() + File.separator;
    int dataFolderLength = dataFolderPath.length();

    for (int i = 0; i < files.length; i++)
    {
      if (files[i].isFile())
      {
        String filePath = files[i].getPath();
        // We only wanna load json objects
        if (filePath.toLowerCase().endsWith(".json"))
        {
          // loadJSONObject() always starts at the data folder, so remove it
          String pathFromDataFolder = filePath.substring(dataFolderLength);
          
          // TODO: Load arrays of objects as well
          //files[i].
          
          JSONObject obj = load(pathFromDataFolder);
          if (obj != null)
            objects.add(obj);
        }
      } else if (files[i].isDirectory())
      {
        objects.addAll(loadAll(files[i].getPath().substring(dataFolderLength)));
      }
    }

    return objects;
  }

  // Concatenates paths together
  static String concatPath(String... parts)
  {
    return String.join(File.separator, parts);
  }

  // Returns the path to the data folder
  static String dataPath()
  {
    return concatPath(Applet.get().sketchPath(), "data");
  }

  // Returns the path created from data/part1/part2/part#
  static String dataPath(String... parts)
  {
    return concatPath(Applet.get().sketchPath(), "data", concatPath(parts));
  }

  // Checks if a file in the data folder exists
  static boolean exists(String... parts)
  {
    File file = new File(dataPath(parts));
    return file.exists();
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
