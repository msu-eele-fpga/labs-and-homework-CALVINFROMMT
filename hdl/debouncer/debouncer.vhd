
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

signal lock_input 		: std_ulogic;

signal flag				: boolean := false;

constant IGNORE_TIME	: natural := (debounce_time / clk_period);
signal count			: integer := 0;


pulse: process(clk)
	begin
	lock_input <= input;
	if (rising_edge(clk)) then 
		if(rst = '1') then
			debounced <= '0';
			flag <= false;
			count <= 0;
		end if;
		if(input <= '1') then
			flag <= true;
			
		


	end process;


end architecture;