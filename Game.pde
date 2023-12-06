// Mainly used to store data. For more functionality during the game, see Board.pde
static class Game
{
  static Game current;

  // None of these are static so it's easier to fully reset the game
  Turn turn;
  Settings settings;
  Board board;
  Player[] players;
  int numPlayers; // May be redundant, idc it is shorter to type

  Player selectedPlayer;
  Player takingTurn;


  private Game(int numPlayers)
  {
    turn = Turn.PLAYER;
    settings = new Settings(3, 5, 4);
    this.numPlayers = numPlayers;

    // Init the board and players
    board = new Board();
    players = new Player[numPlayers];
    for (int i = 0; i < numPlayers; i++)
      players[i] = new Player(this, i);
  }

  static void end()
  {
    // Delete the old game
    current = null;
    // Go back to the main menu
    Menus.clear();
    Menus.deleteGameMenus();
    Menus.mainMenu.open();
  }

  static Game get()
  {
    return current;
  }

  static boolean exists()
  {
    return current != null;
  }

  static Turn turn()
  {
    return current.turn;
  }

  static int numPlayers()
  {
    return current.numPlayers;
  }

  static Player[] players()
  {
    return current.players;
  }

  static Board board()
  {
    return current.board;
  }

  static Player selectedPlayer()
  {
    return current.selectedPlayer;
  }

  static Player takingTurn()
  {
    return current.takingTurn;
  }


  // Called when we actually want to start the game
  static void start(int numPlayers, BoardSize boardSize)
  {
    // Create the game
    current = new Game(numPlayers);

    // Generate the board (places players down too)
    current.board.generate(boardSize);

    // Load the game menu and begin play
    Menus.clear();
    Menus.createGameMenus(current);
    Menus.players.open();
    println("Game started! " + boardSize.toString() + " board, " + numPlayers + " players.");
  }

  static void update()
  {
    // Nothing to update if we are on the main menu
    if (!exists())
      return;

    current.tick();

    current.draw();
  }



  private void tick()
  {
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
