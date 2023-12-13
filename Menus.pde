static class Menus
{
  private static Stack<Menu> history = new Stack<Menu>();


  static EmptyMenu empty;

  static MainMenu mainMenu;
  static Menu guideMenu;
  static SetupMenu setup;

  static PlayerMenu players;
  static ActionMenu actions;
  static CardsMenu cards;
  static EntitiesMenu entities;
  static ViewMenu view; // Whether we are viewing players or entities

  static ListMenu gameOver;
  //static Menu map;

  // Called only once
  static void initTitleMenus()
  {
    initMainMenu();
    guideMenu = new Menu("Guide (not implemented yet)", Rect.fullscreen(), MenuLayout.HORIZONTAL, 1);
    setup = new SetupMenu();
    empty = new EmptyMenu(true);
    // String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items
    gameOver = new ListMenu("Game Over!", Rect.fullscreen(), new Rect(0, Applet.height / 2, Applet.width, 300), MenuLayout.HORIZONTAL, new MenuItem("Back", new Rect(0, 0, 200, 80), (m, i) -> back()));
    gameOver.nameAlignment = TextAlign.CENTER;
    gameOver.nameSize = 15;
  }

  // Called whenever a game is started
  static void createGameMenus(Game game)
  {
    initPlayerMenu();
    initActionsMenu();
    initCardsMenu();
    initEntitiesMenu();
    initViewMenu();
  }

  static void deleteGameMenus()
  {
    players = null;
    actions = null;
    cards = null;
    entities = null;
    view = null;
    //map = null;
  }


  // === Menu initialization === //

  private static void initMainMenu()
  {
    Rect window = new Rect(0, 0, Applet.width, Applet.height);
    Rect buttonRect = new Rect(0, 0, 300, 80);
    Rect elementsRect = Rect.center(Applet.width / 2, Applet.height / 2, buttonRect.w, buttonRect.h * 2.5);

    MenuItem play = new MenuItem("Play", buttonRect, (main, i) -> {
      Menus.setup.open();
    }
    );

    MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> guideMenu.open());

    mainMenu = new MainMenu("ENTITY EXTRACTION", window, elementsRect, MenuLayout.VERTICAL, play, guide);
  }

  private static void initPlayerMenu()
  {
    Rect window = new Rect(ViewMenu.width, Board.pixelHeight, Applet.width - ViewMenu.width, Applet.height - Board.pixelHeight);
    PlayerMenuItem[] items = new PlayerMenuItem[Game.numPlayers()];
    for (int i = 0; i < items.length; i++)
      items[i] = new PlayerMenuItem("Player " + (i + 1), new Rect(0, 0, window.w / items.length - 5, window.h));//, Game.players()[i]);

    players = new PlayerMenu("Player Menu", window, window, MenuLayout.HORIZONTAL, items);
    players.drawName = false;
  }

  private static void initActionsMenu()
  {
    // String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
    Rect window = new Rect(0, Board.pixelHeight, ActionMenu.width, Applet.height - Board.pixelHeight);
    Rect elementRect = new Rect(20, Board.pixelHeight + 50, 0, 0); // Offset layout, width and height don't matter

    // TODO: Update title with actual actions left
    actions = new ActionMenu(window, elementRect, MenuLayout.VERTICAL);
    actions.layoutMode = LayoutMode.OFFSET;
    //actions.updateLayout();
    actions.nameSize = 3;
    actions.offsetLayoutSpacing = 5;
    actions.nameAlignment = TextAlign.TOPCENTER;
  }

  private static void initCardsMenu()
  {
    // String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
    // TODO: Impl
    Rect window = new Rect(ActionMenu.width, Board.pixelHeight, Applet.width - ActionMenu.width, Applet.height - Board.pixelHeight);
    cards = new CardsMenu("Cards", window);
    cards.nameSize = 3;
    cards.nameAlignment = TextAlign.TOPCENTER;
  }

  private static void initEntitiesMenu()
  {
    // String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
    Rect window = new Rect(ViewMenu.width, Board.pixelHeight, Applet.width - ViewMenu.width, Applet.height - Board.pixelHeight);

    entities = new EntitiesMenu("Entities", window);//, items);
    entities.nameAlignment = TextAlign.TOPCENTER;
    entities.nameSize = 4;
    //entities.drawName = false;
  }

  private static void initViewMenu()
  {
    view = new ViewMenu(new Rect(0, Board.pixelHeight, ViewMenu.width, Applet.height - Board.pixelHeight));
  }



  // === Menu navigation === //

  static void back()
  {
    // Don't allow removing all menus. That's what clear() is for.
    if (history.size() > 1)
      history.pop();
  }

  static void goTo(Menu menu)
  {
    history.push(menu);
    menu.menuIndex = history.size() - 1;
  }

  static Menu current()
  {
    return history.size() > 0 ? history.peek() : null;
  }

  static boolean isCurrent(Menu menu)
  {
    return menu.menuIndex == history.size() - 1;
  }

  // Note: After testing, the top element of the stack is the one with the highest index
  static Menu previous(Menu menu)
  {
    if (menu.menuIndex == 0)
      return null;
    return history.get(menu.menuIndex - 1);
  }

  static void close(Menu menu)
  {
    // Kinda violates the spirit of the stack but OK
    if (menu != null && isInStack(menu))
      history.removeElementAt(menu.menuIndex);

    for (int i = 0; i < history.size(); i++)
      // Gotta recalculate all of these now *sigh*
      history.get(i).menuIndex = i;
  }

  static boolean isInStack(Menu menu)
  {
    return history.contains(menu);
  }

  // Removes all menus
  static void clear()
  {
    history.clear();
  }
}







