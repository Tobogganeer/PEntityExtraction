import java.util.Arrays;

static class Applet
{
  // This exists so I can access it even in static classes
  // A truly global variable
  private static PApplet instance;
  static final int width = 1280;
  static final int height = 1024;

  static PApplet get()
  {
    return instance;
  }

  static void init(PApplet applet)
  {
    instance = applet;
  }

  // Stops the app (useful for exceptions);
  static void stop()
  {
    //instance.stop(); // Not sure if this actually works? Documentation is empty
    exit();
  }

  static void exit()
  {
    instance.exit();
  }

  static void exit(String reason)
  {
    println(reason);
    exit();
  }
}

static class JSON
{
  static <T extends Enum<T>> T getEnum(Class<T> enumType, String json)
  {
    try
    {
      return Enum.valueOf(enumType, json.toUpperCase());
    }
    catch (IllegalArgumentException e)
    {
      // Return null instead of crashing program; we will just not load this card
      return null;
    }
  }
}



// Just a wrapper around a PVector for tile based stuff
static class PVectorInt
{
  PVector vec;

  PVectorInt(PVector vec)
  {
    this.vec = vec;
  }

  PVectorInt(int x, int y)
  {
    this(new PVector(x, y));
  }

  PVectorInt(float x, float y)
  {
    this(new PVector(x, y));
  }

  PVectorInt()
  {
    this(new PVector(0, 0));
  }

  int x()
  {
    return round(vec.x);
  }

  int y()
  {
    return round(vec.y);
  }



  /*
  Credit:
   Reason: Idk how to implement a custom hashcode function lol
   https://stackoverflow.com/questions/16377926/how-to-write-hashcode-method-for-a-particular-class
   */
  @Override
    int hashCode() {
    return Arrays.hashCode(new Object[]{ x(), y() });
  }


  /*
  Credit: Lombo
   Reason: Didn't know the proper way to override equals() in java
   https://stackoverflow.com/questions/2265503/why-do-i-need-to-override-the-equals-and-hashcode-methods-in-java
   */
  @Override
    boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    final PVectorInt other = (PVectorInt) obj;
    return x() == other.x() && y() == other.y();
  }
}
