public class ButtonOnOff extends ButtonTrigger {
  boolean on = false;
  boolean triggerSetsOn = false;
  boolean triggerSetsOff = false;
    
  public ButtonOnOff(int x, int y, int w, int h, String text, Runnable myFunc) {
    super(x,y,w,h,text,myFunc);
  }
  
  boolean checkClick(int varx, int vary) {
    boolean wasclicked = super.checkClick(varx,vary);
    if(wasclicked) {
      if(!on && triggerSetsOn) {
        setOn(true);
      } else if(on && triggerSetsOff) {
        setOn(false);
      }
    }
    return wasclicked;
  }
  
  public void setBehaviour(boolean triggerSetsOn, boolean triggerSetsOff) {
    this.triggerSetsOn = triggerSetsOn;
    this.triggerSetsOff = triggerSetsOff;
  }
  
  public void setOn(boolean on) {
    this.on=on;
    if(on) {
      c = color(0,255,0);
    } else {
      c = 255;
    }
  }
}