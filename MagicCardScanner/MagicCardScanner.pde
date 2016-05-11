/*
Click and drag to select card. Click c to crop.
*/

//Image variables
PImage card, borderCard, noBorder, display, centerPic, textBox, type, setSym, name, cost, damage;
//List of image files
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};
//Ints used for cropping the image
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500); // initial screen size
  surface.setResizable(true); // sets resizable screen
  card = loadImage(cardList[2]); // loads the image
  display = card; // sets initial display image
  surface.setSize(display.width, display.height); // resizes surface
  borderCard = card.copy(); // copies card to the borderless image for initial setup
  cropAll(borderCard); // isolates all of the areas to get each variable using borderCard
}

//Draws out all images and objects
void draw() {
  surface.setSize(display.width, display.height); // set surface size
  image(display, 0, 0); // display image
  stroke(255, 0, 0); // line color to red
  noFill(); // no fill
  if (mousePressed) { // on mouse press
    rect(startx, starty, mouseX-startx, mouseY-starty); // draws crop rectangle
  }
}

//Takes data from the images and returns it
//[CardColor(C),Name(B),Type(B),Description(B),Attack/Defense(B),Cost(A1),Set(A1),Image(A9)]
float[] takeData(){
  float[] result = new float[1];
  result[0] = 0; // get card color
  
  float bName = blackPixelCount(name, false); // count black pixels of name
  result = append(result, bName);
  
  float bType = blackPixelCount(type, false); // count black pixels of type
  result = append(result, bType);
  
  float bDesc = blackPixelCount(textBox, false); // count black pixels of description
  result = append(result, bDesc);
  
  float bAtt = blackPixelCount(damage, false); // count black pixels of attack and defense
  result = append(result, bAtt);
  
  float[] aCost = sampleBoxes(cost, 1, 1); // color samples the cost
  result = concat(result, aCost);
  
  float[] aSet = sampleBoxes(setSym, 1, 1); // color samples the set symbol
  result = concat(result, aSet);
  
  float[] aImage = sampleBoxes(centerPic, 3, 3); // color samples the center image
  result = concat(result, aImage);
  
  return result;
}

//Splits image into sections and calls functions to measure values
float[] sampleBoxes(PImage imgSource, int n, int m){
  int xDiff = imgSource.width / n; // width of each box
  int yDiff = imgSource.height / m; // height of each box
  float[] result = new float[n * m * 6]; // result array 6 = size of returned array from findColorValues
  int loopCount = 0; // loop counter
  for (int x = 0; x < n; x++){ // for each box wide
    for (int y = 0; y < m; y++){ // for each box tall
      float[] currData = findColorValues(imgSource, x * xDiff, y * yDiff, (x+1) * xDiff, (y+1) * yDiff);
      System.arraycopy(currData, 0, result, loopCount * currData.length, currData.length);
      loopCount += 1;
    }
  }
  return result;
}

