# CoinCollector

### Description
Collect coin sprites from Super Mario World that randomly spawn on the monitor by controlling the player's movements using the 'w', 'a', 's', 'd' keys on a keyboard. 
Be careful of not colliding with the blue koopa shell, 2 thwomps, and banzai bill that randomly spawn on the monitor, as you lose a life upon collision. You get 3 lives and you must collect enough coins to win; lose all 3 lives and you lose. There is no time limit.

### Motivation for the Project
To learn the basics of Verilog by implementing digital logic systems and controlling them using finite state machines (FSMs). 

### Challenges
1.   Storing Pixel Data of Sprites
     I figured out that Vivado does most of the heavy lifting by offering *Random Memory Generator* as an IP, which can be used as a single-port ROM block to store the        pixels of the sprites *.coe files

## Features:
### top.v
1.  Connects all modules together 

  

###### UARTrx: Takes the ASCII value of the key pressed from the keyboard to be used as user input
###### IP ROM blocks: Store pixel image data of each sprite. The pixel data is stored in a *.coe file
