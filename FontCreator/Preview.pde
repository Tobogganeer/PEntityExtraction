// Draws letters to the screen
class Preview
{
  Rect rect;
  
  Preview(Rect rect)
  {
   this.rect = rect; 
  }
  
  void display(ArrayList<Letter> letters, float size)
  {
    
  }
  
  void drawLetter(Letter l, PVector pos, float size)
  {
    float w = pixelWidth(l, size);
    float h = pixelHeight(l, size);
    //if (rect.x + rect.w
  }
  
  float pixelWidth(Letter l, float size)
  {
    return l.width * size;
  }
  
  float pixelHeight(Letter l, float size)
  {
    return l.width * size;
  }
}
