class translater{

//set up image object, audio channel objects(Ess) , sine wave objects(Ess)
  PImage shell;
  AudioChannel myChannel,myChannel2, myChannel3;
  SineWave fibWav, fibWav2, fibWav3;
  
//variables for pitch shifting, and image scaling 
  float pitch1, pitch2, pitch3, scaler,w,h,scaledX,scaledY;

//variables for tempo  
  float m=millis();
  float newMillis=0;

//variables for sliders (must be public)
  public float vol=.5,volRed=1.0,volGreen=1.0,volBlue=1.0, myVol=.5, maxPitch, minR,maxR,minG,maxG,minB, maxB,myTempo=250.0;
  
//integer variables for image placement and Translater class identification
  int i,offsetNo,imageX,imageY,yspace=20;
  boolean on,hold;

//accept input numbers, and establish maxPitch
  translater(int pos, PImage tempImage){
    offsetNo=pos;
    shell=tempImage;
//hold and play are off by default... default pitch range (20hz-20khz)    
    hold=false;
    on=false;
    maxPitch=20000;
  } 

  void start(){
//establish playback channels for Ess
    myChannel=new AudioChannel();
    myChannel2=new AudioChannel();
    myChannel3=new AudioChannel();

    myChannel.initChannel(myChannel.frames(5));
    myChannel2.initChannel(myChannel2.frames(5));
    myChannel3.initChannel(myChannel3.frames(5));

    myChannel.play(Ess.FOREVER);
    myChannel2.play(Ess.FOREVER);
    myChannel3.play(Ess.FOREVER);

//establish the width and height of the image being convertes
    w=shell.width;
    h=shell.height;

//set scaler to use to limit all images to a width of 200 pixels 
//imageX and imageY use offsetNo to determine placement
//currently limited to 2 images spaced by variable yspace across the y-axis
    scaler=(w/200);
    imageX=10+((offsetNo%2)*220);
    imageY=yspace;
    if(offsetNo>1){
      imageY=300;
    }

//store scaled values in scaledX and scaledY, and display the scaled image in position
    scaledX=shell.width/scaler;
    scaledY=shell.height/scaler;
    image(shell,imageX,imageY,scaledX ,scaledY);

// position, format and display volume, pitch, and tempo sliders, also hold and play buttons    
    String slideNameA="volume "+(offsetNo+1);
    String slideNameB="pitch "+(offsetNo+1);
    String slideNameC="tempo "+(offsetNo+1);
    int xPos=imageX;
    int yPos=imageY+int(scaledY);
    int slideWidth=int(scaledX);

//create and display interface objects and assign IDs based on offsetNo dividing IDs by incrementing integers will return ofsetNo    
    imageControl.addSlider(slideNameA,0,100,50,xPos,yPos+20,slideWidth,10).setId(offsetNo);
    imageControl.addBang("play "+(offsetNo+1),xPos,yPos+80,10,10).setId(offsetNo+(images.length*3));
    imageControl.addBang("hold "+(offsetNo+1),xPos+(slideWidth-10),yPos+80,10,10).setId(offsetNo+(images.length*4));
    pitchControl.addSlider(slideNameB,0,100,50,xPos,yPos+40,slideWidth,10).setId(offsetNo+images.length);
    tempoControl.addSlider(slideNameC,0,100,50,xPos,yPos+60,slideWidth,10).setId(offsetNo+(images.length*2));

  //create varables to hold controllers for later formatting
    Slider v=(Slider)imageControl.controller(slideNameA);
    Slider p=(Slider)pitchControl.controller(slideNameB);
    Slider t=(Slider)tempoControl.controller(slideNameC);
    Bang   play=(Bang)imageControl.controller("play "+(offsetNo+1));
    Bang   holder=(Bang)imageControl.controller("hold "+(offsetNo+1));

    imageControl.controller("hold "+(offsetNo+1)).setLabel("hold");
    imageControl.controller("play "+(offsetNo+1)).setLabel("play");

  //use object variables for Label formatting
    controlP5.Label vlabel=v.captionLabel();
    vlabel.style().marginLeft = -150;

    controlP5.Label plabel=p.captionLabel();
    plabel.style().marginLeft = -150;

    controlP5.Label tlabel=t.captionLabel();
    tlabel.style().marginLeft = -150;

    controlP5.Label hlabel=holder.captionLabel();
    hlabel.style().marginLeft = -8;

  //use object variables to format colors of interface objects    
    
    holder.setColorValue(0x000000);
    holder.setColorLabel(0x000000);
    holder.setColorActive(color(200));
    holder.setColorForeground(color(0));
    holder.setColorBackground(color(40));

    play.setColorValue(0x000000);
    play.setColorLabel(0x000000);
    play.setColorActive(color(200));
    play.setColorForeground(color(0));
    play.setColorBackground(color(40));

    v.setColorValue(0xffffff);
    v.setColorLabel(0xffffff);
    v.setColorActive(color(200));
    v.setColorForeground(color(180));
    v.setColorBackground(color(40));

    p.setColorValue(0xffffff);
    p.setColorLabel(0xffffff);
    p.setColorActive(color(90,180,0));
    p.setColorForeground(color(90,90,180));
    p.setColorBackground(color(60,60,180));

    t.setColorValue(0xffffff);
    t.setColorLabel(0xffffff);
    t.setColorActive(color(90,0,200));
    t.setColorForeground(color(90,0,180));
    t.setColorBackground(color(60,0,90));  

  }
  
  