// ====================================================--- Menu Subclasses ---==================================================== //



static class MainMenu extends ListMenu
{
  MainMenu(String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
  {
    super(name, window, elementRect, layout, items);
    nameAlignment = TextAlign.TOPCENTER;
    namePadding = new PVector(0, 500);
  }

  void back()
  {
    // Can't go back from the main menu silly
    ModalMenu.prompt("Quit game?", (m, i) -> {
      if (i == 0)
      Applet.exit();
    }
    , "Yes", "No");
  }

  void draw()
  {
    super.draw();
    drawControls();
  }

  static void drawControls()
  {
    Rect rect = new Rect(0, Applet.height - 300, 500, 300);
    Draw.start();
    {
      Colours.fill(Colours.menuLight);
      rect.draw(10);
      if (isCabinet)
      {
        Text.box("Controls (hold Player 1 at any time):\nLeft Stick - Navigate menus\nLeft Button - Select\nRight Button - Back\nRight Stick - Move board\nRight Left/Right button - Zoom map", rect, 3, 5);
      } else
      {
        Text.box("Controls (hold tab at any time):\nWASD - Navigate menus\nSpace/Enter - Select\nEscape/Shift/Backspace - Back\nArrow Keys - Move board\nR/F - Zoom map", rect, 3, 5);
      }
    }
    Draw.end();
  }
}



// =========================================================== Setup =========================================================== //



static class SetupMenu extends Menu
{
  int numPlayers;
  int boardSize;

  MenuItem numPlayersItem;
  MenuItem boardSizeItem;
  MenuItem startButton;
  MenuItem backButton;

  static final int maxPlayers = 4;

  SetupMenu()
  {
    super("SETUP", new Rect(0, 0, Applet.width, Applet.height), MenuLayout.VERTICAL, 4);
    float midX = Applet.width / 2;
    float midY = Applet.height / 2;

    nameAlignment = TextAlign.TOPCENTER;
    namePadding = new PVector(0, 500);

    numPlayersItem = new MenuItem("", new Rect(midX, midY - 90, 50, 50), null);
    boardSizeItem = new MenuItem("", new Rect(midX, midY - 30, 120, 50), null);
    startButton = new MenuItem("Start", new Rect(midX - 150, midY + 30, 300, 50), (m, i) -> Game.start(numPlayers, BoardSize.values()[boardSize]));
    backButton = new MenuItem("Back", new Rect(midX - 150, midY + 90, 300, 50), (m, i) -> Menus.back());
  }

  void onInput(Direction input)
  {
    super.onInput(input); // Navigation

    // Index 0 = numPlayers
    if (selectedIndex == 0)
    {
      numPlayers += input == Direction.RIGHT ? 1 : input == Direction.LEFT ? -1 : 0;
      numPlayers = numPlayers < 1 ? maxPlayers : numPlayers > maxPlayers ? 1 : numPlayers;
    }
    // Index 1 = boardSize
    else if (selectedIndex == 1)
    {
      boardSize += input == Direction.RIGHT ? 1 : input == Direction.LEFT ? -1 : 0;
      int maxValue = (BoardSize.LARGE.ordinal() + 1); // Not sure if this is right but it works?
      boardSize = boardSize < 0 ? maxValue : boardSize % maxValue;
    }
  }

