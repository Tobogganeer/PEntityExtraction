static class Player
{
  static final float drawSize = 50;

  PVectorInt position;
  Game game;
  int health;
  int ammo;
  ArrayList<Card> cards;
  int remainingActions;
  Player carriedPlayer;

  int playerNumber;

  int damageMultiplier = 1;

  Player(Game game, int playerNumber)
  {
    this.game = game;
    health = game.settings.maxHealth;
    ammo = game.settings.maxAmmo;
    cards = new ArrayList<Card>();
    this.playerNumber = playerNumber;
  }

  // Called when the game starts and the player is actually
  // placed on the board
  void init(PVectorInt position)
  {
    this.position = position;
    // TODO: Check if position is valid
    // game.board.doesTileExist(); or smth
  }

  void onPlayerTurnsStart()
  {
    damageMultiplier = 1;
  }

  Tile currentTile()
  {
    return Game.board().get(position);
  }

  boolean alive()
  {
    return health > 0;
  }

  boolean down()
  {
    return health <= 0;
  }

  int maxCards()
  {
    return hasCard(IDs.Entity.Item.Backpack) ? 6 : Game.settings().maxItems;
  }

  void heal(int amount)
  {
    health = min(health + amount, Game.settings().maxHealth);
  }

  void damage(int amount)
  {
    health = max(health - amount, 0);
  }

  void reload(int amount)
  {
    ammo = min(ammo + amount, Game.settings().maxAmmo);
  }

  void give(Card card)
  {
    card.position = Menus.cards.window.center();
    cards.add(card);
    if (card.data.type == CardType.ENTITYITEM)
    {
      EntityItemData eiData = (EntityItemData)card.data;
      for (Effect e : eiData.onDiscovery)
        executeEffect(e, card);
    }
  }

  void discard(Card card)
  {
    if (!cards.contains(card))
      return;

    CardParticle.spawn(card); // Spawn a particle and get it outta here
    cards.remove(card);
  }

  void discardRandomCard()
  {
    if (cards.size() == 0)
      return;

    int safety = 1000;
    while (safety --> 0)
    {
      Card c = cards.get((int)Applet.get().random(cards.size()));
      if (!c.data.hasTag(IDs.Tag.NoDiscard))
      {
        discard(c);
        return;
      }
    }

    if (safety == 0)
      Popup.show("Player " + (playerNumber + 1) + " failed to discard a random card", 5);
  }

  boolean hasCard(String id)
  {
    for (Card c : cards)
      if (c.data.is(id))
        return true;
    return false;
  }


  void draw(PVector offset)
  {
    Draw.start();
    {
      Colours.fill(getColour());
      float size = 30;
      Applet.get().rect(offset.x, offset.y, size, size);
      Text.align(TextAlign.CENTER);
      Text.colour = 255; // White
      Text.label(Integer.toString(playerNumber + 1), offset.x + size / 2, offset.y + size / 2, 2);
    }
    Draw.end();
  }

  int getColour()
  {
    if (Game.selectedPlayer() == this)
      return Game.takingTurn() == this ? Colours.turnSelectedPlayer : Colours.selectedPlayer;
    else
      return Game.takingTurn() == this ? Colours.turnPlayer : Colours.player;
  }


  void executeEffect(Effect effect, Card card)
  {
    EffectExecutor.execute(effect, new Context(this, card));
  }

  void executeEffect(Effect effect, Context ctx)
  {
    EffectExecutor.execute(effect, ctx);
  }

  // Note: Doesn't update tiles (called by EffectExecutor)
  void moveTowards(PVectorInt target)
  {
    Path path = new Path(position, target, Game.board());
    if (path.steps.length > 0)
      position.add(path.steps[0].getOffset());
  }
}
