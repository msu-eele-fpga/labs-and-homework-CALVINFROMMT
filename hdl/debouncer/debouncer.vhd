
library ieee;
use ieee.std_logic_1164.all;


entity debouncer is
	generic(
		clk_period    	: time 		:= 20 ns;
		debounce_time 	: time			 );
	port(
        clk       		: in   std_ulogic;
        rst       		: in   std_ulogic;
        input       	: in   std_ulogic;
        debounced		: out  std_ulogic);
end entity;

architecture debouncer_arch of debouncer is
---- STATE SIGNALS
type button_state is (pressed, unpressed);
signal current_state	: button_state	:= unpressed;
signal next_state		: button_state	:= unpressed;
-----DELAY SIGNALS
signal debouncer_delay			: integer :=0;
---constant IGNORE_LIMIT 	: natural 	:= (debounce_time / clk_period );


begin

SM	: process(clk, rst)
	begin
		if(rst = '1') then
			current_state 	<= unpressed;
			next_state 		<= unpressed;
-- reset some counter
		elsif(rising_edge(clk)) then
			current_state 	<= next_state;
		end if;

end process;

--NS	: process(current_state, input)
--	begin
--		case(current_state) is 
--			when unpressed =>
----
---- do i need to check for IGNORE_LIMIT : debounce time / clk_period
---- to be geater than my counter if it is then i transition
---- if its less then i increment? 
--
--
--
----				if(input = '1') then 
----					next_state <= pressed;
----				end if;
----			when presses => 
----				if(counter < delay) them
----					counter = counter + 1;
----				elsif(counter = delay) then
----					next_state <= unpressed;
----		
----
--end process;






end architecture;