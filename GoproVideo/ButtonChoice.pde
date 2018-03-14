public class ButtonChoice<T> implements Button, GoProStatus.StatusEventListener {
  String label = "";
  int x;
  int y;
  ArrayList<ButtonOnOff> btns;
  SettingsOptions<T>[] options;
  Class theT;
  
  public ButtonChoice(String label, int x, int y, int w, int h, SettingsOptions<T>[] options, Class<T> theT) {
    this.label = label;
    this.x=x;
    this.y=y;
    this.theT = theT;
    this.options = options;
    btns = new ArrayList<ButtonOnOff>();
    for(int i = 0; i<options.length; i++) {
      SettingsOptions<T> opt = options[i];
      ButtonOnOff btn = new ButtonOnOff(x+(w*(i+1)), y, w, h, opt.getLabel(), opt.getTrigger());
      btn.setBehaviour(true, false);
      btns.add(btn);
    }
    GoProStatus.getInstance(PAPPLET).register(this);
  }
  
  public void draw() {
    fill(255);
    textAlign(LEFT,TOP);
    text(label, x,y);
    for(ButtonOnOff btn : btns) {
      btn.draw();
    }
  }
  
  public boolean checkClick(int varx, int vary) {
    for(ButtonOnOff btn : btns) {
      boolean wasClicked = btn.checkClick(varx,vary);
      if(wasClicked) {
        for(ButtonOnOff btn2 : btns) {
          if(!btn2.equals(btn)) {
            btn2.setOn(false);
          }
        }
        return true;
      }
    }
    return false;
  }
  
  public void valuesUpdated(JSONObject newStatus) {
    for(SettingsOptions opt : options) {
      JSONObject settings = newStatus.getJSONObject("settings");
      if((theT == Integer.class && settings.getInt(opt.getKey()) == (Integer)opt.getValue()) ||
        (theT == String.class && settings.getString(opt.getKey()) == (String)opt.getValue()) )
      {
        btns.get(opt.getNum()).setOn(true);
      } else {
        btns.get(opt.getNum()).setOn(false);
      }
    }
  }
}
