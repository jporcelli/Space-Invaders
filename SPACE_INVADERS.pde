//*****************************************************************************//SPACE INVADERS//********************************************************************************************\\ 
//by James Porcelli
//Final project, Fall 2011

//******************  PLEASE MAKE SURE YOURE COMPUTERS VOLUME IS TURNED ON FOR MAXIMUM GAME PLAY EXPERIENCE *********************************************************************************\\
//***NOTE: THE GAME MAY TAKE A FEW MOMENTS TO LOAD ONCE THE PLAY BUTTON IS PRESSED, OR UPON RESTARTING THE GAME BY CLICKING THE SCREEN FOR ANY REASON, THIS IS NORMAL, PLEASE BE PATIENT ****\\
//***NOTE: FOR OPTIMAL GAME PLAY, KEEP SHOTS FIRED RATE TO A SINGLE SHOT PER SECOND LIMIT, THANK YOU**//
//***THANKS FOR PLAYING***//


//*******************************************************************************************************************************************************************************************\\


//Variables,Constants,Instances//

import ddf.minim.*;

final int ROWS=6;
final int COLS=6;

final int ROW=10;
final int COL=10;

int newCol;
int newRow;

final int DISPLAY_SIZE=500;
final int BACKGROUND_COLOR=0;

final color SHIP_MISSLE_COLOR=color(350, 0, 0, 250);
final color ALIEN_LASER_COLOR=color(350, 350, 0, 250);
final int MISSLE_SPEED=7;
float alienSpeed=0.5;
int alienReFire=1500;
float alienSpeedFactor=1.08;


boolean youLose=false;


Spaceship ship;
Alien[][]aliens;
Shield[][]shield1;
Shield[][]shield2;
Shield[][]shield3;
ArrayList lasers;
ArrayList missles;
Timer timer;

Minim minim;


int newRows;
int newCols; 




void setup() {
  //display screen size
  size(DISPLAY_SIZE, DISPLAY_SIZE);

  //audio player
  minim=new Minim(this);



  //create instances
  shield1=new Shield[COL][ROW];
  shield2=new Shield[COL][ROW];
  shield3=new Shield[COL][ROW];
  aliens=new Alien[COLS][ROWS];
  lasers=new ArrayList();
  missles=new ArrayList();
  ship=new Spaceship("explosion.mp3");

  //initialize aliens
  for (int i=0; i<COLS; i++) {
    for (int j=0; j<ROWS; j++) {
      aliens[i][j] = new Alien( ( i * DISPLAY_SIZE / 12 ) + ( DISPLAY_SIZE / 6.1 ), ( j * DISPLAY_SIZE / 12.5 ) + ( DISPLAY_SIZE / 20 ), alienSpeed, "explosion.mp3");
    }
  }
  //initialize shields
  for (int i=0;i<COL;i++) {
    for (int j=0;j<ROW;j++) {
      shield1[i][j]=new Shield( ( i * DISPLAY_SIZE / 100 ) + ( DISPLAY_SIZE / 5 ) - DISPLAY_SIZE / 20, ( j * DISPLAY_SIZE / 100 ) + DISPLAY_SIZE - DISPLAY_SIZE / 5, "explosion.mp3");
      shield2[i][j]=new Shield( ( i * DISPLAY_SIZE / 100 ) + ( ( DISPLAY_SIZE / 5 ) + DISPLAY_SIZE / 4 ), ( j * DISPLAY_SIZE / 100 ) + DISPLAY_SIZE - DISPLAY_SIZE / 5, "explosion.mp3");
      shield3[i][j]=new Shield( ( i * DISPLAY_SIZE / 100 ) + ( ( DISPLAY_SIZE / 5 ) + DISPLAY_SIZE / 1.82 ), ( j * DISPLAY_SIZE/100 ) + DISPLAY_SIZE - DISPLAY_SIZE / 5, "explosion.mp3");
    }
  }


  //timer and timer parameter
  timer=new Timer(alienReFire);
  timer.start();

  //load font
  //PFont f=loadFont("Andalus-48.vlw");
}


