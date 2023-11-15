static class Toggle
{
  // Stateless
  static color normal = 230;
  static color activated = 30;
  
  static void display(PApplet applet, Rect rect, boolean active)
  {
    applet.fill(active ? activated : normal);
    rect.display();
  }
}