  void convert(){
  
//this function converts the image to sound  
//*****************************************  
  
//establish volume variables for the image as a whole and for each channel from the master control  
    println(offsetNo + "     "+myVol);
    volRed=vol*(volRed*myVol);
    //println("red=   "+volRed);
    volGreen=vol*(volGreen*myVol);
    //println("green=   "+volGreen);
    volBlue=vol*(volBlue*myVol);
    //println("blue=   "+volBlue);

//formulas to isolate scaled areas of the changing pitch spectrum based on the relative 
//positions of each color in the visible spectrum

    minR=20;
    maxR=maxPitch*.22;
    minG=maxPitch*.32;
    maxG=maxPitch*.53;
    minB=maxPitch*.59;
    maxB=maxPitch*.69;

//variables used to calculate time passing for tempo control
    m=millis();
    m=m-newMillis;

//if all pixels have been converted turn of the play button for that image    
    if(i>=shell.pixels.length-1){
      //println("off");
      on=false;
    }
    
//if the play button is on and the appropriate amount of time (determined by tempo
//&& the milli/newMilli comprison) begin the conversion process
//******************************************************************************
    if(on && m>myTempo){  
    
    //load each pixel and use it's color values to determine where within the spectrum
    //of each channel a frequency will be pulled from,convert the current pixel to black
    //and read the next pixels values
      shell.loadPixels();
      shell.pixels[i]=color(0);
      //println(red(shell.pixels[i+1]));
      float pitch1 = ((red(shell.pixels[i+1])/255)*maxR)+minR;
      float pitch2 = ((green(shell.pixels[i+1])/255)*(maxG-minG))+minG;
      float pitch3 = ((blue(shell.pixels[i+1])/255)*(maxB-minB))+minB;
      // println(minG+"    "+maxG+"    "+minB);

    //using the 3 pitch values and 3 volume values calculated above generate 3 
    //simultaneous sine waves in 3 seperate channels using Ess  
      fibWav=new SineWave(pitch1,volRed);
      fibWav.generate(myChannel); 
      fibWav2=new SineWave(pitch2,volGreen);
      fibWav2.generate(myChannel2);
      fibWav3=new SineWave(pitch3,volBlue);
      fibWav3.generate(myChannel3);
      
    //change the image to reflect the new black pixel,then display the image
    //increment i so we can convert the next pixel, and reset the time for tempo
      shell.updatePixels();
      image(shell,imageX,imageY, shell.width/scaler,shell.height/scaler);
      i++;
      newMillis=millis();
    } 
//if the play button is not "on" and the tempo time has not yet passed
//display the image without converting a new pixel
    else{   
      image(shell,imageX,imageY, shell.width/scaler,shell.height/scaler);
      
    //if the "hold button is not pressed generate a sineWave of 0hz until the 
    //time determined by tempo has passed   
      if(!hold){
        fibWav=new SineWave(0,volRed);
        fibWav.generate(myChannel); 
        fibWav2=new SineWave(0,volGreen);
        fibWav2.generate(myChannel2);
        fibWav3=new SineWave(0,volBlue);
        fibWav3.generate(myChannel3);
      }   
    }
  }
}

