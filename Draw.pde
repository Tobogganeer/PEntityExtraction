import java.util.Stack;

// This is gonna be a fun class
// Utility functions for drawing transformations
static class Draw
{
  static Stack<DrawContext> contexts = new Stack<DrawContext>();
  static final int contextOverflowLimit = 31; // Throws an error if the stack is larger than this
  // Processing has a limit of 32 pushMatrix() calls, so this is lower
  // so we get called first and can give a more descriptive error

  static void start(PVector pos, float rot, float scale)
  {
    // Save current settings
    Applet.get().pushMatrix();
    contexts.push(new DrawContext(currentGraphics()));

    // Apply this new wacky stuff
    translate(pos);
    rotate(radians(rot));
    scale(scale);

    if (contexts.size() > contextOverflowLimit)
    {
      Applet.stop();
      throw new RuntimeException("Draw context stack overflow! Does every Draw.start() have a matching Draw.end()?");
    }
  }

  static void start(PVector pos, float rot)
  {
    start(pos, rot, 1);
  }

  static void start(PVector pos)
  {
    start(pos, 0, 1);
  }

  static void start(float rot)
  {
    start(new PVector(), rot, 1);
  }

  static void start()
  {
    start(new PVector(), 0, 1);
  }


  static void translate(PVector translation)
  {
    if (translation.x != 0 || translation.y != 0)
      Applet.get().translate(translation.x, translation.y);
  }

  static void rotate(float angle)
  {
    if (angle != 0)
      Applet.get().rotate(radians(angle));
  }

  static void scale(float multiplier)
  {
    if (multiplier != 1)
      Applet.get().scale(multiplier);
  }

  static void end()
  {
    if (contexts.size() == 0)
      throw new IllegalStateException("Draw.end() was called more than Draw.start()!");

    Applet.get().popMatrix();
    contexts.pop().apply(currentGraphics());
  }

  private static PGraphics currentGraphics()
  {
    return Applet.get().getGraphics();
  }
}

// https://processing.github.io/processing-javadocs/core/
// Stores current drawing settings
static class DrawContext
{
  int colorMode; // It pains me but I'm going to keep the names identical

  int ellipseMode;

  boolean fill;
  int fillColor; // The pain

  int rectMode;

  boolean stroke;
  int strokeColor;
  float strokeWeight;

  // We don't need text align here, we got our own text system B)
  // But i'll probably add in values from that system once it gets made
  // TODO: Store values from custom font system

  DrawContext(PGraphics src)
  {
    colorMode = src.colorMode;

    ellipseMode = src.ellipseMode;

    fill = src.fill;
    fillColor = src.fillColor;

    rectMode = src.rectMode;

    stroke = src.stroke;
    strokeColor = src.strokeColor;
    strokeWeight = src.strokeWeight;
  }

  void apply(PGraphics target)
  {
    target.colorMode(colorMode);

    target.ellipseMode(ellipseMode);

    target.fill(fillColor);
    if (!fill) target.noFill();

    target.rectMode(rectMode);

    target.stroke(strokeColor);
    if (!stroke) target.noStroke();
    target.strokeWeight(strokeWeight);
  }
}