void draw() {
  //background color
  background(BACKGROUND_COLOR, BACKGROUND_COLOR);

  //call an instance of the spaceship and perform actions
  ship.moveShipLeft();
  ship.moveShipRight();
  ship.display();

  //call instances of shields and remove damage done by missles to those shields
  for (int i=0;i<COL;i++) {
    for (int j=0;j<ROW;j++) {
      shield1[i][j].display();
      shield2[i][j].display();
      shield3[i][j].display();
      shield1[i][j].removeDamage();
      shield2[i][j].removeDamage();
      shield3[i][j].removeDamage();
    }
  }




  //shift all aliens when the outer most alien/aliens reaches the edge of the screen
  for (int i=0;i<COLS;i++) {
    if (((aliens[i][0].alienXpos())>=DISPLAY_SIZE-28) || ((aliens[i][0].alienXpos())<=28) && (aliens[i][0].deadAlien!=true)) {
      for (int k=0; k<COLS; k++) {
        for (int j=0; j<ROWS; j++) {
          aliens[k][j].shiftAliens();

          //if the aliens reach the spaceship you have lost the game
          if (aliens[k][j].alienYpos()>DISPLAY_SIZE-55 && aliens[k][j].deadAlien!=true) {
            youLose();
          }
        }
      }
    }
  }

  //call an instance of an array of alien objects and perform actions on those alien objects
  for (int i=0; i<COLS; i++) {
    for (int j=0; j<ROWS; j++) {
      aliens[i][j].display();
      aliens[i][j].moveAliens();
      aliens[i][j].removeDeadAlien();
    }
  }


  //initialize the missle object to an array list of missle objects and perform actions on that array list of missle objects
  for (int i=0;i<missles.size();i++) {
    Missle m=(Missle)missles.get(i);
    m.fireMissle();
    m.play();
    m.display();



    //if missle is to be terminated remove the missle from the array list
    if (m.terminateMissle()) {
      missles.remove(m);
    }
    for (int k=0; k<COLS; k++) {
      for (int j=0; j<ROWS; j++) {
        //if a missle strikes an alien remove that missle and the alien from the game screen
        if (m.directHit(aliens[k][j])) {
          missles.remove(m);
          aliens[k][j].killed();
          aliens[k][j].play();
          //killed aliens counter
          int aliensMurdered=0;

          for (int l=0; l<COLS; l++) {
            for (int n=0; n<ROWS; n++) {

              //if an alien is killed update the counter
              if (aliens[l][n].deadAlien) {
                aliensMurdered+=1;

                //if there are 8 aliens remaining,increase the speed for the 8th alien and for every alien
                //after that until the last alien has the highest speed of any of the aliens
                if (aliensMurdered>=((COLS*ROWS)-8)) {
                  for (int y=0; y<COLS; y++) {
                    for (int z=0; z<ROWS; z++) {
                      aliens[y][z].setSpeed(alienSpeedFactor);
                    }
                  }
                }
                //if all 36 aliens are killed the game is over and the player wins, click the screen to play again
                if (aliensMurdered>=COLS*ROWS) {
                  text("YOU WIN !!", DISPLAY_SIZE/2-DISPLAY_SIZE/11, DISPLAY_SIZE/2+DISPLAY_SIZE/10);
                  text("CLICK TO PLAY AGAIN AND THE GAME WILL RESTART IN 10 SECONDS", DISPLAY_SIZE/2-DISPLAY_SIZE/2.7, DISPLAY_SIZE/2+DISPLAY_SIZE/6.7  );
                  noLoop();
                  ship.gameOver();
                  m.close();
                }
              }
            }
          }
        }
      }
    }

    for (int p=0;p<COL;p++) {
      for (int q=0;q<ROW;q++) {

        //        if the spaceship fires a missle from behind the shields and that missle strikes the shield the missle
        //        is terminated upon impact with the shield and the damage from the missle to the shield is removed
        //        from the shield, the same way alien lasers damage the shields

        if (m.directHit2(shield1[p][q])) {
          missles.remove(m);
          shield1[p][q].impactShield();
          shield1[p][q].play();
        }
        if (m.directHit2(shield2[p][q])) {
          missles.remove(m);
          shield2[p][q].impactShield();
          shield2[p][q].play();
        }
        if (m.directHit2(shield3[p][q])) {
          missles.remove(m);
          shield3[p][q].impactShield();
          shield3[p][q].play();
        }
      }
    }
  }




  //initialize a new missle object to a new array list for the aliens to fire missles
  //which we call lasers for aliens
  for (int i=0; i < lasers.size(); i++) {

    Missle l=(Missle)lasers.get(i);
    l.fireMissle();
    l.display();
    l.play();


    //determine if the alien missles,lasers, need to be terminated or if they have
    //hit the space ship and remove those lasers from the array list
    if (l.terminateMissle()) {
      lasers.remove(l);
    }
    if (l.directHit3(ship)) {
      lasers.remove(l);
      ship.spaceShipImpact();
      ship.play();
      timer.start();
      l.close();
    }
    for (int k=0;k<COL;k++) {
      for (int n=0;n<ROW;n++) {

        //if the lasers impact the shields remove the damage done by the lasers to the shields 
        //and remove the lasers from the array list
        if (l.directHit2(shield1[k][n])) {
          lasers.remove(l);
          shield1[k][n].impactShield();
          shield1[k][n].play();
        }
        if (l.directHit2(shield2[k][n])) {
          lasers.remove(l);
          shield2[k][n].impactShield();
          shield2[k][n].play();
        }
        if (l.directHit2(shield3[k][n])) {
          lasers.remove(l);
          shield3[k][n].impactShield();
          shield3[k][n].play();
        }
      }
    }
  }

  //if the timer cycles through its set time a new alien missle,laser, will fire
  if (timer.isFinished()) {

    timer.start();
    newShot();
  }

  //if the spaceship is hit by an alien missle,laser, the player loses
  if (ship.getSpaceShipHit()) {
    youLose();
  }
}

