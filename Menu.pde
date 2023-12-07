static class Layout
{
  // In case you type Layout._ instead of MenuLayout._
  static MenuLayout Vertical = MenuLayout.VERTICAL;
  static MenuLayout Horizontal = MenuLayout.HORIZONTAL;

  // Spreads the positions evenly throughout the rect
  /*
  static void spreadPositions(Rect container, MenuLayout layout, PVector... positions)
   {
   boolean vert = layout == MenuLayout.Vertical;
   PVector offset = new PVector(vert ? 0 : container.w, vert ? container.h : 0);
   offset.div(positions.length);
   for (int i = 0; i < positions.length; i++)
   positions[i] = new PVector(container.x, container.y).add(PVector.mult(offset, i));
   }
   */

  static void spaceRects(PVector position, MenuLayout layout, float padding, MenuItem... items)
  {
    spaceRects(position, layout, padding, rects(items));
  }

  static void spaceRects(PVector position, MenuLayout layout, float padding, Rect... rects)
  {
    position = position.copy();
    for (int i = 0; i < rects.length; i++)
    {
      // Set it to the current position
      rects[i].setPosition(position);
      // Add the width/height + padding
      if (layout == MenuLayout.VERTICAL)
        position.y += rects[i].h + padding;
      else
        position.x += rects[i].w + padding;
    }
  }

  static void spreadRects(Rect container, MenuLayout layout, MenuItem... items)
  {
    spreadRects(container, layout, rects(items));
  }

  // Spreads the rects evenly, accounting for width and height
  static void spreadRects(Rect container, MenuLayout layout, Rect... rects)
  {
    boolean vert = layout == MenuLayout.VERTICAL;

    Rect dims = combineDimensions(rects);

    if (vert)
    {
      // How much empty space there is
      float ySpace = container.h - dims.h;
      // Space between elements + 1 for the top/bottom
      float spacing = ySpace / (rects.length + 1);
      float y = container.y + spacing;
      for (Rect r : rects)
      {
        r.setCenterX(container.centerX());
        r.y = y;
        y += r.h + spacing;
      }
    } else
    {
      // How much empty space there is
      float xSpace = container.w - dims.w;
      // Space between elements + 1 for the left/right
      float spacing = xSpace / (rects.length + 1);
      float x = container.x + spacing;
      for (Rect r : rects)
      {
        r.setCenterY(container.centerY());
        r.x = x;
        x += r.w + spacing;
      }
    }
  }


  static Rect combineDimensions(MenuItem... menuItems)
  {
    return combineDimensions(rects(menuItems));
  }

  // Returns (largestWidth, largestHeight, combinedWidth, combinedHeight);
  static Rect combineDimensions(Rect... rects)
  {
    float largestWidth = 0;
    float largestHeight = 0;
    float combinedWidth = 0;
    float combinedHeight = 0;

    for (Rect rect : rects)
    {
      largestWidth = max(largestWidth, rect.w);
      largestHeight = max(largestHeight, rect.h);
      combinedWidth += rect.w;
      combinedHeight += rect.h;
    }

    return new Rect(largestWidth, largestHeight, combinedWidth, combinedHeight);
  }

  static Rect[] rects(MenuItem... items)
  {
    Rect[] rects = new Rect[items.length];
    for (int i = 0; i < items.length; i++)
      rects[i] = items[i].rect; // Reference type, works fine
    return rects;
  }
}

static class Menu
{
  String name;
  Rect window;
  int selectedIndex;
  int numElements;
  MenuLayout layout;
  boolean drawLastMenu = false;

  float nameSize = 6;
  PVector namePadding = new PVector(5, 10);
  TextAlign nameAlignment = TextAlign.TOPLEFT;
  color windowColour = Colours.menuLight;
  color nameColour = Colours.menuDark;
  boolean drawName = true;

  int menuIndex;

  Menu(String name, Rect window, MenuLayout layout, int numElements)
  {
    this.name = name;
    this.window = window;
    this.layout = layout;
    this.numElements = numElements;
  }