  void draw()
  {
    Draw.start();
    {
      drawWindow();

      drawName();

      drawLabelledControl("Players:  ", Integer.toString(numPlayers), numPlayersItem, 0);
      drawLabelledControl("Board Size:  ", BoardSize.values()[boardSize].name(), boardSizeItem, 1);

      Text.align(TextAlign.CENTER);

      startButton.draw(selectedIndex == 2, selectedIndex, 2);
      backButton.draw(selectedIndex == 3, selectedIndex, 3);
    }
    Draw.end();
  }

  void drawLabelledControl(String label, String content, MenuItem item, int index)
  {
    Draw.start();
    {
      item.label = content;
      Text.align(TextAlign.CENTER);
      item.draw(selectedIndex == index, selectedIndex, index);
      Text.align(TextAlign.TOPRIGHT);
      Text.label(label, item.rect.x, item.rect.y, 3);
      if (selectedIndex == index)
      {
        Colours.fill(item.selectedColour);
        Colours.stroke(Colours.menuDark);
        Shapes.triangle(item.rect.center().add(-item.rect.w / 2 - 10, 0), 20, 10, Direction.LEFT);
        Shapes.triangle(item.rect.center().add(item.rect.w / 2 + 10, 0), 20, 10, Direction.RIGHT);
      }
    }
    Draw.end();
  }

  void open()
  {
    super.open();
    // Reset default values
    numPlayers = 3;
    boardSize = 1; // Medium
  }

  void select()
  {
    // Handle inputs
    if (selectedIndex == 2)
      startButton.select(this, selectedIndex);
    else if (selectedIndex == 3)
      backButton.select(this, selectedIndex);
  }
}



// =========================================================== Player Menu =========================================================== //



static class PlayerMenuItem extends MenuItem
{
  Player player;

  PlayerMenuItem(String label, Rect rect)//, Player player)
  {
    //super(label, rect, null);
    super(label, rect, (m, i) ->
    {
      if (Game.get().takingTurn == null)
      Game.get().takingTurn = Game.players()[i];
      Menus.actions.open();
      // Game.selectedPlayer is set automatically by PlayerMenu
    }
    );
  }

  void draw(boolean isSelected, int selectedIndex, int index)
  {
    Draw.start();
    {
      player = Game.players()[index];
      drawRect(isSelected);
      Text.align(TextAlign.TOPCENTER);
      rect.y += 10; // Scuffed padding (out of time)
      drawLabel(isSelected);
      Text.align(TextAlign.CENTERLEFT);
      Text.label("Health: " + player.health, rect.x + 10, rect.y + 50, 3);
      Text.label("Ammo: " + player.ammo, rect.x + 10, rect.y + 90, 3);
      Text.label("Actions Left: " + player.remainingActions, rect.x + 10, rect.y + 130, 3);
      if (Game.takingTurn() == player)
        Text.label("Currently taking turn.", rect.x + 10, rect.y + 170, 3);
      rect.y -= 10;
    }
    Draw.end();
  }

  void drawRect(boolean isSelected)
  {
    PApplet app = Applet.get();
    app.rectMode(PConstants.CORNER);

    if (isSelected)
    {
      app.fill(selectedOutlineColour);
      Rect.grow(rect, 5, 5).draw();
    }

    app.fill(Colours.mix(isSelected ? selectedColour : defaultColour, player.getColour(), 0.3));
    rect.draw();
  }

