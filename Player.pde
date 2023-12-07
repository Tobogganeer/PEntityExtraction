static class Player
{
  static final float drawSize = 50;

  PVectorInt position;
  Game game;
  int health;
  int ammo;
  ArrayList<ItemCard> cards;
  int remainingActions;
  Player carriedPlayer;

  int playerNumber;

  Player(Game game, int playerNumber)
  {
    this.game = game;
    health = game.settings.maxHealth;
    ammo = game.settings.maxAmmo;
    cards = new ArrayList<ItemCard>();
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
