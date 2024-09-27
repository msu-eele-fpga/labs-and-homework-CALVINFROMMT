library ieee;
use ieee.std_logic_1164.all;


entity one_pulse is
	port (

		clk 	: in  std_ulogic;
		rst 	: in  std_ulogic;
		input 	: in  std_ulogic;
		pulse 	: out std_ulogic);

end entity;

architecture one_pulse_arch of one_pulse is 	

---- STATE MACHINE VARIABLES
type pulse_state is (pulse_start, pulse_done, pulse_waitH, pulse_waitL);

signal current_state	: pulse_state := pulse_waitL;
signal next_state		: pulse_state;


	begin

SM: process(clk)
		begin
			if(rst = '1') then 
				current_state <= pulse_waitL;
			
			elsif(rising_edge(clk)) then
				current_state <= next_state;	  
			end if;	
	end process;

NS: process(clk, input, current_state)
	begin
		if(rst = '1') then
			next_state <= pulse_waitL;
		elsif(rising_edge(clk)) then
		case (current_state) is 
			when pulse_waitL => 
				if (input = '1') then 
					next_state <= pulse_start;
				else
					next_state <= pulse_waitL;
				end if;
			when pulse_start => 
				pulse <= '1';
				next_state <= pulse_done;
			when pulse_done => 
				pulse <= '0';
				if (input = '1') then 
					next_state <= pulse_waitH;
				else
					next_state <= pulse_waitL;
				end if; 
			when pulse_waitH => 
				if (input = '0') then 
					next_state <= pulse_waitL;
				end if;
		end case;
		end if;
end process;

end architecture;
