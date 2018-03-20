import hypermedia.net.*;
import org.bytedeco.javacv.*;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.awt.image.BufferedImage;

static int GOPRO_PORT = 8554;
static String GOPRO_IP = "10.5.5.9";
static int LISTEN_PORT = 8554;
static String LISTEN_IP = "0.0.0.0";

static String KEEP_ALIVE_MESSAGE = "_GPHD_:0:0:2:0.000000\n";
static boolean useFFPlay = false;
static boolean mayListen = true;
static boolean listen = false;

static PApplet PAPPLET;

UDP udp;
int lastKeepAlive = 0;
byte[] lastData;
ArrayList<Button> buttons = new ArrayList<Button>();
ArrayList<Button> optionButtons = new ArrayList<Button>();

PipedInputStream videoStream;
PipedOutputStream videoBucket;

FFmpegFrameGrabber frameGrabber;
Java2DFrameConverter converter = new Java2DFrameConverter();

boolean videoStarted = false;
boolean showOptionButtons = false;

void setup(){
  PAPPLET = this;
  
  videoStream = new PipedInputStream();
  videoBucket = new PipedOutputStream();
  
  try {
    videoStream.connect(videoBucket);
  } catch (IOException e) {
    println(e);
  }
  
  frameRate(30);
  size(680,400);
  if(mayListen) {
    udp = new UDP(this, LISTEN_PORT, LISTEN_IP);
    if(listen) {
      udp.listen(true);
    }
  } else {
    udp = new UDP(this);
  }
  //udp.log(true);
  startStreamOnGopro();
  if(useFFPlay) {
    startStreamReceiver();
  }
  
  frameGrabber = new FFmpegFrameGrabber(videoStream);
  
  setupButtons();
}

void draw() {
  background(0);
  drawVideo();
  if(showOptionButtons) {
    for (Button btn : optionButtons) {
      btn.draw();
    }
  }
  for (Button btn : buttons) {
    btn.draw();
  }
  int currentTime = millis();
  if(currentTime - lastKeepAlive > 10000) {
    thread("sendKeepAlive");
    lastKeepAlive = currentTime;
    GoProStatus.getInstance(this).updateValuesInThread();
  }
}

public void drawVideo() {
  Frame frame=null;
  if(videoStarted) {
    try {
      frame = frameGrabber.grabImage().clone();
      frameGrabber.flush();
    } catch (FrameGrabber.Exception e) {
      println(e);
    }

    if(frame!=null) {
      BufferedImage bim = converter.convert(frame);
      PImage img = getAsImage(bim);
      image(img,0,0);
    }
  }
}

void mouseClicked() {
  if(showOptionButtons) {
    for(Button btn : optionButtons) {
      btn.checkClick(mouseX, mouseY);
    }
  }
  for(Button btn : buttons) {
    btn.checkClick(mouseX, mouseY);
  }
}

