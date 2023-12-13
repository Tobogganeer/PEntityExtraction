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
    CardParticle.spawn(card); // Spawn a particle and get it outta here
    cards.remove(card);
  }


  void draw(PVector offset)
  {
    Colours.fill(getColour());
    Applet.get().rect(offset.x, offset.y, 30, 30);
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
}
