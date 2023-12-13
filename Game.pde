// Mainly used to store data. For more functionality during the game, see Board.pde
static class Game
{
  static Game current;

  // None of these are static so it's easier to fully reset the game
  Turn turn;
  Settings settings;
  Board board;
  Player[] players;
  ArrayList<Entity> entities;
  int numPlayers; // May be redundant, idc it is shorter to type

  Player selectedPlayer;
  Player takingTurn;

  CardPile entityCards;
  CardPile itemCards;


  private Game(int numPlayers)
  {
    turn = Turn.PLAYER;
    settings = new Settings(3, 5, 4, 2);
    this.numPlayers = numPlayers;

    // Init the board and players
    board = new Board();
    players = new Player[numPlayers];
    for (int i = 0; i < numPlayers; i++)
      players[i] = new Player(this, i);
    entities = new ArrayList<Entity>();
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

  static Settings settings()
  {
    return current.settings;
  }

  static Player[] players()
  {
    return current.players;
  }

  static ArrayList<Entity> entities()
  {
    return current.entities;
  }

  static int numPlayers()
  {
    return current.numPlayers;
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

    // "Shuffle" the cards
    current.reshuffleItems();
    current.reshuffleEntities();

    // Load the game menu and begin play
    Menus.clear();
    Menus.createGameMenus(current);
    Menus.players.open();
    println("Game started! " + boardSize.toString() + " board, " + numPlayers + " players");

    current.giveStartingItems();

    current.startPlayerTurns();
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
    checkTurns();

    if (turn == Turn.ENTITY)
      takeEntityTurns();

    checkGameOver();
  }

  void checkTurns()
  {
    if (turn == Turn.PLAYER)
    {
      boolean anyPlayerHasActions = false;

      for (Player p : players)
      {
        if (p.remainingActions > 0)
        {
          anyPlayerHasActions = true;
          break;
        }
      }

      if (!anyPlayerHasActions)
      {
        startEntityTurn();
      }
    } else
    {
      if (entities.size() == 0)
      {
        startPlayerTurns();
      } else
      {
        boolean anyEntityHasActions = false;

        for (Entity e : entities)
        {
          if (!e.takenTurn)
          {
            anyEntityHasActions = true;
            break;
          }
        }

        if (!anyEntityHasActions)
          startPlayerTurns();
      }
    }
  }

  void takeEntityTurns()
  {
  }

  void checkGameOver()
  {
    boolean anyPlayersAlive = false;

    for (Player p : players)
    {
      if (p.alive())
      {
        anyPlayersAlive = true;
        break;
      }
    }

    // Ruh roh raggy
    if (!anyPlayersAlive)
    {
      Game.end();
      Menus.gameOver.open();
    }
  }

  void spawnEntity(PVectorInt position, EntityData data)
  {
    entities.add(new Entity(position, data));
  }



  private void draw()
  {
    board.draw();
  }

  // TODO: Keep currently held cards out of the shuffle
  void reshuffleItems()
  {
    current.itemCards = CardPiles.getItems();
  }

  void reshuffleEntities()
  {
    current.entityCards = CardPiles.getEntities();
  }

  void giveStartingItems()
  {
    CardPile smallWeapons = CardPiles.getSmallWeapons();
    for (Player p : players)
    {
      p.give(smallWeapons.pull());
      p.give(itemCards.pull());
    }
  }

  void startPlayerTurns()
  {
    turn = Turn.PLAYER;
    for (Player p : players)
    {
      p.remainingActions = settings.maxActions;

      for (Card card : p.cards)
      {
        // Execute EntityItem effects for owners
        if (card.data.type == CardType.ENTITYITEM)
        {
          EntityItemData eiData = (EntityItemData)card.data;
          for (Effect e : eiData.onOwnerTurn)
            p.executeEffect(e, card);
        }
      }
    }
  }

  void startEntityTurn()
  {
    turn = Turn.ENTITY;

    for (Entity e : entities)
    {
      e.takenTurn = false;
    }
  }




  class Settings
  {
    final int maxHealth;
    final int maxAmmo;
    final int maxItems;
    final int maxActions;

    Settings(int maxHealth, int maxAmmo, int maxItems, int maxActions)
    {
      this.maxHealth = maxHealth;
      this.maxAmmo = maxAmmo;
      this.maxItems = maxItems;
      this.maxActions = maxActions;
    }
  }
}
