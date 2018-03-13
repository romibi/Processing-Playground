public class ButtonTrigger implements Button {
  int x=0;
  int y=0;
  int w=0;
  int h=0;
  String text="";
  int lastTriggered = 0;
  Runnable myFunc = null;
  protected color c = 255;
  
  public ButtonTrigger(int x, int y, int w, int h, String text, Runnable myFunc) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.text=text;
    this.myFunc=myFunc;
  }
  
  void draw() {
    int off = (200+(lastTriggered-frameCount)*10);
    if(off<0) {
      off=0;
    }
    fill(c-off);
    rect(x,y,w,h,7);
    textAlign(CENTER,CENTER);
    fill(0);
    text(text, x+(w/2),y+(h/2));
  }
  
  boolean checkClick(int varx, int vary) {
    if(varx>x && varx<(x+w) &&
       vary>y && vary<(y+h)) {
         if(myFunc!=null) {
           new Thread(myFunc).start();
         }
         lastTriggered = frameCount;
         return true;
    }
    return false;
  }
}