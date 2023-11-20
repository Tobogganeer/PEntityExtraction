import java.util.Arrays;



static class GlobalPApplet
{
  // This exists so I can access it even in static classes
  // A truly global variable
  private static PApplet instance;

  static PApplet get()
  {
    return instance;
  }

  static void init(PApplet applet)
  {
    instance = applet;
  }
}



// Just a wrapper around a PVector for tile based stuff
class PVectorInt
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
