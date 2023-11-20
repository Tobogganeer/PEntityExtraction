class Player
{
  PVectorInt position;
  Game game;
  int health;
  int ammo;
  ArrayList<ItemCard> cards;
  int remainingActions;
  Player carriedPlayer;

  Player(Game game)
  {
    this.game = game;
    health = game.settings.maxHealth;
    ammo = game.settings.maxAmmo;
    cards = new ArrayList<ItemCard>();
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
    // TODO: Get from board dict or smth
    return null;
  }
}
