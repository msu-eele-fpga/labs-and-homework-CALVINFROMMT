library ieee;
use ieee.std_logic_1164.all;

entity timed_counter is
	generic (
		clk_period 	: time;
		count_time 	: time	);
	port (
		clk    		: in std_ulogic;
		enable 		: in  boolean;
		done   		: out boolean	);
end entity;

architecture timed_counter_arch of timed_counter is

	constant COUNTER_LIMIT 	: natural 	:= (count_time / clk_period );
	signal counter 		: integer 	:= 0;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if enable then
				if ((counter -1) = COUNTER_LIMIT) then
					counter 	<= 0;
					done 		<= true;
				else
					counter 	<= counter + 1;
					done 		<= false;
				end if;
			else 
				done <= false;
				counter 	<= 0;
			end if;
		else
			done <= false;
		end if;

	end process;


end architecture;