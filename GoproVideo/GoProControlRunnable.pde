public class GoProControlRunnable implements Runnable {
  String setting;
  String value;
  public GoProControlRunnable(String setting, String value) {
    this.setting = setting;
    this.value = value;
  }
  
  public void run() {
    try {
      loadJSONObject("http://"+GOPRO_IP+"/gp/gpControl/setting/"+setting+"/"+value);
    } catch(Exception e) {}
    GoProStatus.getInstance(PAPPLET).updateValuesInThread();
  }
}