  /*
  // Breaking these functions off so subclasses can more granularly override them
   void drawRect(boolean isSelected)
   {
   PApplet app = Applet.get();
   app.rectMode(PConstants.CORNER);
   
   if (isSelected)
   {
   app.fill(selectedOutlineColour);
   Rect.grow(rect, 5, 5).draw();
   }
   
   app.fill(isSelected ? selectedColour : defaultColour);
   rect.draw();
   }
   
   void drawLabel(boolean isSelected)
   {
   Text.colour = isSelected ? selectedTextColour : defaultTextColour;
   Text.box(label, rect, textSize, padding);
   }
   
   void select(Menu menu, int selectedIndex)
   {
   if (callback != null)
   callback.onSelected(menu, selectedIndex);
   }
   
   */
}



static class PlayerMenu extends ListMenu
{
  PlayerMenu(String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
  {
    super(name, window, elementRect, layout, items);
  }

  void draw()
  {
    super.draw();
    Game.get().selectedPlayer = Game.players()[selectedIndex];
    Menus.view.draw();
  }

  void onInput(Direction dir)
  {
    super.onInput(dir);
    Menus.view.onInput(dir);
    // Don't pan to a player if we just changed to viewing entities
    if (Menus.isInStack(this))
      Game.board().panTo(Game.players()[selectedIndex].position);
  }

  void open()
  {
    super.open();
    // This is the first menu opened - game might not be properly started yet
    if (Game.exists())
      Game.board().panTo(Game.players()[selectedIndex].position);
  }

  void back()
  {
    ModalMenu.prompt("End Game?", (m, i) ->
    {
      if (i == 1) // Option 2, yes
      Game.end();
    }
    , "No", "Yes");
  }
}







// =========================================================== Action Menu =========================================================== //

static class ActionMenu extends ListMenu
{
  static final int width = 400;

  Player selectedPlayer;
  Player takingTurn;

  MenuItem move;
  MenuItem cards;
  MenuItem pickUpPlayer;
  MenuItem useDoor;
  MenuItem discoverRoom;
  MenuItem dropPlayer;
  MenuItem back;
  MenuItem skipTurn;
  MenuItem endTurn;

  ActionMenu(Rect window, Rect elementRect, MenuLayout layout)
  {
    super("", window, elementRect, layout, new MenuItem[0]);
    createItems();
  }

  void createItems()
  {
    // Yeah, I am hardcoding them here.
    // It goes against my kinda menu designs and blah blah
    // Do we want a game here or not!
    // (I could pass them in the constructor but spite)
    Rect itemRect = new Rect(0, 0, width - 60, 40);
    move = new MenuItem("Move", itemRect, (m, i) ->
      MoveMenu.getMovement(selectedPlayer.position, 2, (pos) -> {
      selectedPlayer.position = pos;
      selectedPlayer.remainingActions--;
      refreshPossibleActions();
    }
    )

    );
    cards = new MenuItem("Cards", itemRect, (m, i) -> Menus.cards.open());
    pickUpPlayer = new MenuItem("Pick Up\n Player #", itemRect, null);
    pickUpPlayer.textSize = 1.5;
    useDoor = new MenuItem("Lock/Unlock Door", itemRect, null);
    //useDoor.textSize = 1.5;
    discoverRoom = new MenuItem("Discover Room", itemRect, (m, i) ->
    {
      ((RoomTile)Game.board().get(selectedPlayer.position)).discover(selectedPlayer);
      selectedPlayer.remainingActions--;
      Menus.actions.refreshPossibleActions();
    }
    );
    //discoverRoom.textSize = 2;
    dropPlayer = new MenuItem("Drop\n Player #", itemRect, null);
    //dropPlayer.textSize = 1.5;
    back = new MenuItem("Back", itemRect, (m, i) -> back());
    skipTurn = new MenuItem("Skip Turn", itemRect, (m, i) ->
      ModalMenu.prompt("Forfeit all actions? Cannot be undone!", (mm, mi) ->
    {
      if (mi == 1) // Yes
      {
        selectedPlayer.remainingActions = 0;
        Menus.actions.refreshPossibleActions();
      }
    }
    , "No", "Yes")
      );
    endTurn = new MenuItem("End Turn", itemRect, (m, i) ->
      ModalMenu.prompt("Forfeit remaining actions? Cannot be undone!", (mm, mi) ->
    {
      if (mi == 1) // Yes
      {
        selectedPlayer.remainingActions = 0;
        Menus.actions.refreshPossibleActions();
      }
    }
    , "No", "Yes")
      );
  }

  void draw()
  {
    if (!Menus.isInStack(Menus.cards))
      Menus.cards.draw(); // Draw the cards if they aren't open

    super.draw();
  }

  void open()
  {
    super.open();

    selectedPlayer = Game.selectedPlayer();
    takingTurn = Game.takingTurn();

    refreshPossibleActions();
  }

  void onInput(Direction input)
  {
    super.onInput(input);
    refreshPossibleActions(); // Refresh every time a key is pressed
  }

