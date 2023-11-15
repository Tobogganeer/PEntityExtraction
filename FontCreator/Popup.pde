
static class Popup
{
  static int frames;
  static String label;
  static PApplet applet;

  static void show(String content, float seconds)
  {
    frames = (int)(seconds * applet.frameRate);
    label = content;
    println("Popup: " + content);
  }
  
  static void display(PApplet applet)
  {
    Popup.applet = applet;
    frames--;
    if (frames > 0)
    {
     float w = applet.textWidth(label);
     float padding = 10;
     
     applet.fill(255);
     applet.rectMode(PConstants.CENTER);
     applet.rect(applet.width / 2, applet.height / 2, w + padding * 2, 24);
     applet.rectMode(PConstants.CORNER);
     
     applet.fill(0);
     applet.textAlign(PConstants.CENTER, PConstants.CENTER);
     applet.text(label, applet.width / 2, applet.height / 2);
    }
  }
  
  class PopupInstance
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