void setupButtons() {
  SettingsOptions<Integer>[] bitrateOptions = new SettingsOptions[10];
  bitrateOptions[0] = new SettingsOptions(0, "62",  250000, "250k");
  bitrateOptions[1] = new SettingsOptions(1, "62",  400000, "400k");
  bitrateOptions[2] = new SettingsOptions(2, "62",  600000, "600k");
  bitrateOptions[3] = new SettingsOptions(3, "62",  700000, "700k");
  bitrateOptions[4] = new SettingsOptions(4, "62",  800000, "800k");
  bitrateOptions[5] = new SettingsOptions(5, "62", 1000000, "1M");
  bitrateOptions[6] = new SettingsOptions(6, "62", 1200000, "1.2M");
  bitrateOptions[7] = new SettingsOptions(7, "62", 1600000, "1.6M");
  bitrateOptions[8] = new SettingsOptions(8, "62", 2000000, "2M");
  bitrateOptions[9] = new SettingsOptions(9, "62", 2400000, "2.4M");
  ButtonChoice bitrateBtns = new ButtonChoice<Integer>("Bitrate", 5, 5, 60, 30, bitrateOptions, Integer.class);
  optionButtons.add(bitrateBtns);
  
  SettingsOptions<Integer>[] screenSizeOptions = new SettingsOptions[10];
  screenSizeOptions[0] = new SettingsOptions(0, "64", 0, "Default");
  screenSizeOptions[1] = new SettingsOptions(1, "64", 1, "240p");
  screenSizeOptions[2] = new SettingsOptions(2, "64", 2, "240p 3:4");
  screenSizeOptions[3] = new SettingsOptions(3, "64", 3, "240p 1:2");
  screenSizeOptions[4] = new SettingsOptions(4, "64", 4, "480p");
  screenSizeOptions[5] = new SettingsOptions(5, "64", 5, "480p 3:4");
  screenSizeOptions[6] = new SettingsOptions(6, "64", 6, "480p 1:2");
  screenSizeOptions[7] = new SettingsOptions(7, "64", 7, "720p");
  screenSizeOptions[8] = new SettingsOptions(8, "64", 8, "720p 3:4");
  screenSizeOptions[9] = new SettingsOptions(9, "64", 9, "720p 1:2");
  ButtonChoice screenSizeBtns = new ButtonChoice<Integer>("Resolution", 5, 40, 60, 30, screenSizeOptions, Integer.class);
  optionButtons.add(screenSizeBtns);
  
  SettingsOptions<Integer>[] videoOption = new SettingsOptions[2];
  videoOption[0] = new SettingsOptions(0, "10", 0, "Off");
  videoOption[1] = new SettingsOptions(1, "10", 1, "On");
  ButtonChoice videoOptionBtns = new ButtonChoice<Integer>("Video", 5, 80, 60, 30, videoOption, Integer.class);
  optionButtons.add(videoOptionBtns);
  
  SettingsOptions<Integer>[] photoOption = new SettingsOptions[2];
  photoOption[0] = new SettingsOptions(0, "21", 0, "Off");
  photoOption[1] = new SettingsOptions(1, "21", 1, "On");
  ButtonChoice photoOptionBtns = new ButtonChoice<Integer>("Photo", 190, 80, 60, 30, photoOption, Integer.class);
  optionButtons.add(photoOptionBtns);
  
  SettingsOptions<Integer>[] multiShotOption = new SettingsOptions[2];
  multiShotOption[0] = new SettingsOptions(0, "34", 0, "Off");
  multiShotOption[1] = new SettingsOptions(1, "34", 1, "On");
  ButtonChoice multiShotOptionBtns = new ButtonChoice<Integer>("MultiShot", 375, 80, 60, 30, multiShotOption, Integer.class);
  optionButtons.add(multiShotOptionBtns);
  
  SettingsOptions<Integer>[] whiteBalanceVideoOptions = new SettingsOptions[8];
  whiteBalanceVideoOptions[0] = new SettingsOptions(0, "11", 0, "Auto");
  whiteBalanceVideoOptions[1] = new SettingsOptions(1, "11", 1, "3000k");
  whiteBalanceVideoOptions[2] = new SettingsOptions(2, "11", 5, "4000k");
  whiteBalanceVideoOptions[3] = new SettingsOptions(3, "11", 6, "4800k");
  whiteBalanceVideoOptions[4] = new SettingsOptions(4, "11", 2, "5500k");
  whiteBalanceVideoOptions[5] = new SettingsOptions(5, "11", 7, "6000k");
  whiteBalanceVideoOptions[6] = new SettingsOptions(6, "11", 3, "6500k");
  whiteBalanceVideoOptions[7] = new SettingsOptions(7, "11", 4, "Native");
  ButtonChoice whiteBalanceVideoOptionBtns = new ButtonChoice<Integer>("WBal (Vid)", 5, 120, 60, 30, whiteBalanceVideoOptions, Integer.class);
  optionButtons.add(whiteBalanceVideoOptionBtns);
  
  SettingsOptions<Integer>[] whiteBalancePhotoOptions = new SettingsOptions[8];
  whiteBalancePhotoOptions[0] = new SettingsOptions(0, "22", 0, "Auto");
  whiteBalancePhotoOptions[1] = new SettingsOptions(1, "22", 1, "3000k");
  whiteBalancePhotoOptions[2] = new SettingsOptions(2, "22", 5, "4000k");
  whiteBalancePhotoOptions[3] = new SettingsOptions(3, "22", 6, "4800k");
  whiteBalancePhotoOptions[4] = new SettingsOptions(4, "22", 2, "5500k");
  whiteBalancePhotoOptions[5] = new SettingsOptions(5, "22", 7, "6000k");
  whiteBalancePhotoOptions[6] = new SettingsOptions(6, "22", 3, "6500k");
  whiteBalancePhotoOptions[7] = new SettingsOptions(7, "22", 4, "Native");
  ButtonChoice whiteBalancePhotoOptionBtns = new ButtonChoice<Integer>("WBal (Photo)", 5, 155, 60, 30, whiteBalancePhotoOptions, Integer.class);
  optionButtons.add(whiteBalancePhotoOptionBtns);
  
  SettingsOptions<Integer>[] whiteBalanceMultiOptions = new SettingsOptions[8];
  whiteBalanceMultiOptions[0] = new SettingsOptions(0, "35", 0, "Auto");
  whiteBalanceMultiOptions[1] = new SettingsOptions(1, "35", 1, "3000k");
  whiteBalanceMultiOptions[2] = new SettingsOptions(2, "35", 5, "4000k");
  whiteBalanceMultiOptions[3] = new SettingsOptions(3, "35", 6, "4800k");
  whiteBalanceMultiOptions[4] = new SettingsOptions(4, "35", 2, "5500k");
  whiteBalanceMultiOptions[5] = new SettingsOptions(5, "35", 7, "6000k");
  whiteBalanceMultiOptions[6] = new SettingsOptions(6, "35", 3, "6500k");
  whiteBalanceMultiOptions[7] = new SettingsOptions(7, "35", 4, "Native");
  ButtonChoice whiteBalanceMultiOptionBtns = new ButtonChoice<Integer>("WBal (Vid)", 5, 190, 60, 30, whiteBalanceMultiOptions, Integer.class);
  optionButtons.add(whiteBalanceMultiOptionBtns);
  
  SettingsOptions<Integer>[] videoColorOption = new SettingsOptions[2];
  videoColorOption[0] = new SettingsOptions(0, "12", 0, "GOPRO");
  videoColorOption[1] = new SettingsOptions(1, "12", 1, "Flat");
  ButtonChoice videoColorOptionBtns = new ButtonChoice<Integer>("Color(V)", 5, 230, 60, 30, videoColorOption, Integer.class);
  optionButtons.add(videoColorOptionBtns);
  
  SettingsOptions<Integer>[] photoColorOption = new SettingsOptions[2];
  photoColorOption[0] = new SettingsOptions(0, "23", 0, "GOPRO");
  photoColorOption[1] = new SettingsOptions(1, "23", 1, "Flat");
  ButtonChoice photoColorOptionBtns = new ButtonChoice<Integer>("Color(P)", 190, 230, 60, 30, photoColorOption, Integer.class);
  optionButtons.add(photoColorOptionBtns);
  
  SettingsOptions<Integer>[] multiShotColorOption = new SettingsOptions[2];
  multiShotColorOption[0] = new SettingsOptions(0, "36", 0, "GOPRO");
  multiShotColorOption[1] = new SettingsOptions(1, "36", 1, "Flat");
  ButtonChoice multiShotColorOptionBtns = new ButtonChoice<Integer>("Color(M)", 375, 230, 60, 30, multiShotColorOption, Integer.class);
  optionButtons.add(multiShotColorOptionBtns);
  
  ButtonTrigger launchffplay = new ButtonTrigger(5, height-40, 80, 30, "Start ffplay", new Runnable() {
    public void run() {
      launchFfplay();
    }
  });
  buttons.add(launchffplay);
  
  ButtonTrigger startFrameGrabber = new ButtonTrigger(90, height-40, 80, 30, "Start Video", new Runnable() {
    public void run() {
      udp.listen(true);
      println("Start FrameGrabber");
      try {
        frameGrabber.start();
      } catch (FrameGrabber.Exception e) {
        println(e);
      }
      println("Started FrameGrabber");
      videoStarted = true;
    }
  });
  buttons.add(startFrameGrabber);
  
  
  ButtonTrigger showHideButtons = new ButtonTrigger(175, height-40, 80, 30, "Show/Hide Options", new Runnable() {
    public void run() {
      showOptionButtons = !showOptionButtons;
    }
  });
  buttons.add(showHideButtons);
}

void receive(byte[] data){
  lastData = data;
  if(true || videoStarted) {
    try {
      videoBucket.write(data);
    } catch (IOException e) {
      println(e);
    }
  }
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
  println("starting ffplay");
  Process pobj = launch(dataPath("ffplay.exe") +" -fflags nobuffer -f:v mpegts -probesize 8192 udp://10.5.5.9:8554");
  InputStream istream = pobj.getInputStream();
  InputStream estream = pobj.getErrorStream();
  try {
    istream.close();
    estream.close();
  } catch (IOException e) {
    println(e);
  }
}

void sendKeepAlive() {
    println("KEEPALIVE!");
    udp.send(KEEP_ALIVE_MESSAGE, GOPRO_IP, GOPRO_PORT);
}

public PImage getAsImage(BufferedImage bimg) {
  try {
    PImage img = new PImage(bimg.getWidth(),bimg.getHeight(),PConstants.ARGB);
    bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();
    return img;
  }
  catch(Exception e) {
    System.err.println("Can't create image from buffer");
    e.printStackTrace();
  }
  return null;
}
