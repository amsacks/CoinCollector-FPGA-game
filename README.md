# CoinCollector

### Description
Collect coin sprites from Super Mario World that randomly spawn on the monitor by controlling the player's movements using the 'w', 'a', 's', 'd' keys on a keyboard. 
Be careful of not colliding with the blue koopa shell, 2 thwomps, and banzai bill that randomly spawn on the monitor, as you lose a life upon collision. You get 3 lives and you must collect enough coins to win; lose all 3 lives and you lose. There is no time limit.

### Motivation for the Project
To learn the basics of Verilog by implementing digital logic systems and controlling them using finite state machines (FSMs). 

### Challenges
1.   **Storing Pixel Data of Sprites**: I figured out that Vivado does most of the heavy lifting by offering **Block Memory Generator** as an IP, which can be used as a memory type *single port ROM*. The settings for the IP are the same for all sprites (Port A Width = 12, Always Enabled), with the only difference being the Port A Depth. Depth = ImageLength * ImageWidth 



## Modules
1.  top.v: Connects all modules together in the system.
2.  UARTrx.v: Recieves the keyboard inputs as ASCII a baud rate of 9600.
3.  UARTtx.v: Transmits the ASCII value of the key pressed to the computer.
4.  Clk_Div.v: Generates a 25 MHz clock from the system clock of 100 MHz.
5.  VGAcore.v: Generates the appropriate vertical and horizontal synch pulses at a resolution 640 x 480 at a Pixel Clock of 25 MHz.
6.  PRNG.v: Pseudo-random number generator (PRNG) to allow the spawn locations of the mobs to be somewhat randomized, in view of the player. The generated coordinates are made sure to be within the bounds of the active video display.
    - LFSR.v: Outputs a 50-bit and 20-bit long PRNG using taps that maximize the cycle length.
    - FIFOv2.v: An asynchronous FIFO that continously writes at the system clock and reads at the pixel clock. The data coming from the buffer corresponds to the randomized x-coordinate of Thwomp #2 on the map.
7.  GameDisplay.v: Generates all sprites using the Block Memory Generator IP; takes the ASCII key as input to change the coordinates of the player; does all proper logic for the spawn time and location of all sprites and collisions between player and mobs/coins.
    - BinToBCD.v: Converts 14-bit binary number into a 20-bit BCD number. This is used so that the player's score can be outputted to the seven-segment displays.
9.  PlayerLifeRGB.v: A FSM is used to generate a PWM pulse to an RGB led to either GREEN (3 lives), YELLOW (2 lives), or RED (1 life). 
10.  nDigitSevenSegDriver.v: A parametrized seven-segment driver that displays the player's score.
  


### References
1.  https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
2.  https://web.mit.edu/6.111/volume2/www/f2019/handouts/labs/lab3_19/rom_vivado.html
3.  https://github.com/gajjanag/6111_Project/blob/master/assets/audio_convert/makecoe.m
