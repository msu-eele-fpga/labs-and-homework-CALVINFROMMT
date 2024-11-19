# Lab 7: Verifying custom component using System Console and /dev/mem
## Project Overview
In this lab we took our knowledge from Platform Designer and added a JTAP to Avalon Master Bridge component so we could use the System Console.  
After getting this to work we wrote the dev/mem file that tested the software control mode of our HPD_LED_Patterns which used the program and took in the memory address and value we wanted to write to that location.  

## Deliverables:
### Q1: What hex value did you write to base_period to have a 0.125 second base period? 
- I wrote the value 0x9.  This is because the floating point binary value for 0.5625 is 0000110  This then converts to 6 in HEX. 

### Q2: What hex value did you write to base_period to have a 0.5625 second base period? 
- I wrote the value 0x9.  This is because the floating point binary value for 0.5625 is 00001001  This then converts to 9 in HEX. 
