
static class Popup
{
  static ArrayList<PopupInstance> popups = new ArrayList<PopupInstance>();
  static PApplet applet;
  static int spacing = 30;

  static void show(String content, float seconds)
  {
    int frames = (int)(seconds * applet.frameRate);
    popups.add(new PopupInstance(content, frames));
    println("Popup: " + content);
  }

  static void display(PApplet applet)
  {
    Popup.applet = applet;

    for (int i = popups.size(); i > 0; )
    {
      i--;
      PopupInstance instance = popups.get(i);
      instance.frames--;

      if (instance.frames <= 0)
      {
        popups.remove(i);
      }
      else
      {
       drawInstance(i, instance); 
      }
    }
  }

  private static void drawInstance(int index, PopupInstance instance)
  {
    float w = applet.textWidth(instance.label);
    float padding = 10;
    float y = applet.height / 2 + spacing * index;

    applet.fill(255);
    applet.rectMode(PConstants.CENTER);
    applet.rect(applet.width / 2, y, w + padding * 2, 24);
    applet.rectMode(PConstants.CORNER);

    applet.fill(0);
    applet.textAlign(PConstants.CENTER, PConstants.CENTER);
    applet.text(instance.label, applet.width / 2, y);
  }

  static class PopupInstance
  {
    String label;
    int frames;

    PopupInstance(String label, int frames)
    {
      this.label = label;
      this.frames = frames;
    }
  }
}
