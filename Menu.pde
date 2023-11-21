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
  Rect window;
  //MenuType type;
  //MenuItem[] itemList;
  int selectedIndex;
  int numElements;

  // Joystick input direction - select and back are handled automatically
  void onInput(Direction input) {
  }
  void display() {
  }
  void select() {
  }
  void back() {
    History.back();
  }

  void select(int offset)
  {
    selectedIndex += offset;
    if (selectedIndex < 0)
      selectedIndex = numElements - 1;
    else if (selectedIndex >= numElements)
      selectedIndex = 0;
  }
}

class MenuItem
{
  String label;
  Rect rect;
  MenuCallback callback;

  MenuItem(String label, Rect rect, MenuCallback callback)
  {
    this.label = label;
    this.rect = rect;
    this.callback = callback;
  }
}





// Begin subclasses --=======================================================================

class ListMenu extends Menu
{
  Rect elementRect; // Where the buttons are laid out
  ListMenuType type;
  MenuItem[] menuItems;

  ListMenu(String name, Rect window, Rect elementRect, ListMenuType type, MenuItem... items)
  {
    this.name = name;
    this.window = window;
    this.elementRect = elementRect;
    this.type = type;
    this.menuItems = items;
    this.numElements = menuItems.length;
  }

  void onInput(Direction input)
  {
    boolean horizontal = type == ListMenuType.Horizontal;
    if (horizontal && input == Direction.East)
      select(1);
    if (horizontal && input == Direction.West)
      select(-1);
    if (!horizontal && input == Direction.North)
      select(1);
    if (!horizontal && input == Direction.South)
      select(-1);
  }

  void display()
  {
  }

  void select()
  {
    menuItems[selectedIndex].callback.onSelected(this, selectedIndex);
  }
}

class ModalMenu extends Menu
{
}
