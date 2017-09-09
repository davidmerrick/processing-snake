import java.util.*;

public class Point {
  
  private int x;
  private int y;
  
  public Point(int x, int y){
     this.x = x;
     this.y = y; 
  }
  
  public int getX(){
     return x; 
  }
  
  public int getY(){
     return y; 
  }
  
  @Override
  public boolean equals(Object other){
      if (other == null) return false;
      if (other == this) return true;
      if (!(other instanceof Point))return false;
      Point otherPoint = (Point)other;
      return otherPoint.getX() == this.getX() && otherPoint.getY() == this.getY(); 
  }
}

public enum Direction {
   UP, DOWN, LEFT, RIGHT 
}

public enum GameState {
   PLAYING, GAME_OVER, WIN 
}

public class Snake {
  
  private Deque<Point> pointDeque = new ArrayDeque<Point>();
  private Direction direction;
  
  public Snake(){
     Point startingPoint = new Point(0,0);
     pointDeque.addFirst(startingPoint);
     this.direction = Direction.DOWN;
  }
  
  public void changeDirection(Direction newDirection){
      direction = newDirection;
  }
  
  public void move(){
      Point currentHead = getHead();
      Point newHead = null;
      switch(direction){
         case UP:
           newHead = new Point(currentHead.getX(), currentHead.getY() - 1);
           break;
          case DOWN:
            newHead = new Point(currentHead.getX(), currentHead.getY() + 1);
            break;
          case LEFT:
            newHead = new Point(currentHead.getX() - 1, currentHead.getY());
            break;
          case RIGHT:
            newHead = new Point(currentHead.getX() + 1, currentHead.getY());
            break;
      }
      
      pointDeque.addFirst(newHead);
      pointDeque.removeLast();
  }
  
  public Point getHead(){
     return pointDeque.peekFirst(); 
  }
  
  public void grow(){
      // When the snake grows, just freeze the tail and let the rest of the body grow
      // Do this by pushing a duplicate point to the end of the queue
      Point currentTail = pointDeque.getLast();
      Point newTail = new Point(currentTail.getX(), currentTail.getY());
      pointDeque.addLast(newTail);
  }
  
  public Point getTail(){
     return pointDeque.getLast(); 
  }
  
  public List<Point> getPoints(){
      List<Point> pointList = new ArrayList<Point>();
      Iterator<Point> pointIterator = pointDeque.descendingIterator(); 
      while(pointIterator.hasNext()){
          Point point = pointIterator.next();
          pointList.add(point);
      }
      return pointList;
  }
}

public class Grid {
  
  private int GRID_WIDTH;
  private int GRID_HEIGHT;
  private int BLOCK_SIDE_LENGTH;

  public Grid(int width, int height, int block_side_length){
      GRID_WIDTH = width;
      GRID_HEIGHT = height;
      BLOCK_SIDE_LENGTH = block_side_length;
  }

  public int getXSize(){
      return GRID_WIDTH * BLOCK_SIDE_LENGTH;
  }
  
  public int getYSize(){
      return GRID_HEIGHT * BLOCK_SIDE_LENGTH;
  }
  
  public void draw(){
      // Horizontal lines
      for(int i = 0; i < GRID_WIDTH; i++){
          line(0, i * BLOCK_SIDE_LENGTH, GRID_WIDTH * BLOCK_SIDE_LENGTH, i * BLOCK_SIDE_LENGTH); 
      }
      
      // Vertical lines
      for(int i = 0; i < GRID_HEIGHT; i++){
          line(i * BLOCK_SIDE_LENGTH, 0, i * BLOCK_SIDE_LENGTH, GRID_HEIGHT * BLOCK_SIDE_LENGTH); 
      }
  }
  
  public void drawPoint(Point point){
      if(!isValidPoint(point)){
         throw new RuntimeException("Invalid point"); 
      }
      
      fill(0, 0, 0);
      int x = point.getX() * BLOCK_SIDE_LENGTH;
      int y = point.getY() * BLOCK_SIDE_LENGTH; 
      rect(x, y, BLOCK_SIDE_LENGTH, BLOCK_SIDE_LENGTH);
  }
  
  public boolean isValidPoint(Point point){
      int x = point.getX();
      int y = point.getY(); 
       
      return x >= 0 && x <= GRID_WIDTH && y >=0 && y <= GRID_HEIGHT; 
  }
  
  public Point getRandomPoint(List<Point> invalidPoints){
      Point point = null;
      while(point == null){
          int randomX = (int) random(0, GRID_WIDTH);
          int randomY = (int) random(0, GRID_HEIGHT);
          Point testPoint = new Point(randomX, randomY);
          if(!invalidPoints.contains(testPoint)){
             point = testPoint; 
          }
      }
      
      return point;
  }
}

final int GRID_WIDTH = 30;
final int GRID_HEIGHT = 30;
final int BLOCK_SIDE_LENGTH = 20;
Grid grid = new Grid(GRID_WIDTH, GRID_HEIGHT, BLOCK_SIDE_LENGTH);
Snake snake = new Snake();
Point foodPoint = new Point(GRID_WIDTH/2, GRID_HEIGHT/2);
final int GAME_SPEED = 5;
GameState gameState = GameState.PLAYING;

void setup(){
  size(600, 600);
}

void playGame(){
  Point snakeHead = snake.getHead();
   if(snakeHead.equals(foodPoint)){
       snake.grow();
       foodPoint = grid.getRandomPoint(snake.getPoints());
   }
   
   background(255);
   grid.draw();
   grid.drawPoint(foodPoint);
  
   List<Point> pointList = snake.getPoints();
   for(Point point : pointList){
     grid.drawPoint(point);
   };
   
   delay(500/GAME_SPEED);
   snake.move();
}

void draw(){
  switch(gameState){
     case PLAYING:
       // Todo: check if snake has eaten itself
      if(!grid.isValidPoint(snake.getHead())){
          gameState = GameState.GAME_OVER;
          break;
       }   
       playGame();
       break;
    case GAME_OVER:
      int middleX = grid.getXSize() / 2;
      int middleY = grid.getYSize() / 2;
      background(255);
      
      PFont f;
      f = createFont("Arial", 16, true);
      textFont(f, 36);
      textAlign(CENTER);
      text("GAME OVER", middleX, middleY);
      break;
  }
}

void keyPressed(){
    switch(keyCode){
       case UP: 
         snake.changeDirection(Direction.UP);
         break;
       case DOWN: 
         snake.changeDirection(Direction.DOWN);
         break;
       case LEFT: 
         snake.changeDirection(Direction.LEFT);
         break;
       case RIGHT: 
         snake.changeDirection(Direction.RIGHT);
         break;
    }
}