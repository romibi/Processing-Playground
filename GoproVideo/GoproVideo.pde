import hypermedia.net.*;

int GOPRO_PORT = 8554;
String GOPRO_IP = "10.5.5.9";
int LISTEN_PORT = 8554;
String LISTEN_IP = "0.0.0.0";

String KEEP_ALIVE_MESSAGE = "_GPHD_:0:0:2:0.000000\n";
boolean useFFPlay = true;
boolean listen = false;

UDP udp;
int lastKeepAlive = 0;
byte[] lastData;
ArrayList<Button> buttons = new ArrayList<Button>();

void setup(){
  frameRate(30);
  size(620,400);
  if(listen) {
    udp = new UDP(this, LISTEN_PORT, LISTEN_IP);
    udp.listen(true);
  } else {
    udp = new UDP(this);
  }
  udp.log(true);
  startStreamOnGopro();
  if(useFFPlay) {
    startStreamReceiver();
  }
  
  setupButtons();
}

void draw() {
  background(0);
  for (Button btn : buttons) {
    btn.draw();
  }
  int currentTime = millis();
  if(currentTime - lastKeepAlive > 10000) {
    thread("sendKeepAlive");
    lastKeepAlive = currentTime;
  }
}

void mouseClicked() {
  for(Button btn : buttons) {
    btn.checkClick(mouseX, mouseY);
  }
}

void setupButtons() {
  Tuple<String, Runnable>[] bitrateOptions = new Tuple[10];
  bitrateOptions[0] = new Tuple("250k", new GoProControlRunnable("62",  "250000"));
  bitrateOptions[1] = new Tuple("400k", new GoProControlRunnable("62",  "400000"));
  bitrateOptions[2] = new Tuple("600k", new GoProControlRunnable("62",  "600000"));
  bitrateOptions[3] = new Tuple("700k", new GoProControlRunnable("62",  "700000"));
  bitrateOptions[4] = new Tuple("800k", new GoProControlRunnable("62",  "800000"));
  bitrateOptions[5] = new Tuple("1M",   new GoProControlRunnable("62", "1000000"));
  bitrateOptions[6] = new Tuple("1.2M", new GoProControlRunnable("62", "1200000"));
  bitrateOptions[7] = new Tuple("1.6M", new GoProControlRunnable("62", "1600000"));
  bitrateOptions[8] = new Tuple("2M",   new GoProControlRunnable("62", "2000000"));
  bitrateOptions[9] = new Tuple("2.4M", new GoProControlRunnable("62", "2400000"));
  ButtonChoice bitrateBtns = new ButtonChoice(5, 5, 60, 30, bitrateOptions);
  buttons.add(bitrateBtns);
  
  Tuple<String, Runnable>[] screenSizeOptions = new Tuple[10];
  screenSizeOptions[0] = new Tuple("Default", new GoProControlRunnable("64", "0"));
  screenSizeOptions[1] = new Tuple("240p", new GoProControlRunnable("64", "1"));
  screenSizeOptions[2] = new Tuple("240p 3:4", new GoProControlRunnable("64", "2"));
  screenSizeOptions[3] = new Tuple("240p 1:2", new GoProControlRunnable("64", "3"));
  screenSizeOptions[4] = new Tuple("480p", new GoProControlRunnable("64", "4"));
  screenSizeOptions[5] = new Tuple("480p 3:4", new GoProControlRunnable("64", "5"));
  screenSizeOptions[6] = new Tuple("480p 1:2", new GoProControlRunnable("64", "6"));
  screenSizeOptions[7] = new Tuple("720p", new GoProControlRunnable("64", "7"));
  screenSizeOptions[8] = new Tuple("720p 3:4", new GoProControlRunnable("64", "8"));
  screenSizeOptions[9] = new Tuple("720p 1:2", new GoProControlRunnable("64", "9"));
  ButtonChoice screenSizeBtns = new ButtonChoice(5, 40, 60, 30, screenSizeOptions);
  buttons.add(screenSizeBtns);
}

void receive(byte[] data){
  if(lastData==null){
    println(data);
  }
  lastData = data;
  println("received something");
}

boolean startStreamOnGopro() {
  JSONObject json=null;
  try {
    json = loadJSONObject("http://"+GOPRO_IP+"/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart");
  } catch(Exception e) {}
  if(json==null)
    return false;
  println("status: "+json.getInt("status"));
  return json.getInt("status")==0;
}

void startStreamReceiver() {
  thread("launchFfplay");
}

void launchFfplay() {
  Process pobj = launch(dataPath("ffplay.exe") +" -fflags nobuffer -f:v mpegts -probesize 8192 udp://10.5.5.9:8554");
  InputStream istream = pobj.getInputStream();
  InputStream estream = pobj.getErrorStream();
  try {
    istream.close();
    estream.close();
  } catch (IOException e) {
  }
}

void sendKeepAlive() {
    println("KEEPALIVE!");
    udp.send(KEEP_ALIVE_MESSAGE, GOPRO_IP, GOPRO_PORT);
}