  void refreshPossibleActions()
  {
    // Can this player take all actions, or just free ones?
    boolean canTakeAllActions = selectedPlayer == takingTurn && selectedPlayer.remainingActions > 0;
    changeItems(getPossibleActions(selectedPlayer, canTakeAllActions).toArray(new MenuItem[0]));

    if (canTakeAllActions)
      name = "Actions (" + selectedPlayer.remainingActions + " left)";
    else
      name = "Free Actions";
  }

  ArrayList<MenuItem> getPossibleActions(Player p, boolean allActions)
  {
    // move; cards; pickUpPlayer; useDoor; discoverRoom; dropPlayer; back;
    ArrayList<MenuItem> possibleActions = new ArrayList<MenuItem>();
    boolean alive = p.health > 0;
    Tile tile = p.currentTile();

    // Why not one big long if? Because I want actions in a certain order >:(
    if (allActions && alive)
      possibleActions.add(move);
    if (p.cards.size() > 0)
      possibleActions.add(cards);
    if (allActions && alive && p.carriedPlayer == null && anyDownedPlayers(tile))
      possibleActions.add(pickUpPlayer);
    if (allActions && alive && anyNearbyDoors(tile))
      possibleActions.add(useDoor);
    if (allActions && alive && tile.data.type == CardType.ROOM && !((RoomTile)tile).discovered)
      possibleActions.add(discoverRoom);
    if (p.carriedPlayer != null)
      possibleActions.add(dropPlayer);

    if (selectedPlayer.remainingActions == Game.settings().maxActions)
      possibleActions.add(skipTurn);
    if (selectedPlayer.remainingActions < Game.settings().maxActions && selectedPlayer.remainingActions > 0)
      possibleActions.add(endTurn);

    possibleActions.add(back);

    return possibleActions;
  }

  boolean anyDownedPlayers(Tile t)
  {
    for (Player p : t.currentPlayers)
    {
      if (p.down())
        return true;
    }
    return false;
  }

  boolean anyNearbyDoors(Tile t)
  {
    // Does this tile have lockable connections?
    for (Connection c : t.connections)
    {
      if (c.type == ConnectionType.LOCKABLE)
        return true;
    }

    // Do any neighbours have lockable connections attached to this tile?
    for (Tile neighbour : t.neighbours)
    {
      Direction dir = t.dir(neighbour);
      if (neighbour.getConnection(dir.opposite()).type == ConnectionType.LOCKABLE)
        return true;
    }

    return false;
  }

  void back()
  {
    // If we haven't taken any actions yet (or we took all of them), don't lock us into playing our turn.
    if (takingTurn != null && takingTurn.remainingActions == Game.settings().maxActions || takingTurn.remainingActions == 0)
      Game.current.takingTurn = null;
    super.back();
  }
}




// =========================================================== Move Menu =========================================================== //

static interface TileCallback
{
  void callback(PVectorInt position);
}

static class MoveMenu extends Menu
{
  PVectorInt start;
  int maxTiles;
  TileCallback callback;
  ArrayList<Direction> directions;

  MoveMenu(Rect window, PVectorInt start, int maxTiles, TileCallback callback)
  {
    // String name, Rect window, MenuLayout layout, int numElements
    super("", window, MenuLayout.HORIZONTAL, 0);
    this.start = start;
    this.maxTiles = maxTiles;
    this.callback = callback;
    directions = new ArrayList<Direction>();
  }

  void draw()
  {
    drawMovementPreview();

    int tilesLeft = maxTiles - directions.size();
    if (tilesLeft < 1)
      name = "Press Select to move...";
    else if (tilesLeft == 1)
      name = "Move up to 1 more tile, or press Select to move...";
    else
      name = "Move up to " + tilesLeft + " more tiles, or press Select to move...";
    super.draw();
  }

  void drawMovementPreview()
  {
    Board b = Game.board();

    // Apply the board 'matrix'
    Draw.start(b.pan.x * b.zoom + Board.centerX, b.pan.y * b.zoom + Board.centerY, 0, b.zoom);
    {
      float tileSize = Tile.pixelSize;

      Colours.stroke(Colours.moveMenuRed);
      Colours.strokeWeight(15);
      Applet.get().noFill();

      // Draw the starting tile
      Draw.start(b.getWorldPosition(start));
      {
        Applet.get().rectMode(CENTER);
        Applet.get().rect(0, 0, tileSize - 100, tileSize - 100, 50);
      }
      Draw.end();

      PVectorInt currentPos = start.copy();
      for (Direction d : directions)
      {
        // Get the position of this tile
        Draw.start(b.getWorldPosition(currentPos));
        {
          PVector pos = d.getOffset().mult(tileSize / 2);
          pos.y = -pos.y;
          float size = 0.5;
          Shapes.arrow(pos, 160 * size, tileSize * 0.3 * size, 60 * size, tileSize * 0.7 * size, d);
        }
        Draw.end();

        currentPos.add(d.getOffset());
      }
    }
    Draw.end();
  }

