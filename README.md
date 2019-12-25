# idealgaslawsimulator
Both of us are physics enthusiasts, and we decided to use this project as an opportunity to see if we can use hardware to help us visualize some of the concepts we learned in high school. We tried to aim for a project with many dynamic parts, while simplifying the initial stages of the project so that we can add complexity by gradually building on something that is already functional. 

We wanted to replicate the ideal gas law simulators that we saw in high school with Verilog. Since the purpose of these simulators are to provide students with a better intuition of the ideal gas law, we wanted to be able to show the different relationships between each variable with appropriate visual aid. To demonstrate the different relationships, we wanted to be able to test the relation between one independent and dependent variable, while keeping other variables constant. Furthermore, since there are many ideal gas law simulators available online, we had a way to benchmark our design against existing ones.


## “Main” Module:
### The “main” FSM control path:
The control path for the “main” FSM consists of the following states:
* Reset_Pos: This is the reset state where everything on the screen is reset.
* DrawWait: Everything including the particles, the piston, the pressure meter, and the PV=NRT equation are drawn in this state.
* RateDividerWait: In this state, we make the screen stay static for a certain amount of time; this controls how fast/slow we see things updating and moving on the screen.
* EraseWait: This state makes sure we wait long enough for everything to be erased before updating the screen so that we don’t draw new items on top of existing items
* UpdateShiftReg: This state updates the contents of the direction registers to be described in the data path below.
* UpdatePos: This state updates the positions of the particles

### The “main” datapath FSM:
The important components of the datapath for the main FSM are summarized below:
1. The drawWaitCounter, rateDividerCounter, and eraseWaitCounter. These counters make the circuit wait (i.e. not do any action) until everything has been drawn on the screen,  until the screen has waited long enough before updating, and until everything has been erased before updating, respectively.
1. Each particle has one of the following:
    1. An x-Counter that updates the x-position of the particle
    1. A y-Counter that updates the y-position of the particle
    1. A T flip flop holding the horizontal direction of motion (1 for right, 0 for left)
    1.A T flip flop holding the vertical direction of motion (1 for down, 0 for up)
1. 10 checkCollision module instantiations that check for the 10 possible collisions that could happen in a system of 5 colliding particles. These instantiations consist of purely combinational logic that checks if the centers of two particles are at a certain distance away from each other.
1. BorderCounter, which updates the position of the border defined by the piston
1. Meter counter, which is used for controlling the position of the pressure meter
1. An instantiation of the module that controls the input to the VGA Adapter in order to draw each individual pixel

### Elaboration on the border counter module:
The border counter module is actively used when the simulation is on one of modes 0, 2, and 3 (i.e. manual, moles to volume, and temperature to volume). If the simulation is on mode 0, the counter just updates the position of the piston based on the compressIn and expandIn signals entered through the switches by the user. However, if the simulation is on one of modes 2 or 3, this module generates an internal compress or expand signal by comparing the current position of the piston with where it ought to be depending on the temperature or number of moles.

### Elaboration on the pressure meter module (meterMod.v):
The pressure meter module updates the location of the pressure meter on the horizontal scale. The pressure meter is kept constant in all modes, except for the manual mode. In the manual mode, pressure meter proportionally increases with moles and temperature, while it is inversely proportional to volume. The pressureLevel represents the location the meter ought to be, based on current values of temperature, volume, and moles. The Q value is the current location of the meter. We determine whether to shift the meter to the right or left by comparing the current Q value with the pressureLevel value. Based on the right or left value, every clock cycle,  we increment the Q value by +1 or -1, respectively.

## FSM for changing moles:
Control path for the changing moles FSM:
The control path consists of the following states:
* Reset
* Load: Detects if the user presses the increase or decrease keys
* LoadWait: waits for user to release the key since the clock is running at a much faster rate than the time it takes to press and release a key
* ChangeNum: enables the datapath counter to increment/decrement the number of moles

### Data path for the changing moles FSM:
The data path just consists of a simple counter that updates the number of particles

## “Draw” Module:
This module expands on that by drawing other complex and moving shapes such as the particle, piston, PV=nRT block, the background, and the pressure meter. For the module to be able to draw all these objects, we added new states and counters to keep track of the coordinates and total pixel drawn, as well as ROM modules for each image. 

### The “draw” FSM:
The control path for the “draw” FSM consists of the following states:
LoadX: loads the reference coordinate of the object being drawn. Only used for the particle and describes the top left corner of the particle.
DrawMeter: enables the counters associated with the pressure meter. Waits for 99 clock cycles, which is the total pixel of the meter image.
DrawPVNRT:  enables the counters associated with the PV=nRT. Waits for 1299 clock cycles, which is the total pixel of the PV=nRT.
DrawBall:  enables the counters associated with the ball. Waits for 360 clock cycles, which is the total pixel of the ball.
DrawPiston:  enables the counters associated with the piston. The number of clock cycles the FSM waits depends on the height of the piston, which is variable.
Clear: clears the entire screen and replaces it with the background.mif. Waits until the entire screen is cleared.

### “Draw” FSM’s datapath components:
The important components of the datapath are summarized below:
* For the clear and each object the datapath draws, there is a counter that increments the x and y position, as well as a counter that counts the total pixel drawn at any given clock cycle. The x and y position counters are necessary to send the VGA the x and y coordinate. They are also used to determine the address location of the ROM that contains the color at each pixel. The pixel counter is necessary to be connected back to the FSM to tell it how long it needs to wait at the given draw state. 
* PV=nRT has four different ROM modules for each mode: manual, mole to temperature, mole to volume, and temperature to volume. Each PV=nRT contains mif data that represents the different ideal gas law relationship we are looking to demonstrate. There is an always block, essentially a multiplexer, that chooses between the three bit color output of each module based on the mode.  
* The output of the module is essentially the x coordinate, the y coordinate, and the color which are to be modified by the VGA display. There is an always block, again essentially a multiplexer, that chooses between what x, y, and color to load based on the enable signals from the FSM.




