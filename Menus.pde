static class Menus
{
  private static Stack<Menu> history = new Stack<Menu>();

  static MainMenu mainMenu;

  static void initTitleMenus()
  {
    initMainMenu();
  }


  // === Menu initialization === //

  private static void initMainMenu()
  {
    PApplet app = Applet.get();
    Rect window = new Rect(0, 0, app.width, app.height);
    Rect buttonRect = new Rect(0, 0, 300, 80);
    Rect elementsRect = Rect.center(app.width / 2, app.height / 2, buttonRect.w, buttonRect.h * 2.5);

    MenuItem play = new MenuItem("Play", buttonRect, (main, i) -> {
      Rect buttonSize = new Rect(0, 0, 150, 75);
      MenuItem confirm = new MenuItem("Yes", buttonSize, (modal, modalI) ->
      {
        modal.close();
        println("Yes!!!!");
      }
      );
      MenuItem cancel = new MenuItem("No", buttonSize, (modal, modalI) ->
      {
        modal.close();
        println("No :(");
        ModalMenu.prompt("Really really sure?", (subModal, subI) ->
        {
          if (subI == 0)
          println("Man, they are really sure...");
          else
            println("We changed them!!!!");
        }
        , "YES!!!", "Um... Not anymore...");
      }
      );
      ModalMenu.prompt("You sure???", confirm, cancel);
    }
    );
    MenuItem guide = new MenuItem("Guide", buttonRect, (m, i) -> println("Selected guide"));

    mainMenu = new MainMenu("ENTITY EXTRACTION", window, elementsRect, MenuLayout.Vertical, play, guide);
    mainMenu.nameAlignment = TextAlign.TopCenter;
    mainMenu.namePadding = new PVector(0, 200);
  }



  // === Menu navigation === //

  static void back()
  {
    if (history.size() > 0)
      history.pop();
  }

  static void goTo(Menu menu)
  {
    history.push(menu);
    menu.menuIndex = history.size() - 1;
    println("Added new menu (" + menu.name + ") with index " + menu.menuIndex);
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
}
