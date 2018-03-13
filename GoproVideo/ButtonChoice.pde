public class ButtonChoice implements Button {
  ArrayList<ButtonOnOff> btns;
  public ButtonChoice(ArrayList<ButtonOnOff> buttons) {
    btns = buttons;
    for(ButtonOnOff btn : btns) {
      btn.setBehaviour(true, false);
    }
  }
  
  public ButtonChoice(int x, int y, int w, int h, Tuple<String,Runnable>[] options) {
    btns = new ArrayList<ButtonOnOff>();
    for(int i = 0; i<options.length; i++) {
      Tuple<String, Runnable> opt = options[i];
      ButtonOnOff btn = new ButtonOnOff(x+(w*i), y, w, h, opt.getKey(), opt.getValue());
      btn.setBehaviour(true, false);
      btns.add(btn);
    }
  }
  
  public void draw() {
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
}