//method for insuring alien laser fire is from the outer most non-dead alien in a given column
//and that the column chosen to fire from is chosen at random each cycle through the timer
void newShot() {
  newCol=int(random(0, COLS));


  for (int i= 5; i>=0;--i) {
    if (!aliens[newCol][i].deadAlien) {
      lasers.add(new Missle(aliens[newCol][i].alienXpos(), aliens[newCol][i].alienYpos(), -MISSLE_SPEED, ALIEN_LASER_COLOR, "laser_zap.mp3"));

      return;
    }
  }

  newShot();
}

// method to restart the game, by clicking the screen, for different scenarios in which the game has ended
void mousePressed() {
  if (ship.spaceShipHit==true) {
    setup();
    loop();
  }
  else {
    if (ship.gameOver==true) {
      setup();
      loop();
    }
    else {
      if (youLose=true) {
        setup();
        loop();
      }
    }
  }
}


//if the player has lost this method displays the "you lose" text and stops the game before 
//the option to restart by clicking is given by the previous method
void youLose() {
  text("YOU LOSE!!", DISPLAY_SIZE/2-DISPLAY_SIZE/11, DISPLAY_SIZE/2+DISPLAY_SIZE/10);
  text("CLICK TO TRY AGAIN AND THE GAME WILL RESTART IN 10 SECONDS", DISPLAY_SIZE/2-DISPLAY_SIZE/2.7, DISPLAY_SIZE/2+DISPLAY_SIZE/6.7);
  noLoop();
  youLose=true;
}








