// Graphical representation of a card
static class Card
{
  // A standard playing card is apparently 2.5 x 3.5 inches
  static final float width = 250;
  static final float height = 350;
  private static final float borderPadding = 10;
  private static final float elementPadding = 5;
  private static final float headerHeight = 30;
  private static final float imageHeight = 180;
  // We want the card to be drawn centered, so translate etc work properly
  private static final Rect cardRect = new Rect(-width / 2, -height / 2, width, height);
  private static final Rect contentRect = Rect.shrink(cardRect, borderPadding);
  private static final Rect headerRect = Rect.shrink(new Rect(contentRect.x, contentRect.y, contentRect.w, headerHeight), elementPadding);
  //private static final Rect 
  // TODO: Finish this later when movement is done

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