  // Joystick input direction - select and back are handled automatically
  void onInput(Direction input)
  {
    // If statement spaghetti but I think this reads better than a switch statement would
    boolean horizontal = layout == MenuLayout.HORIZONTAL;
    if (horizontal && input == Direction.RIGHT)
      select(1);
    if (horizontal && input == Direction.LEFT)
      select(-1);
    if (!horizontal && input == Direction.UP)
      select(-1);
    if (!horizontal && input == Direction.DOWN)
      select(1);
  }

  void draw()
  {
    if (drawLastMenu)
      Menus.previous(this).draw();

    Draw.start();
    {
      drawWindow();

      drawName();
    }
    Draw.end();
  }

  void select() {
  }

  void back()
  {
    Menus.back();
  }

  void select(int offset)
  {
    selectedIndex += offset;
    if (selectedIndex < 0)
      selectedIndex = numElements - 1;
    else if (selectedIndex >= numElements)
      selectedIndex = 0;
  }

  void drawWindow()
  {
    PApplet app = Applet.get();
    app.rectMode(PConstants.CORNER);
    app.fill(windowColour);
    app.stroke(0);
    app.strokeWeight(1);
    window.draw();
  }

  void drawName()
  {
    if (!drawName)
      return;
    Text.colour = nameColour;
    Text.align(nameAlignment);
    Text.box(name, window, nameSize, namePadding);
  }

  void open()
  {
    Menus.goTo(this);
  }

  void close()
  {
    Menus.close(this);
  }
}

static interface MenuCallback
{
  void onSelected(Menu menu, int index);
}

static class MenuItem
{
  String label;
  Rect rect;
  private MenuCallback callback;

  float textSize = 3;
  PVector padding = new PVector();
  // Custom function just in case Applet isn't initialized (somehow)
  color selectedOutlineColour = Colours.lessPaleBlue;
  color selectedColour = Colours.paleBlue;
  color defaultColour = Colours.menuControl;

  color defaultTextColour = 0;
  color selectedTextColour = 0;

  MenuItem(String label, Rect rect, MenuCallback callback)
  {
    this.label = label;
    this.rect = rect.copy();
    this.callback = callback;
  }

  void draw(boolean isSelected, int selectedIndex, int index)
  {
    Draw.start();
    {
      drawRect(isSelected);
      drawLabel(isSelected);
    }
    Draw.end();
  }

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
}


static class ListMenu extends Menu
{
  Rect elementRect; // Where the buttons are laid out
  MenuItem[] menuItems;
  LayoutMode layoutMode = LayoutMode.SPREAD;
  float offsetLayoutSpacing = 10;

  ListMenu(String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
  {
    super(name, window, layout, items == null ? 0 : items.length);
    this.elementRect = elementRect;
    this.menuItems = items;

    updateLayout();
  }

  void updateLayout()
  {
    if (menuItems == null || menuItems.length == 0)
      return;

    if (layoutMode == LayoutMode.SPREAD)
      Layout.spreadRects(elementRect, layout, menuItems);
    else if (layoutMode == LayoutMode.OFFSET)
      Layout.spaceRects(elementRect.position(), layout, offsetLayoutSpacing, menuItems);
  }

  void changeItems(MenuItem... newItems)
  {
    menuItems = newItems;
    numElements = menuItems.length;
    updateLayout();
  }

  void draw()
  {
    if (drawLastMenu)
      Menus.previous(this).draw();

    Draw.start();
    {
      drawWindow();

      drawName();

      // Only overriden to add this
      drawItems();
    }
    Draw.end();
  }

  void drawItems()
  {
    Text.align(TextAlign.CENTER);
    for (int i = 0; i < numElements; i++)
      // Nothing is selected if we aren't the current menu
      menuItems[i].draw(i == selectedIndex && Menus.isCurrent(this), selectedIndex, i);
  }


  void select()
  {
    menuItems[selectedIndex].select(this, selectedIndex);
  }
}

static class ModalMenu extends ListMenu
{
  static int defaultPromptSize = 4;
  static int defaultChoiceTextSize = 3;
  static MenuLayout defaultLayout = MenuLayout.HORIZONTAL;