  void onInput(Direction input) {
    Board b = Game.board();
    PVectorInt currentPos = start.copy();
    for (Direction d : directions)
      currentPos.add(d.getOffset()); // Apply current moves

    // A tile exists and the path isn't locked
    if (b.get(currentPos).canTravel(input))
    {
      if (directions.size() > 0 && directions.get(directions.size() - 1).oppositeTo(input))
      {
        directions.remove(directions.size() - 1);
        Game.board().panTo(currentPos.copy().sub(input.getOffset()));
      } else if (directions.size() < maxTiles)
      {
        directions.add(input);
        Game.board().panTo(currentPos.copy().add(input.getOffset()));
      }
    }
  }

  // Opens a new menu and calls the callback when the movement is decided
  static MoveMenu getMovement(PVectorInt start, int maxTiles, TileCallback callback)
  {
    // Open the menu ready to move
    MoveMenu menu = new MoveMenu(new Rect(0, Board.pixelHeight, Applet.width, Applet.height - Board.pixelHeight), start, maxTiles, callback);
    menu.nameAlignment = TextAlign.CENTER;
    menu.nameSize = 4;
    menu.open();

    return menu;
  }

  void select()
  {
    Board b = Game.board();
    PVectorInt destination = start.copy();
    for (Direction d : directions)
      destination.add(d.getOffset());

    // We didn't move ._.
    if (destination.equals(start))
    {
      back();
    } else
    {
      // We moved somewhere! Yippee!!
      callback.callback(destination);
      b.updateTiles();
      back();
    }
  }
}




// =========================================================== Cards =========================================================== //


static class CardsMenu extends Menu
{
  static final float smallScale = 0.8;
  static final float hoveredScale = 1.2;
  static final float selectedScale = 1.5;
  static final float anglePerCard = 1.5;
  static final float droopPerDegree = 5; // Pixels moved down

  boolean inspectingCard = false;

  CardsMenu(String name, Rect window)
  {
    // String name, Rect window, MenuLayout layout, int numElements
    super(name, window, MenuLayout.HORIZONTAL, 0);
  }

  void draw()
  {
    // If we are being drawn by the action menu, we don't exist, so don't try drawing the "last" menu
    boolean menuSelected = Menus.isInStack(this);
    drawLastMenu = menuSelected;

    super.draw();

    if (menuSelected && Game.selectedPlayer().cards.size() == 0)
    {
      // If we have no cards, go back to the actions menu
      Menus.actions.refreshPossibleActions();
      back();
      return;
    }

    ArrayList<Card> cards = Game.selectedPlayer().cards;
    numElements = cards.size();

    if (numElements == 0)
    {
      Draw.startContext();
      Text.align(TextAlign.CENTER);
      Text.label("(No Cards)", window.center(), 3);
      Draw.endContext();
    } else
    {
      selectedIndex = min(selectedIndex, numElements - 1);
      int selectedCard = menuSelected ? selectedIndex : -1;
      layoutCards(cards, selectedCard);
      drawCards(cards, selectedCard);
    }
  }