//method to add a new missle object to the array list for missles if the space bar is pressed,
//this missle array list is for the space ship to fire missles
void keyPressed() {
  if (key==' ') {
    missles.add(new Missle(ship.shipXpos(), ship.shipYpos(), MISSLE_SPEED, SHIP_MISSLE_COLOR, "laser_zap.mp3"));
  }
}

public void stop() {
  ship.close();


  for (int i=0;i<COLS;i++) {
    for (int j=0;j<ROWS;i++) {
      aliens[i][j].close();
    }
  }

  for (int k=0;k<COL;k++) {
    for (int p=0;p<ROW;p++) {
      shield1[k][p].close();
      shield2[k][p].close();
      shield3[k][p].close();
    }
  }
  super.stop();
}

//SPACESHIP CLASS
class Spaceship {
  final int DISPLAY_SIZE=500;
  final int SHIP_RADIUS=30;
  final float SHIP_SPEED=4;
  float x, y;
  color shipColor;
  boolean spaceShipHit;
  boolean gameOver;
  AudioSnippet explosion;



  Spaceship(String filename) {
    x=DISPLAY_SIZE/2;
    y=DISPLAY_SIZE-25;
    shipColor=color(0, 300, 0, 300);
    spaceShipHit=false;
    gameOver=false;
    explosion=minim.loadSnippet(filename);
  }
  //move left
  void moveShipLeft() {
    if (keyPressed) {
      if (key==CODED) {
        if (keyCode==LEFT) {
          x-=SHIP_SPEED;
        }
      }
    }
  }
  //move right
  void moveShipRight() {
    if (keyPressed) {
      if (key==CODED) {
        if (keyCode==RIGHT) {
          x+=SHIP_SPEED;
        }
      }
    }
  }
  //ship x position getter
  float shipXpos() {
    return x;
  }
  //ship y position getter
  float shipYpos() {
    return y;
  }
  //display spaceship
  void display() {
    ellipseMode(CENTER);
    stroke(0);
    fill(shipColor);
    ellipse(x, y, SHIP_RADIUS*2, SHIP_RADIUS/1.5);
  }
  //has the space ship been hit by alien missle?
  void spaceShipImpact() {
    spaceShipHit=true;
  }


  //play again if you loose
  void playAgain() {
    if (spaceShipHit==true) {
      fill(255);
      text("playAgain ?", DISPLAY_SIZE/2, DISPLAY_SIZE/2);
    }
  }
  //has the spaceship been hit by alien missle getter
  boolean getSpaceShipHit() {
    return spaceShipHit;
  }
  //you lose, game over
  boolean gameOver() {
    gameOver=true;
    return gameOver;
  }

  void play() {
    if (!explosion.isPlaying()) {
      explosion.rewind();
      explosion.play();
    }
  }

  void close() {
    explosion.close();
  }
}

//ALIEN CLASS
class Alien {

  final int ALIEN_COLOR=255;
  final int DISPLAY_SIZE=500;
  float x;
  float y;
  float r;
  float speed;
  boolean deadAlien=false;
  AudioSnippet explosion;


  Alien(float x_, float y_, float speed_, String filename) {
    x=x_;
    y=y_;
    r=28;
    speed=speed_;
    explosion=minim.loadSnippet(filename);
  }
  //display alien
  void display() {
    ellipseMode(CENTER);
    noStroke();
    fill(ALIEN_COLOR);
    ellipse(x, y, r, r);
  }
  //alien x position getter
  float alienXpos() {
    return x;
  }
  //alien y position getter
  float alienYpos() {
    return y;
  }
  //alien killed
  void killed() {
    deadAlien=true;
  }
  //alien killed , remove alien from game
  void removeDeadAlien() {
    if (deadAlien==true) {
      x=-1000;
      speed=0;
    }
  }
  //move the aliens
  void moveAliens() {
    x+=speed;
  }