//Used to find the average and median values
// format of output (so far):
// [0] = avg red
// [1] = avg green
// [2] = avg blue
// [3] = median red
// [4] = median green
// [5] = median blue
float[] findColorValues(PImage img, int startX, int startY, int endX, int endY){
  color currentColor;
  float[] redValues = new float[(endX - startX) * (endY - startY)];
  float[] greenValues = new float[(endX - startX) * (endY - startY)];
  float[] blueValues = new float[(endX - startX) * (endY - startY)];
  float sumRed = 0, sumGreen = 0, sumBlue = 0;
  float medianRed, medianGreen, medianBlue;
  float averageRed, averageGreen, averageBlue;
  
  // loop to calculate average and median
  for(int y = startY; y < endY; y++){
    for(int x = startX; x < endX; x++){
      currentColor = img.get(x, y); // color at x, y
      
      // red
      redValues[(endX-startX)*(y-startY)+(x-startX)] = red(currentColor); // median
      sumRed += red(currentColor); // average
      
      greenValues[(endX-startX)*(y-startY)+(x-startX)] = green(currentColor); // median
      sumGreen += green(currentColor); // average
      
      blueValues[(endX-startX)*(y-startY)+(x-startX)] = blue(currentColor); // median
      sumBlue += blue(currentColor); // average
    }
  }
  
  // sort arrays of color values for median
  redValues = sort(redValues);
  greenValues = sort(greenValues);
  blueValues = sort(blueValues);
  
  // even number of colors median
  if(redValues.length % 2 == 0){
    medianRed = (redValues[int(redValues.length/2)] +  redValues[int(redValues.length/2 - 1)]) / 2;
    medianGreen = (greenValues[int(greenValues.length/2)] +  greenValues[int(greenValues.length/2 - 1)]) / 2;
    medianBlue = (blueValues[int(blueValues.length/2)] +  blueValues[int(blueValues.length/2 - 1)]) / 2;
  }
  // odd number of colors median
  else{
    medianRed = redValues[int(redValues.length/2)];
    medianGreen = greenValues[int(greenValues.length/2)];
    medianBlue = blueValues[int(blueValues.length/2)];
  }
  
  // average colors
  averageRed = sumRed / redValues.length;
  averageGreen = sumGreen / greenValues.length;
  averageBlue = sumBlue / blueValues.length;
  
  float[] result = {averageRed, averageGreen, averageBlue, medianRed, medianGreen, medianBlue};
  
  return result;
}

//Isolates all of the parts of the card
void cropAll(PImage cropSource){
  int wide = cropSource.width; // gets the width of the card
  int tall = cropSource.height; // get the height of the card
  // gets a card without a border
  noBorder = cropCard(cropSource, int(wide*0.05), int(wide*0.05), int(wide*0.95), int(tall-(wide*0.05)));
  // gets the center picture
  centerPic = cropCard(cropSource, int(wide*0.08), int(2*wide*0.085), int(wide-wide*0.08), int(tall/2 + wide*0.075));
  // gets the description text
  textBox = cropCard(cropSource, int(wide*0.072), int(tall*0.626), int(wide*0.92), int(tall*0.91));
  // gets the type of card
  type = cropCard(cropSource, int(wide*0.08),int(tall*0.56),int(wide*0.8),int(tall*0.626));
  // gets the set symbol
  setSym = cropCard(cropSource, int(wide*0.8),int(tall*0.56),int(wide*0.92),int(tall*0.626));
  // gets the card name
  name = cropCard(cropSource, int(wide*0.08),int(tall*0.05),int(wide*0.7),int(tall*0.11));
  // gets the cost of summoning
  cost = cropCard(cropSource, int(wide*0.7),int(tall*0.05),int(wide*0.92),int(tall*0.11));
  // gets the defense and damage
  damage = cropCard(cropSource, int(wide*0.74), int(tall*0.89), int(wide*0.93), int(tall*0.95));
}

//Function used to crop an image
PImage cropCard(PImage src, int sx, int sy, int ex, int ey){
  // the new image
  PImage cropped = new PImage(ex - sx, ey - sy, ARGB);
  // loops through the selected area and copies to new image
  for (int x = sx; x <= ex; x++){
    for (int y = sy; y <= ey; y++){
      cropped.set(x-sx, y-sy, src.get(x,y));
    }
  }
  return cropped;
}


void compareData(float[] data, String cardName){
  // Declare an array of floats to store results of card-to-card comparisons
  //
  // Reads in a 2-D array of strings: ["[cardData]", "cardName"]
  //
  // For every sub-array in the main array:
  //   Converts sub-array[0] representation of array into an array of floats, called otherCard.
  //   Calls compareCards( data, otherCard ), stores the result in the results array.
  //
  // Iterate through the results array, finding the index of the smallest number.
  //
  // the card name at 2-D_StringArray[smallset_number_index, 1] is the closest match.
  
}

