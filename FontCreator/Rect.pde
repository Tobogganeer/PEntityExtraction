class Rect
{
  float x, y, w, h;
  float centerX, centerY;
  Rect(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    recalculateCenter();
  }
  
  void setPosition(PVector pos)
  {
    x = pos.x;
    y = pos.y;
    recalculateCenter();
  }
  
  void recalculateCenter()
  {
    centerX = x + w / 2;
    centerY = y + h / 2;
  }

  // Is (x, y) within the rect?
  boolean contains(float x, float y)
  {
    return x > this.x && x < this.x + w && y > this.y && y < this.y + h;
  }

  // Just draw the rect
  void display()
  {
    rect(x, y, w, h);
  }
}