  private ModalMenu(String name, Rect window, Rect elementRect, MenuLayout layout, MenuItem... items)
  {
    super(name, window, elementRect, layout, items);
  }

  // Dead simplest, just add the options
  static ModalMenu prompt(String prompt, MenuCallback onChoice, String... choices)
  {
    PVector padding = new PVector(20, 10);
    float height = Text.calculateHeight(1, defaultChoiceTextSize, true);
    float width = 0;
    for (String s : choices) // Get the widest string
      width = max(width, Text.calculateWidth(s, defaultChoiceTextSize));

    Rect choiceRect = new Rect(0, 0, width + padding.x, height + padding.y);
    MenuItem[] items = new MenuItem[choices.length];
    for (int i = 0; i < items.length; i++)
      items[i] = new MenuItem(choices[i], choiceRect, (m, index) -> {
        onChoice.onSelected(m, index);
        m.close();
      }
    );

    return prompt(prompt, items);
  }

  static ModalMenu prompt(String prompt, MenuItem... choices)
  {
    return prompt(prompt, defaultPromptSize, defaultLayout, choices);
  }

  static ModalMenu prompt(String prompt, MenuLayout layout, MenuItem... choices)
  {
    return prompt(prompt, defaultPromptSize, layout, choices);
  }

  static ModalMenu prompt(String prompt, float promptTextSize, MenuLayout layout, MenuItem... choices)
  {
    PApplet app = Applet.get();
    Rect dims = Layout.combineDimensions(choices);
    boolean vert = layout == MenuLayout.VERTICAL;

    float borderpadding = 10; // All around
    float elementPadding = 10; // Between choices
    float promptElementGap = 10; // Between the label and the choices

    // The layout function adds border padding too, so +1
    float totalElementPadding = (choices.length + 1) * elementPadding;

    PVector center = new PVector(app.width / 2, app.height / 2);
    PVector elementDims = new PVector(dims.x, dims.y); // Default is the bounds of the largest elements
    if (vert)
      elementDims.y = dims.h + totalElementPadding; // Expand y to fit all
    else
      elementDims.x = dims.w + totalElementPadding; // Expand x to fit all

    float textWidth = Text.calculateWidth(prompt, promptTextSize);
    elementDims.x = max(elementDims.x, textWidth + elementPadding);

    Rect elementRect = Rect.center(center.x, center.y, elementDims.x, elementDims.y);

    float textHeight = Text.calculateHeight(1, promptTextSize, true);

    // Padding is uneven due to element rect being extra wide (due to layout function)
    PVector paddingRemoval = new PVector(vert ? 0 : elementPadding, vert ? elementPadding : 0);
    Rect window = Rect.grow(elementRect, borderpadding - paddingRemoval.x, borderpadding + promptElementGap - paddingRemoval.y + textHeight);

    // Move the window up, but add in the padding when we are horizontal because ???
    window.changeCenterY(-promptElementGap - textHeight / 2 + paddingRemoval.x);

    ModalMenu menu = new ModalMenu(prompt, window, elementRect, layout, choices);
    menu.drawLastMenu = true;
    menu.nameAlignment = TextAlign.TOPCENTER;
    menu.nameSize = promptTextSize;
    menu.namePadding = new PVector(0, borderpadding);
    menu.open();
    return menu;
  }

  void back() {
    // Can't go back on modal menus - must choose an option
  }
}

static class EmptyMenu extends Menu
{
  EmptyMenu(boolean drawLastMenu)
  {
    // String name, Rect window, MenuLayout layout, int numElements
    super("Empty Menu", Rect.fullscreen(), MenuLayout.HORIZONTAL, 0);
    this.drawLastMenu = drawLastMenu;
  }

  void onInput(Direction input) {
  }

  void draw()
  {
    if (drawLastMenu)
      Menus.previous(this).draw();
  }

  void select() {
  }

  void back() {
  }
}
