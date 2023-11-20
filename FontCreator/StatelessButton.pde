static class StatelessButton
{
  static color normal;
  static color hover;
  static color clicked;
  static boolean coloursInited;

  static void display(PApplet applet, Rect rect, String label, boolean mouseDown)
  {
    // Init colours if they haven't been already
    initColours(applet);
    
    // Set colour and display our rect
    applet.fill(mouseDown ? clicked : isHovered(applet, rect) ? hover : normal);
    rect.display();

    // Display our text
    applet.fill(0);
    applet.textAlign(CENTER, CENTER);
    applet.text(label, rect.centerX, rect.centerY);
  }

  static boolean isHovered(PApplet applet, Rect rect)
  {
    // We have to mouse over us
    return rect.contains(applet.mouseX, applet.mouseY);
  }

  static void initColours(PApplet applet)
  {
    if (!coloursInited)
    {
      coloursInited = true;
      normal = applet.color(200);
      hover = applet.color(180, 180, 200);
      clicked = applet.color(215, 215, 200);
    }
  }
}