  //shift the aliens if they reach the edge of the screen
  void shiftAliens() {
    speed*=-1;
    y+=30;
  }
  //alien speed setter
  void setSpeed(float speed_) {
    speed*=speed_;
  }

  void play() {
    if (!explosion.isPlaying()) {
      explosion.rewind();
      explosion.play();
    }
  }

  void close() {
    explosion.close();
  }
}

//MISSLE CLASS
class Missle {
  final float MISSLE_LENGTH=10;
  final float MISSLE_WIDTH=2;
  final float MISSLE_R=7;
  final float DISPLAY_SIZE=500;
  float x, y;
  color missleColor;
  float speed;
  AudioSnippet laser;

  Missle(float x_, float y_, float speed_, color missleColor_) {
    x=x_;
    y=y_;
    speed=speed_;
    missleColor=missleColor_;
  }

  Missle(float x_, float y_, float speed_, color missleColor_, String filename) {
    x=x_;
    y=y_;
    speed=speed_;
    missleColor=missleColor_;
    laser=minim.loadSnippet(filename);
  }

  //display missle
  void display() {
    ellipseMode(CENTER);
    noStroke();
    fill(missleColor);
    ellipse(x, y, MISSLE_R, MISSLE_R );
  }
  //fire the missle,move the missle
  void fireMissle() {
    y-=speed;
  }
  //terminate the missle from the screen
  boolean terminateMissle() {
    if ( y - speed < 25 || y + speed > DISPLAY_SIZE - 25) {
      return true;
    }
    else {
      return false;
    }
  }
  //missle has intersected an alien object
  boolean directHit(Alien a) {
    float distance=dist(x, y, a.x, a.y);
    if (distance < 30) {
      return true;
    }
    else {
      return false;
    }
  }


  //missle has intersected a shield object
  boolean directHit2(Shield s) {
    float distance=dist(x, y, s.x, s.y);

    if (distance < 5) {
      return true;
    }
    else {
      return false;
    }
  }
  //missle has intersected the spaceship
  boolean directHit3(Spaceship ss) {
    float distance2=dist(x, y, ss.x, ss.y);
    if (distance2<30) {
      return true;
    }
    else {
      return false;
    }
  }

  void play() {
    if (!laser.isPlaying()) {
      laser.rewind();
      laser.play();
    }
  }

  void close() {
    laser.close();
  }
}

//SHIELD CLASS
class Shield {
  final float DAMAGE=5;
  final int DISPLAY_SIZE=500;
  final int INDIVIDUAL_SHIELD_SIZE=5;
  float x, y;
  color shieldColor;
  boolean shieldDamage=false;
  AudioSnippet explosion;

  Shield(float x_, float y_, String filename) {
    x=x_;
    y=y_;
    shieldColor=color(0, 300, 0, 300);
    explosion=minim.loadSnippet(filename);
  }
  //display shield
  void display() {
    rectMode(CENTER);
    noStroke();
    fill(shieldColor);
    rect(x, y, INDIVIDUAL_SHIELD_SIZE, INDIVIDUAL_SHIELD_SIZE);
  }

  //missle has hit shield
  void impactShield() {
    shieldDamage=true;
  }
  //remove the damage done to the shield by the missle impact
  void removeDamage() {
    if (shieldDamage==true) {
      x=-1000;
    }
  }

  void play() {
    if (!explosion.isPlaying()) {
      explosion.rewind();
      explosion.play();
    }
  }

  void close() {
    explosion.close();
  }
}

//TIMER CLASS
class Timer {

  int savedTime;//when timer started
  int totalTime;//how long timer should last

  Timer(int totalTime_) {
    totalTime=totalTime_;
  }

  //starting the timer
  void start() {
    savedTime=millis();
  }

  //returns true if time in parameter has passed
  boolean isFinished() {
    //check how much time has passed
    int passedTime=millis()-savedTime;
    if (passedTime>totalTime) {
      return true;
    }
    else {
      return false;
    }
  }
}

