import java.util.*;
import processing.core.*; 
import processing.data.*;

public class GoProStatus {
  static String GOPRO_IP = "10.5.5.9";
  private static HashMap<String, GoProStatus> instances = new HashMap<String, GoProStatus>();
  
  PApplet p = null;
  private JSONObject status = null;
  
  public interface StatusEventListener {
    public void valuesUpdated(JSONObject status);
  }
  private ArrayList<StatusEventListener> listeners = new ArrayList<StatusEventListener>();
  
  private GoProStatus(PApplet p) {
    this.p = p;
    updateValuesInThread();
  }
  
  public static GoProStatus getInstance(PApplet p) { return getInstance(p, ""); }
  public static GoProStatus getInstance(PApplet p, String instanceId) {
    if(instances.containsKey(instanceId)) {
      return instances.get(instanceId);
    } else {
      GoProStatus instance = new GoProStatus(p);
      instances.put(instanceId, instance);
      return instance;
    }
  }
  
  private void updateValues() {
    try {
      status = p.loadJSONObject("http://"+GOPRO_IP+"/gp/gpControl/status");
    } catch(Exception e) {}
    triggerEvent();
  }
  
  public void updateValuesInThread() {
    new Thread(new Runnable() {
      public void run() {
        updateValues();
      }
    }).start();
  }
  
  public void register(StatusEventListener listener) {
    listeners.add(listener);
  }
  
  private void triggerEvent() {
    for(StatusEventListener listener : listeners) {
      listener.valuesUpdated(status);
    }
  }
  
  public String getSettingsString(String id) {
    if(status==null)
      return "";
    return status.getJSONObject("settings").getString(id);
  }
  
  public int getSettingsInt(String id) {
    if(status==null)
      return -1;
    return status.getJSONObject("settings").getInt(id);
  }
}
