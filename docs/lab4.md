# Lab 4: LED Pattern.
## Project Overview
We combined our Async Conditioner created in homework with an LED pattern generator and a clock generator.  
Prior to starting the project a block diagram of my system architecture was created.  

## Functional Requirements
 - HPS_LED_control input signal: If 1 LED's controlled by AMRS HPS, if 0 LED's controlled by LED_patterns in FPGA fabric.
 - State Machine requirement 1: LED[7] blinks at base_rate seconds. on one second, off one second. 
 - State Machine requirement 2: Four states, LED[6:0] shift right 1 bit at half base rate. LED[6:0] shift left 2 bit at quarter base rate, LED[6:0] up counter 2 times base rate, LED[6:0] down count eighth the base rate, LED[6:0] personal pattern.
 - State Machine requirement 3: Transition state that displays the switch values for 1 second after the button is pressed.  If the switch configuration is not 0-3 then the pattern of the last LED state is started.  
 - Conditional push button: Buttone is sychronized with 2 d flipflops, debounced and creates one pulse for one clock cycle no matter how long the button is pressed.
 
### System Architecture

[Picture of BlockDiagram](assets/Lab4/Lab4_BlockDiagram.png)
[Picture of Final BlockDiagram](assets/Lab4/Lab4_finalBlock.png.png)

The DE10 top file or FPGA fabric is used to connect the DE10 componenets to the signals used for the LED pattern.
The LED pattern instantiates a Clock generator, and the Async-conditioner along with the statemachine and LED patterns.
The LED pattern also generates the max count value for the system clock to generate 1 second's worth of cycles.  

The Clock generator takes in the system clock and base period (non-floating point value for 1 seconds worth of system clock cycles) and outputs 5 differnt clocking rates for the 5 different patterns. 
The Async-conditioner is used for the button press.  It ensures the button press is syncronus with the clock and any debounce is removed. 

The statemachine SM: process changes the state based on system clocking event and reset and locks the current state based on the next state value.  

In the Next state process (NS) the sensitiviy is driven by the debounce flag, the transition state flag and current state. 
Starting with our current state we want to see if the button has been pressed.  Knowing the debounce is flagged shows our button has be pressed appropriately.  This will drive transitioning to the transition state.  If not pressed we stay in our current state. 
By transitioning to our transition state we enable that process and wait for the TS flag to indicate that process if over.  One second of showing the switch value before transitioning to the LED pattern.  
The previous state is maintained by the output.  If the LED switches are in a configuration other than the 4 designated to a pattern the pattern needs to default to the last known pattern. 
[Picture of State Machine](assets/Lab4/Lab4_State_Diagram.png)
[Picture of Final State Machine](assets/Lab4/Lab4_State_diagram_final.png)


### Implementation Details
#### User LED Pattern
I created a pattern that mimicked Twinkle Twinkle Little Star.  
Each LED was designated a letter on the key scale and I used the elementary piano key scale of A through F. 
A case statement was used that incremented through the keys for the song.  
![Picture of LED pattern justification](assets/Lab4/Lab_4_PersonalPattern.png)