class Button
{
  color normal = color(200);
  color hover = color(180, 180, 200);
  color clicked = color(215, 215, 200);
  Rect rect;
  String label;

  boolean mouseDown;
  boolean enabled = true;

  Button(float x, float y, float w, float h, String label)
  {
    rect = new Rect(x, y, w, h);
    this.label = label;
  }

  void display()
  {
    // We are turned off
    if (!enabled)
      return;

    // Set colour and display our rect
    fill(mouseDown ? clicked : isHovered() ? hover : normal);
    rect.display();

    // Display our text
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, rect.centerX, rect.centerY);
  }

  boolean isHovered()
  {
    // We are turned off
    if (!enabled)
      return false;
    // We have to mouse over us
    return rect.contains(mouseX, mouseY);
  }

  void setPosition(PVector pos)
  {
    rect.setPosition(pos);
  }
}
