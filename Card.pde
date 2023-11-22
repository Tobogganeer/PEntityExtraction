// Graphical representation of a card
static class Card
{
  // A standard playing card is apparently 2.5 x 3.5 inches
  static final float width = 250;
  static final float height = 350;
  
  static Rect rect()
  {
   return new Rect(0, 0, width, height); 
  }
  
  static PVector size()
  {
   return new PVector(width, height); 
  }
  
  // TODO: Impl
}

static class ItemCard extends Card
{
  // TODO: Impl
}
