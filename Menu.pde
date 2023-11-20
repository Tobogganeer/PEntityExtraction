static class History
{
  private static Stack<Menu> historyBuffer = new Stack<Menu>();

  static void back()
  {
    // Our first menu is very precious and we are gonna keep it
    if (historyBuffer.size() > 0)
      historyBuffer.pop();
  }

  static void goTo(Menu menu)
  {
    historyBuffer.push(menu);
  }

  static Menu current()
  {
    return historyBuffer.size() > 0 ? historyBuffer.peek() : null;
  }
}

class Menu
{
  String name;
  //MenuType type;
  MenuItem[] itemList;
  int selectedIndex;
  MenuCallback back = (m, i) -> History.back();

  // Joystick input direction - enter and back are handled automatically
  void onInput(Direction input) {
  }

  void display() {
  }
}

class MenuItem
{
  String label;
  MenuCallback callback;

  void display() {
  }
}

// Begin subclasses -----------------------
