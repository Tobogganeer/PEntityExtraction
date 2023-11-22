static class Menus
{
  private static Stack<Menu> history = new Stack<Menu>();


  static EmptyMenu empty;

  static MainMenu mainMenu;
  static SetupMenu setup;

  static Menu playerSelect;

  // Called only once
  static void initTitleMenus()
  {
    initMainMenu();
    setup = new SetupMenu();
    empty = new EmptyMenu(true);
  }

  // Called whenever a game is started
  static void createGameMenus(Game game)
  {
    playerSelect = new Menu("Player Select", new Rect(0, 0, 500, 500), MenuLayout.Horizontal, 1);
  }

  static void deleteGameMenus()
  {
    playerSelect = null;
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

    // TODO: Guide menu (extension)
    MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> println("Selected guide"));

    mainMenu = new MainMenu("ENTITY EXTRACTION", window, elementsRect, MenuLayout.Vertical, play, guide);
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
    nameAlignment = TextAlign.TopCenter;
    namePadding = new PVector(0, 500);
  }

  void back()
  {
    // Can't go back from the main menu silly
  }
}

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
    super("SETUP", new Rect(0, 0, Applet.width, Applet.height), MenuLayout.Vertical, 4);
    float midX = Applet.width / 2;
    float midY = Applet.height / 2;

    nameAlignment = TextAlign.TopCenter;
    namePadding = new PVector(0, 500);

    PApplet app = Applet.get();
    numPlayersItem = new MenuItem("", new Rect(midX, midY - 90, 50, 50), null);
    boardSizeItem = new MenuItem("", new Rect(midX, midY - 30, 120, 50), null);
    startButton = new MenuItem("Start", new Rect(midX - 150, midY + 30, 300, 50), (m, i) -> Game.start(numPlayers, BoardSize.fromInt(boardSize)));
    backButton = new MenuItem("Back", new Rect(midX - 150, midY + 90, 300, 50), (m, i) -> Menus.back());
  }

  void onInput(Direction input)
  {
    super.onInput(input); // Navigation

    // Index 0 = numPlayers
    if (selectedIndex == 0)
    {
      numPlayers += input == Direction.Right ? 1 : input == Direction.Left ? -1 : 0;
      numPlayers = numPlayers < 1 ? maxPlayers : numPlayers > maxPlayers ? 1 : numPlayers;
    }
    // Index 1 = boardSize
    else if (selectedIndex == 1)
    {
      boardSize += input == Direction.Right ? 1 : input == Direction.Left ? -1 : 0;
      boardSize = boardSize < 0 ? BoardSize.maxValue : boardSize % BoardSize.maxValue;
    }
  }

  void draw()
  {
    Draw.start();
    {
      drawWindow();

      drawName();

      drawLabelledControl("Players:  ", Integer.toString(numPlayers), numPlayersItem, 0);
      drawLabelledControl("Board Size:  ", BoardSize.fromInt(boardSize).toString(), boardSizeItem, 1);

      Text.align(TextAlign.Center);

      startButton.draw(selectedIndex == 2);
      backButton.draw(selectedIndex == 3);
    }
    Draw.end();
  }

  void drawLabelledControl(String label, String content, MenuItem item, int index)
  {
    Draw.start();
    {
      item.label = content;
      Text.align(TextAlign.Center);
      item.draw(selectedIndex == index);
      Text.align(TextAlign.TopRight);
      Text.label(label, item.rect.x, item.rect.y, 3);
      if (selectedIndex == index)
      {
        Colours.fill(item.selectedColour);
        Colours.stroke(Colours.menuDark);
        Shapes.triangle(item.rect.center().add(-item.rect.w / 2 - 10, 0), 20, 10, Direction.Left);
        Shapes.triangle(item.rect.center().add(item.rect.w / 2 + 10, 0), 20, 10, Direction.Right);
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
