public class SettingsOptions<T> {
  private int n;
  private String settingsKey;
  private T settingsValue;
  private String label;
  
  public SettingsOptions(int n, String k, T v, String l) {
    this.n = n;
    this.settingsKey = k;
    this.settingsValue = v;
    this.label = l;
  }
  
  public int getNum() {
    return n;
  }
  
  public String getKey() {
    return settingsKey;
  }
  
  public T getValue() {
    return settingsValue;
  }
  
  public String getLabel() {
    return label;
  }
  
  public Runnable getTrigger() {
    return new GoProControlRunnable(settingsKey,  settingsValue.toString());
  }
}