  void layoutCards(ArrayList<Card> cards, int selectedCard)
  {
    // static void layoutCards(Rect window, ArrayList<Card> cards, int selectedCard, float smallScale, float hoveredScale, float anglePerCard, float droopPerDegree, float selectedScale, boolean inspectingCard)
    Layout.layoutCards(window, cards, selectedCard, smallScale, hoveredScale, anglePerCard, droopPerDegree, selectedScale, inspectingCard);

    /*
    float smallCardWidth = Card.width * smallScale;
     float widthBetweenCards = smallCardWidth * 0.9;
     float totalWidth = cards.size() * smallCardWidth;
     PVector center = window.center();
     PVector cardStart = center.copy().sub(totalWidth / 2 - smallCardWidth / 2, 0);
     
     for (int i = 0; i < cards.size(); i++)
     {
     Card card = cards.get(i);
     boolean selected = i == selectedCard;
     
     PVector targetPos = cardStart.copy().add(widthBetweenCards * i, 0);
     if (selected)
     targetPos.add(0, -100);
     
     float targetAngle = 0;
     if (cards.size() > 1 && !selected)
     {
     float cardAngle = cards.size() * anglePerCard;
     targetAngle = map(i, 0, cards.size() - 1, -cardAngle, cardAngle);
     targetPos.add(0, droopPerDegree * abs(targetAngle));
     }
     float targetScale = selected ? hoveredScale : smallScale;
     
     if (inspectingCard && selected)
     {
     targetPos = new PVector(Applet.width / 2, Applet.height / 2);
     targetScale = selectedScale;
     }
     
     card.position = PVector.lerp(card.position, targetPos, Time.deltaTime * 10);
     card.angle = lerp(card.angle, targetAngle, Time.deltaTime * 10);
     card.scale = lerp(card.scale, targetScale, Time.deltaTime * 10);
     }
     */
  }

  static void drawCards(ArrayList<Card> cards, int selectedCard)
  {
    Draw.start();

    // If there is a selected card
    if (selectedCard > -1)
    {
      for (int i = 0; i < cards.size(); i++)
      {
        if (i != selectedCard)
          cards.get(i).draw();
        // TODO: Draw range visualization for weapons
      }

      // Draw an outline around the selected card
      Card selected = cards.get(selectedCard);
      Draw.start(selected.position, selected.angle, selected.scale);
      Colours.stroke(Colours.selectedCardOutline);
      Colours.strokeWeight(3);
      Colours.fill(Colours.selectedCardOutline);
      Rect.grow(Card.cardRect(), 10).draw(5);
      Draw.end();

      // Draw the selected card on top
      cards.get(selectedCard).draw();
    } else
    {
      for (Card card : cards)
      {
        card.draw();
      }
    }

    Draw.end();
  }

  void select()
  {
    inspectingCard = true;

    promptForItemActions();
  }

  void promptForItemActions()
  {
    ArrayList<ModalItem> choices = new ArrayList<ModalItem>();
    Player selected = Game.selectedPlayer();

    Card selectedCard = selected.cards.get(selectedIndex);
    boolean canTakeActions = selected.remainingActions > 0 && selected == Game.takingTurn();

    if (selectedCard.data.type == CardType.CONSUMABLE)
    {
      ConsumableItemData consData = (ConsumableItemData)selectedCard.data;
      if (consData.actionCost == 0 || canTakeActions && consData.actionCost <= selected.remainingActions)
        choices.add(new ModalItem("Use", (m, i) -> {
          selected.discard(selectedCard); // Get rid of card
          for (Effect e : consData.onUse)
          selected.executeEffect(e, selectedCard); // Apply the effects
          selected.remainingActions -= consData.actionCost; // Take the actions
          Menus.actions.refreshPossibleActions();
        }
      ));
    }

    if (selectedCard.data.type == CardType.WEAPON)
    {
      // TODO: Fix - account for ammo, attacks per action, etc
      if (canTakeActions)
        choices.add(new ModalItem("Attack", null));
    }

    if (selected.currentTile().currentPlayers.size() > 1)
      choices.add(new ModalItem("Trade", null));

    if (!selectedCard.data.hasTag(IDs.Tag.NoDiscard))
      choices.add(new ModalItem("Discard", (m, i) -> {
        ModalMenu.prompt("Discard " + selectedCard.data.name + "?", (dm, di) -> {
          if (di == 0) // Yes
          {
            selected.discard(selectedCard);
          }
          inspectingCard = false;
        }
        , "Yes", "No");
        inspectingCard = true; // Keep inspecting while the second modal is active
      }
    ));

    choices.add(new ModalItem("Back", null)); // Going back is the default behaviour, no need for a callback

    String prompt = "Choose an action:";
    // Some cards can't be 'played', so tell the player that
    if (selectedCard.data.type == CardType.EFFECT || selectedCard.data.type == CardType.ENTITYITEM)
      prompt = "(Passive Card) Choose an action:";

    ModalMenu.prompt(prompt, new PVector(Applet.width / 2, 200), (m, i) -> inspectingCard = false, choices.toArray(new ModalItem[0]));
  }

  void open()
  {
    super.open();
    inspectingCard = false;
  }

