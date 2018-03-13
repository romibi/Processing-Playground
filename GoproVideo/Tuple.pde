public class Tuple<K, V> {
  private K k;
  private V v;
  
  public Tuple(K _k, V _v) {
    k = _k;
    v = _v;
  }
  
  public K getKey() {
    return k;
  }
  
  public V getValue() {
    return v;
  }
}