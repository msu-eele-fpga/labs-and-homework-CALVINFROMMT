
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

signal previous_input 				: std_ulogic;
signal time_over_flag				: boolean := false;
signal lock_input_flag				: boolean := false;

constant IGNORE_TIME	: natural := (debounce_time / clk_period);
signal count			: integer := 0;

begin

process(clk)
	begin

	if (rising_edge(clk)) then 
		if(rst = '1') then
			debounced <= '0';
			previous_input <= '0';
			count <= 0;
			lock_input_flag <= false;

		elsif(previous_input = '0' and input = '1' and lock_input_flag = false) then
			lock_input_flag <= true;	
			previous_input <= input;
			debounced <= input;
			count <= count + 1;

		elsif(previous_input = '1' and count < IGNORE_TIME) then
			count <= count + 1;

		elsif(previous_input = '1' and input = '1' and count = IGNORE_TIME) then
			-- do nothing
		elsif(previous_input = '1' and input = '0' and count = IGNORE_TIME) then
			debounced <= input;
			previous_input <= input;
			count <= 0;

		elsif(previous_input = '0' and count < IGNORE_TIME and lock_input_flag = true) then
			count <= count + 1;

		elsif(previous_input = '0' and count = IGNORE_TIME and input = '0' and lock_input_flag = true) then
			lock_input_flag <= false;
			count <= 0;
		else

		end if;
	end if;

	end process;


end architecture;