import krister.Ess.*;
import controlP5.*;


translater[] myTranslaters;

ControlP5 volumeControl;
ControlP5 imageControl;
ControlP5 pitchControl;
ControlP5 tempoControl;

//various volumes

public float main=50.0,reds=100.0,blues=100.0,greens=100.0;


//markers to identify sliders by ID no.

public boolean pitch,tempo;


int num;
//  sets up database of images [maxImages] is the number of images to be imported
int maxImages = 4;
PImage[] images=new PImage[maxImages];



void setup(){
  //start Ess
  Ess.start(this);

  //format screen size
  size(800,600);

  //initialize variables  
  num=4;
  pitch=false;
  tempo=false;

  //format controllers - 
  //seperate classes for each type of controller for formatting purposes
  volumeControl = new ControlP5(this);
  imageControl = new ControlP5(this);
  pitchControl = new ControlP5(this);
  tempoControl = new ControlP5(this);

  //basic formatting of sliders for main volume and each color channel
  volumeControl.addSlider("main",0,100,50,width-50,20,10,200);
  volumeControl.addSlider("blues",0,100,100,width-90,20,10,200);
  volumeControl.addSlider("greens",0,100,100,width-130,20,10,200);
  volumeControl.addSlider("reds",0,100,100,width-170,20,10,200);

  //make object variables for each slider for formatting purposes
  Slider s1=(Slider)volumeControl.controller("main");
  Slider s2=(Slider)volumeControl.controller("blues");  
  Slider s3=(Slider)volumeControl.controller("greens");
  Slider s4=(Slider)volumeControl.controller("reds");

  //set colors for each slider
  s1.setColorValue(0x000000);
  s1.setColorLabel(0x000000);
  s1.setColorActive(color(200));
  s1.setColorForeground(color(180));
  s1.setColorBackground(color(40));

  s2.setColorValue(0x000000);
  s2.setColorLabel(0x000000);
  s2.setColorActive(color(0,90,200));
  s2.setColorForeground(color(0,90,180));
  s2.setColorBackground(color(0,40,90));

  s3.setColorValue(0x000000);
  s3.setColorLabel(0x000000);
  s3.setColorActive(color(90,200,0));
  s3.setColorForeground(color(90,180,0));
  s3.setColorBackground(color(40,90,0));

  s4.setColorValue(0x000000);
  s4.setColorLabel(0x000000);
  s4.setColorActive(color(200,0,90));
  s4.setColorForeground(color(180,0,90));
  s4.setColorBackground(color(90,0,40));

  //begin translating images using Translater class
  myTranslaters=new translater[maxImages];

  //establish a new Translater object for each image  
  for(int i=0;i<images.length;i++){
    images[i]=loadImage((i+1)+".jpg");
    myTranslaters[i]=new translater(i,images[i]);
    myTranslaters[i].start();
  }
}




void draw(){
  background(255);

  //trigger Translater objects every frame
  for(int i=0; i<myTranslaters.length;i++){
    myTranslaters[i].vol=main/100;
    myTranslaters[i].volRed=reds/100;
    myTranslaters[i].volGreen=greens/100;
    myTranslaters[i].volBlue=blues/100;  
    myTranslaters[i].convert();
  } 
}


//clean up Ess

public void stop() {
  Ess.stop();
  super.stop();
}


//trigger events using P5 controller IDs

void controlEvent(ControlEvent theEvent) {
  /* events triggered by controllers are automatically forwarded to 
   the controlEvent method. by checking the id of a controller one can distinguish
   which of the controllers has been changed.
   */
  // println("got a control event from controller with id "+theEvent.controller().id());


  //set i to be the controller ID: IDs are assigned based on the Translater.offsetNo
  //volume controllers are numbered as offsetNo, pitch controllers are
  //numbered as offsetNo *2, temp-offsetNo*3, play buttons=offsetNo*4, hold buttons
  //offsetNo*5


  int i=theEvent.controller().id();


  //set markers for controllers based on their ID and adjust i to equal the offsetNo
  //for the Translater object.

  if(i>=maxImages && i<(maxImages*2)){
    i=i-images.length;
    pitch=true;
  } 
  else if(i>=(maxImages*2) && i<(maxImages*3)){
    i=i-(maxImages*2);
    tempo=true;
  }
  else if(i>=(maxImages*3) && i<(maxImages*4)){
    i=i-(maxImages*3);

    //if play button is already "on" set it to be off
    myTranslaters[i].on=!myTranslaters[i].on;

    //change labels for the play button each time it is pressed
    if(myTranslaters[i].on){
      theEvent.controller().setLabel("on");
      theEvent.controller().setColorForeground(color(0,200,0));
    }
    else{
      theEvent.controller().setLabel("play");
      theEvent.controller().setColorForeground(color(0));    
    }
  }
  else if(i>=(maxImages*4)){
    i=i-(maxImages*4);

    //if hold button is already "on" set it to be off    
    myTranslaters[i].hold=!myTranslaters[i].hold;

    //change labels for the hold button each time it is pressed    
    if(myTranslaters[i].hold){
      theEvent.controller().setLabel("h-on");
      theEvent.controller().setColorForeground(color(200,0,0));
    }
    else{
      theEvent.controller().setLabel("hold");
      theEvent.controller().setColorForeground(color(0));
    }
  }
  else{
  //if i<maxImages from the start then the ID is for a volume controller which matches the offsetNo  
    println("volume"+i);
    myTranslaters[i].myVol=(theEvent.controller().value()/100);
    println(myTranslaters[i].myVol);
  }

  if(i>=0){
    if(pitch){
      println(myTranslaters[i].offsetNo);
      myTranslaters[i].maxPitch=((theEvent.controller().value())/100)*20000;
      pitch=false;
    }
    else if(tempo){
      println("tempo"+i);
      myTranslaters[i].myTempo=(theEvent.controller().value());
      println(myTranslaters[i].myTempo);
      tempo=false;
    }
  }
}

