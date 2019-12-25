# idealgaslawsimulator
Both of us are physics enthusiasts, and we decided to use this project as an opportunity to see if we can use hardware to help us visualize some of the concepts we learned in high school. We tried to aim for a project with many dynamic parts, while simplifying the initial stages of the project so that we can add complexity by gradually building on something that is already functional. 

We wanted to replicate the ideal gas law simulators that we saw in high school with Verilog. Since the purpose of these simulators are to provide students with a better intuition of the ideal gas law, we wanted to be able to show the different relationships between each variable with appropriate visual aid. To demonstrate the different relationships, we wanted to be able to test the relation between one independent and dependent variable, while keeping other variables constant. Furthermore, since there are many ideal gas law simulators available online, we had a way to benchmark our design against existing ones.


## “Main” Module:
### The “main” FSM control path:
The control path for the “main” FSM consists of the following states:
Reset_Pos: This is the reset state where everything on the screen is reset.
DrawWait: Everything including the particles, the piston, the pressure meter, and the PV=NRT equation are drawn in this state.
RateDividerWait: In this state, we make the screen stay static for a certain amount of time; this controls how fast/slow we see things updating and moving on the screen.
EraseWait: This state makes sure we wait long enough for everything to be erased before updating the screen so that we don’t draw new items on top of existing items
UpdateShiftReg: This state updates the contents of the direction registers to be described in the data path below.
UpdatePos: This state updates the positions of the particles

### The “main” datapath FSM:
The important components of the datapath for the main FSM are summarized below:
The drawWaitCounter, rateDividerCounter, and eraseWaitCounter. These counters make the circuit wait (i.e. not do any action) until everything has been drawn on the screen,  until the screen has waited long enough before updating, and until everything has been erased before updating, respectively.
Each particle has one of the following:
An x-Counter that updates the x-position of the particle
A y-Counter that updates the y-position of the particle
A T flip flop holding the horizontal direction of motion (1 for right, 0 for left)
A T flip flop holding the vertical direction of motion (1 for down, 0 for up)
10 checkCollision module instantiations that check for the 10 possible collisions that could happen in a system of 5 colliding particles. These instantiations consist of purely combinational logic that checks if the centers of two particles are at a certain distance away from each other.
BorderCounter, which updates the position of the border defined by the piston
Meter counter, which is used for controlling the position of the pressure meter
An instantiation of the module that controls the input to the VGA Adapter in order to draw each individual pixel