float compareCards(float[] card1, float[] card2){
  float result = 0;
  
  // In the body of this function, compare the cards field by field and add the differences to result.
  // Basically, use a for loop to do:
  //   result += abs(card1[x] - card2[x]);
  //
  // Some of the indexes of the card arrays will need to be handled differently, though.
  // More details will come when we know where those fields are, and how their differences should be measured.
  
  return result;
}

//reading info from text file
String[][] readText(){
  String[] data=loadStrings("cards.txt");
  String[][] result = new String[data.length][2];
  
  for(int i = 0; i < data.length; i++){
    result[i] = split(data[i], " ");
  }
  
  return result;
}

float blackPixelCount(PImage img, boolean cutOffMargin)
{
  int pixCount = 0;
  if(cutOffMargin == true)
  {
      img = cropCard(img, int(img.width * 0.02), int(img.height* 0.05), int(img.width* 0.98), int(img.height*0.93));
  }
  float thr = avgPixel(img);
  PImage newImage = img.get();
  newImage.loadPixels();
  
  for (int i = 0; i < newImage.pixels.length; i++) {
    float val = int(red(newImage.pixels[i]));
    if (val > thr) val = 255;
    else val = 0;
    newImage.pixels[i] = color(val, val, val);
    if(val == 0)
    {
     pixCount++; 
    }
  }
  float percentBlack = ((pixCount*1.0) / (img.width * img.height)) * 100;
  return percentBlack;
}

float avgPixel(PImage img)
{
  float total = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    total += red(img.pixels[i]);
  }
  float avg = total/img.pixels.length;
  return avg;
}

//Samples the card and appends the data to cards.txt
void cardSample(){
  // gets the card data
  float[] data = takeData();
  String outArray = "["; // initialize output string
  for (int x = 0; x < data.length; x++){
    outArray += str(data[x]) + ","; // append array data to output string
  }
  outArray = outArray.substring(0, outArray.length() - 1); // removes the last comma
  outArray += "] " + cardList[2]; // adds the card name
  outArray = outArray.substring(0, outArray.length() - 4); // removes the extension
  // opens and reads the current contents of cards.txt
  String lines[] = loadStrings("cards.txt");
  // appends the output string to the current contents
  lines = append(lines, outArray);
  //saves the strings to the file
  saveStrings("data/cards.txt", lines);

}

void mousePressed(){
  // Starts card selection
  startx = mouseX;
  starty = mouseY;
}

void mouseReleased(){
  // Ends card selection
  endx = mouseX;
  endy = mouseY;
}

void keyPressed(){
  // crop the card
  if (key == 'c'){
    borderCard = cropCard(card, startx, starty, endx, endy);
    cropAll(borderCard);
    display = borderCard;
  }
  // samples the card saving the data to a file
  if (key == 's'){
    cardSample();
  }
  // finds the closes match to known cards
  if (key == 'f'){

    

float[] data = takeData();
    readText();
    compareData(data, "data/cards.txt");
  }
  // gets black pixel count by cropping a percentage border around the img passed in, converting the 
  // img to black and white and counting the number of black pixels. This will display the black and white image
  // and set the black pixel count to blackCount. Do NOT press the button more than once on an img or else the img
  // will be cropped smaller
  if (key =='b')
  {
     float blackCount = blackPixelCount(display, false);
     println(blackCount);
  }
  // display the original image
  if (key == '1'){
    display = card;
  }
  // display the cropped card
  if (key == '2'){
    display = borderCard;
  }
  // displays the borderless card
  if (key == '3'){
    display = noBorder;
  }
  // displays the center picture
  if (key == '4'){
    display = centerPic;
  }
  // display the description box
  if (key == '5'){
    display = textBox;
  }
  // display the type of card
  if (key == '6'){
    display = type;
  }
  // display the set symbol
  if (key == '7'){
    display = setSym;
  }
  // display the name of the card
  if (key == '8'){
    display = name;
  }
  // display the cost of the card
  if (key == '9'){
    display = cost;
  }
  // display the defense and attack of the card
  if (key == '0'){
    display = damage;
  }
}