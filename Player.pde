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
    return Game.board().getTile(position);
  }

  void draw(PVector offset)
  {
    if (Game.selectedPlayer() == this)
      Colours.fill(255, 0, 0);
    else
      Colours.fill(0, 0, 255);
    Applet.get().rect(offset.x, offset.y, 30, 30);
  }


  void executeEffect(Effect effect, Card card)
  {
    EffectExecutor.execute(effect, new Context(this, card));
  }
}
