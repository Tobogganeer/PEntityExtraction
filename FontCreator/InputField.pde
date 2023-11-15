class InputField
{
  color normal = color(200);
  color hover = color(180, 180, 200);
  color activated = color(200, 180, 180);
  int padding = 5;
  //color clicked = color(215, 215, 200);
  Rect rect;
  String label;
  boolean isActive; // Should be we taking input right now
  boolean mouseDown;

  String content; // The typed in string
  InputType type; // What type of input is this (string, char, or number)

  InputField(float x, float y, float w, float h, String label, InputType type)
  {
    rect = new Rect(x, y, w, h);
    this.label = label;
    content = "";
    this.type = type;
  }

  void display()
  {
    // Draw background
    //fill(isActive ? activated : mouseDown ? clicked : isHovered() ? hover : normal);
    fill(isActive ? activated : isHovered() ? hover : normal);
    rect.display();

    // Label text
    fill(255);
    textAlign(RIGHT, CENTER);
    text(label, rect.x - padding, rect.centerY);

    // Actual content
    fill(0);
    if (type == InputType.CHAR)
    {
      textAlign(CENTER, CENTER);
      text(content, rect.centerX, rect.centerY);
    } else
    {
      textAlign(LEFT, CENTER);
      text(content, rect.x + padding, rect.centerY);
    }
  }

  // Self explanatory really
  boolean isHovered()
  {
    return rect.contains(mouseX, mouseY);
  }

  // Select this when we click on it (technically release the mouse but who's keeping track)
  void onMousePressed()
  {
    isActive = isHovered();
  }

  // Handles key presses
  void onKeyPressed()
  {
    // If we don't want to be typing
    if (!isActive)
      return;

    // If we are taking text input
    if ((type == InputType.STRING || type == InputType.CHAR) && key >= ' ' && key <= '~')
      content = type == InputType.CHAR ? Character.toString(key) : content + key;
    // Maybe a number instead?
    else if (type == InputType.NUMBER && Character.isDigit(key))
      content += key;
    // Deleting a character?
    else if (key == BACKSPACE && content.length() > 0)
      content = content.substring(0, content.length() - 1);
    // Submitting (just deselecting)?
    else if (key == ENTER)
      isActive = false;
  }

  // Deselects and sets the content to be empty
  void reset()
  {
    isActive = false;
    content = "";
  }

  // Returns the content as a number, or -1 if it is invalid
  int numericContent()
  {
    if (type != InputType.NUMBER)
    {
      println("Tried to get a number on a non-numeric input field? Label: " + label);
      return -1;
    }

    if (content.isEmpty())
      return -1;

    try
    {
      // https://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html#parseInt-java.lang.String-
      return Integer.parseInt(content);
    }
    catch (NumberFormatException ex)
    {
      // We might get errors here somehow? We don't care though, keep going
      return -1;
    }
  }
  
  void clamp(int min, int max)
  {
    if (type != InputType.NUMBER)
    {
      println("Tried to clamp a non-numeric input field? Label: " + label);
      return;
    }
    
    int numericValue = numericContent();
    numericValue = constrain(numericValue, min, max);
    content = Integer.toString(numericValue);
  }
}

enum InputType
{
  STRING,
    CHAR,
    NUMBER
}
