static class Menus
{
  private static Stack<Menu> history = new Stack<Menu>();

  static void back()
  {
    if (history.size() > 0)
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

  // Note: After testing, the top element of the stack is the one with the highest index
  static Menu previous(Menu menu)
  {
    if (menu.menuIndex == 0)
      return null;
    return history.get(menu.menuIndex - 1);
  }
  
  
  
  static MainMenu mainMenu;

  static void initTitleMenus()
  {
    initMainMenu();
  }

  private static void initMainMenu()
  {
    PApplet app = Applet.get();
    Rect window = new Rect(0, 0, app.width, app.height);
    Rect buttonRect = new Rect(0, 0, 300, 80);
    Rect elementsRect = Rect.center(app.width / 2, app.height / 2, buttonRect.w, buttonRect.h * 2.5);

    MenuItem play = new MenuItem("Play", buttonRect, (m, i) -> println("Selected play"));
    MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> println("Selected guide"));

    mainMenu = new MainMenu("ENTITY EXTRACTION", window, elementsRect, MenuLayout.Vertical, play, guide);
    mainMenu.nameAlignment = TextAlign.TopCenter;
    mainMenu.namePadding = 200;
  }
}
