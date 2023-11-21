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

  static Menu previous()
  {
    if (historyBuffer.size() < 2)
      return null;
    Menu cur = historyBuffer.pop();
    Menu prev = historyBuffer.peek();
    goTo(cur);
    return prev;
  }
}

static class Layout
{
  // In case you type Layout._ instead of MenuLayout._
  static MenuLayout Vertical = MenuLayout.Vertical;
  static MenuLayout Horizontal = MenuLayout.Horizontal;

  // Spreads the positions evenly throughout the rect
  static void spreadPositions(Rect container, MenuLayout layout, PVector... positions)
  {
    boolean vert = layout == MenuLayout.Vertical;
    PVector offset = new PVector(vert ? 0 : container.w, vert ? container.h : 0);
    offset.div(positions.length);
    for (int i = 0; i < positions.length; i++)
      positions[i] = new PVector(container.x, container.y).add(PVector.mult(offset, i));
  }
}

static class Menu
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
  void draw() {
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

static class MenuItem
{
  String label;
  Rect rect;
  MenuCallback callback;

  MenuItem(String label, Rect rect, MenuCallback callback)
  {
    this.label = label;
    this.rect = rect.copy();
    this.callback = callback;
  }

  void draw(PVector position)
  {
    Draw.start(position);
    {
      PApplet app = Applet.get();
      // Keep the settings that the owner window is using/set for us
      //app.fill(255);
      //app.stroke(0);
      //app.strokeWeight(1);
      app.rectMode(PConstants.CORNER);
      rect.draw();
      Text.box(label, rect, 3, 0); // TODO: Don't hardcode size
    }
    Draw.end();
  }
}





// Begin subclasses --=======================================================================

static class ListMenu extends Menu
{
  Rect elementRect; // Where the buttons are laid out
  MenuLayout layout;
  MenuItem[] menuItems;

  PVector[] itemPositions;

  ListMenu(String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
  {
    this.name = name;
    this.window = window;
    this.elementRect = elementRect;
    this.layout = layout;
    this.menuItems = items;
    this.numElements = menuItems.length;
    itemPositions = new PVector[numElements];
    for (int i = 0; i < numElements; i++)
      itemPositions[i] = new PVector();
    Layout.spreadPositions(elementRect, layout, itemPositions);
  }

  void onInput(Direction input)
  {
    boolean horizontal = layout == MenuLayout.Horizontal;
    if (horizontal && input == Direction.East)
      select(1);
    if (horizontal && input == Direction.West)
      select(-1);
    if (!horizontal && input == Direction.North)
      select(1);
    if (!horizontal && input == Direction.South)
      select(-1);
  }

  void draw()
  {
    Draw.start();
    {
      PApplet app = Applet.get();
      app.rectMode(PConstants.CORNER);
      app.fill(255);
      app.stroke(0);
      app.strokeWeight(1);

      window.draw();
      Text.colour = 0;
      Text.align(TextAlign.TopLeft);
      Text.label(name, window.x + 5, window.y + 5, 4); // TODO: Don't harcode padding and name size

      Text.align(TextAlign.Center);
      for (int i = 0; i < numElements; i++)
        menuItems[i].draw(itemPositions[i]);
    }
    Draw.end();
  }

  void select()
  {
    menuItems[selectedIndex].callback.onSelected(this, selectedIndex);
  }
}

static class ModalMenu extends Menu
{
}