  void back()
  {
    super.back();
    inspectingCard = false;
  }
}





// =========================================================== Entities =========================================================== //

static class EntitiesMenu extends Menu
{
  // Yeah, a lot of this code will be copied from CardsMenu. No, I don't care right now.

  ArrayList<Card> entityCards;

  EntitiesMenu(String name, Rect window)
  {
    super(name, window, MenuLayout.HORIZONTAL, 0);
    entityCards = new ArrayList<Card>();
  }

  void draw()
  {
    // TODO: Draw cards
    super.draw();

    numElements = entityCards.size();

    if (numElements == 0)
    {
      Draw.startContext();
      Text.align(TextAlign.CENTER);
      Text.label("(No Entities)", window.center(), 3);
      Draw.endContext();
    } else
    {
      selectedIndex = min(selectedIndex, numElements - 1);
      int selectedCard = selectedIndex;
      layoutCards(entityCards, selectedCard);
      drawCards(entityCards, selectedCard);
    }

    Menus.view.draw();
  }

  void layoutCards(ArrayList<Card> cards, int selectedCard)
  {
    // static void layoutCards(Rect window, ArrayList<Card> cards, int selectedCard, float smallScale, float hoveredScale, float anglePerCard, float droopPerDegree, float selectedScale, boolean inspectingCard)
    Layout.layoutCards(window, cards, selectedCard, CardsMenu.smallScale, CardsMenu.hoveredScale, CardsMenu.anglePerCard, CardsMenu.droopPerDegree);
  }

  // Copied from CardsMenu
  void drawCards(ArrayList<Card> cards, int selectedCard)
  {
    CardsMenu.drawCards(cards, selectedCard);
  }

  void onInput(Direction dir)
  {
    super.onInput(dir);
    Menus.view.onInput(dir);
    if (Game.entities().size() > 0 && Menus.isInStack(this))
      Game.board().panTo(Game.entities().get(selectedIndex).position);
  }

  void back()
  {
    super.back();
    Menus.players.open();
    Menus.view.selectedIndex = 0;
  }

  void open()
  {
    super.open();

    entityCards.clear();
    ArrayList<Entity> entities = Game.entities();
    for (int i = 0; i < entities.size(); i++)
    {
      Entity e = entities.get(i);
      e.colourIndex = i; // So they know which order they are in
      Card card = Card.from(e.data);
      card.position = window.center();
      entityCards.add(card);
    }

    numElements = entityCards.size();

    if (Game.entities().size() > 0)
      Game.board().panTo(Game.entities().get(selectedIndex).position);
  }

  // Can't select an entity
  void select() {
  }
}



// =========================================================== View =========================================================== //

static class ViewMenu extends ListMenu
{
  static final float width = 50;

  ViewMenu(Rect window)
  {
    super("", window, window, MenuLayout.VERTICAL, new MenuItem[0]);
    numElements = 2;
  }

  void draw()
  {
    //super.draw();
    Draw.start();
    {
      Colours.fill(Colours.menuLight);
      Colours.stroke(Colours.menuDark);
      Colours.strokeWeight(2);
      window.draw();

      Text.colour = Colours.menuDark;
      Text.align(TextAlign.CENTER);
      Applet.get().rectMode(PConstants.CORNER);
      drawControl(window.y, "Players", selectedIndex == 0);
      drawControl(window.y + window.h / 2, "Entities", selectedIndex == 1);
    }
    Draw.end();
  }

  void drawControl(float height, String label, boolean isSelected)
  {
    Rect r = new Rect(0, height, width, window.h / 2);

    if (isSelected)
    {
      Colours.fill(Colours.lessPaleBlue);
      Rect.grow(r, 5, 5).draw();
    }

    Colours.fill(isSelected ? Colours.paleBlue : Colours.menuControl);
    r.draw();

    // Rotate text sideways
    Draw.start(r.center(), -90);
    Text.label(label, 0, 0, 3);
    Draw.end();
  }

  // This menu is never "open", this is called by the Players and Entities menus
  void onInput(Direction dir)
  {
    int oldSelection = selectedIndex;

    super.onInput(dir);

    if (oldSelection != selectedIndex)
    {
      //Menus.current().back();
      Menus.clear();

      if (selectedIndex == 0) // Players
      {
        Menus.players.open();
      } else
      {
        Menus.entities.open();
      }
    }
  }
}
