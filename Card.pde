import java.util.Collections;

static class CardPile
{
  Stack<CardData> cards;

  CardPile(CardData... cards)
  {
    this.cards = new Stack<CardData>();
    for (CardData card : cards)
      add(card);
    shuffle();
  }

  CardPile(ArrayList<CardData> cards)
  {
    this.cards = new Stack<CardData>();
    for (CardData card : cards)
      add(card);
    shuffle();
  }

  void addToTop(CardData card)
  {
    cards.push(card);
  }

  // Adds a card and then shuffles the deck
  void add(CardData card)
  {
    cards.push(card);
    shuffle();
  }

  void shuffle()
  {
    // https://stackoverflow.com/questions/16112515/how-to-shuffle-an-arraylist
    Collections.shuffle(cards);
  }

  CardData pull()
  {
    return cards.pop();
  }

  boolean isEmpty()
  {
    return cards.size() == 0;
  }

  int cardsLeft()
  {
    return size();
  }

  int size()
  {
    return cards.size();
  }
}




// Graphical representation of a card
static class Card
{
  // A standard playing card is apparently 2.5 x 3.5 inches
  static final float width = 250;
  static final float height = 350;
  private static final float borderPadding = 16;
  private static final float elementPadding = 10;
  private static final float headerHeight = 30;
  private static final float imageHeight = 112; // W=224, H=112
  // We want the card to be drawn centered, so translate etc work properly
  private static final Rect cardRect = new Rect(-width / 2, -height / 2, width, height);
  private static final Rect contentRect = Rect.shrink(cardRect, borderPadding);
  private static final Rect headerRect = Rect.shrink(new Rect(contentRect.x, contentRect.y, contentRect.w, headerHeight + elementPadding), elementPadding);
  private static final Rect imageRect = new Rect(headerRect.x, headerRect.y + headerRect.h + elementPadding, headerRect.w, imageHeight);
  private static final Rect descriptionRect = new Rect(imageRect.x, imageRect.y + imageRect.h + elementPadding, imageRect.w, contentRect.h - imageRect.h - headerRect.h - elementPadding * 3);

  CardData data;

  Card(CardData data)
  {
    this.data = data;
  }

  static Rect cardRect()
  {
    return cardRect.copy();
  }

  static Rect contentRect()
  {
    return contentRect.copy();
  }

  static Rect headerRect()
  {
    return headerRect.copy();
  }

  static Rect imageRect()
  {
    return imageRect.copy();
  }

  static Rect descriptionRect()
  {
    return descriptionRect.copy();
  }

  static PVector size()
  {
    return new PVector(width, height);
  }

  void draw()
  {
    Draw.start();
    {
      // TODO: Make this not temp drawing
      Colours.fill(255, 150, 150);
      Colours.stroke(0);
      Colours.strokeWeight(2);
      cardRect.draw(5);
      Colours.fill(180);
      contentRect.draw(5);
      Colours.fill(255);
      headerRect.draw(5);
      imageRect.draw(5);
      descriptionRect.draw(5);
    }
    Draw.end();
  }
}


static class ItemCard extends Card
{
  // TODO: Impl
  ItemCard(CardData data)
  {
    super(data);
  }
}
