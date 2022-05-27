# CoinCollector

### Description
Collect coin sprites from Super Mario World that randomly spawn on the monitor by controlling the player's movements using the 'w', 'a', 's', 'd' keys on a keyboard. 
Be careful of not colliding with the blue koopa shell, 2 thwomps, and banzai bill that randomly spawn on the monitor, as you lose a life upon collision. You get 3 lives and you must collect enough coins to win; lose all 3 lives and you lose. There is no time limit.

### Motivation for the Project
To learn the basics of Verilog by implementing digital logic systems and controlling them using finite state machines (FSMs). 

### Challenges
1.   **Storing Pixel Data of Sprites**: I figured out that Vivado does most of the heavy lifting by offering **Block Memory Generator** as an IP, which can be used as a memory type *single port ROM*. The settings for the IP are the same for all sprites (Port A Width = 12, Always Enabled), with the only difference being the Port A Depth. Depth = ImageLength * ImageWidth 



## Modules
1.  top.v: Connects all modules together 
2.  

### References
1.  https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
2.  https://web.mit.edu/6.111/volume2/www/f2019/handouts/labs/lab3_19/rom_vivado.html
