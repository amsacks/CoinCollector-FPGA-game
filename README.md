# CoinCollector

Collect coin sprites from Super Mario World that randomly spawn on the monitor by controlling the player's movements using the 'w', 'a', 's', 'd' keys on a keyboard. 
Be careful of not colliding with the blue koopa shell, 2 thwomps, and banzai bill that randomly spawn on the monitor, as you lose a life upon collision. You get 3 lives and you must collect enough coins to win; lose all 3 lives and you lose. There is no time limit. 

Hardware: Nexys A7: FPGA Trainer Board


###### UARTrx: Takes the ASCII value of the key pressed from the keyboard to be used as user input
###### IP ROM blocks: Store pixel image data of each sprite. The pixel data is stored in a *.coe file
