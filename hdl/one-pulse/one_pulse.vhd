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

signal pulse_flag			 : std_ulogic := '0';

	begin
	process(clk)
		begin
		if rising_edge(clk) then

			if (rst = '1') then
				pulse <= '0';
			elsif (pulse_flag = '1') then
				if (input = '0') then
					pulse <= '0';
					pulse_flag <= '0';
				elsif (input = '1') then
					pulse <= '0';
				end if;
			elsif(pulse_flag = '0') then
				if (input = '0') then
					pulse <= '0';
				elsif(input = '1') then
					pulse <= '1';
					pulse_flag <= '1';
				end if;
			end if;
		end if;
				
end process;

end architecture;
