static class Game
{
  static Game current;

  // None of these are static so it's easier to fully reset the game
  GameState state;
  Settings settings;
  Board board;
  Player[] players;

  private Game()
  {
    state = GameState.MainMenu;
    settings = new Settings(3, 5, 4);
  }

  static void create()
  {
    current = new Game();
  }

  static void end()
  {
    // Delete the old game
    create();
    // Go back to the main menu
    Menus.clear();
    Menus.mainMenu.open();
  }

  static boolean exists()
  {
    return current != null;
  }


  static GameState state()
  {
    return current.state;
  }


  // Called when we actually want to start the game
  static void start(int numPlayers, BoardSize boardSize)
  {
    // Init the board and players
    current.board = new Board(boardSize);
    current.board.generate();
    current.players = new Player[numPlayers];
    for (int i = 0; i < numPlayers; i++)
      current.players[i] = new Player(current);

    // Load the game menu and begin play
    Menus.clear();
    Menus.playerSelect.open();
    current.state = GameState.PlayerTurn;
    println("Game started! " + boardSize.toString() + " board, " + numPlayers + " players.");
  }

  static void update()
  {
    // Nothing to update if we are on the menu
    if (!exists() || state() == GameState.MainMenu)
      return;

    current.draw();
  }

  private void draw()
  {
    board.draw();
  }




  class Settings
  {
    final int maxHealth;
    final int maxAmmo;
    final int maxItems;

    Settings(int maxHealth, int maxAmmo, int maxItems)
    {
      this.maxHealth = maxHealth;
      this.maxAmmo = maxAmmo;
      this.maxItems = maxItems;
    }
  }
}
