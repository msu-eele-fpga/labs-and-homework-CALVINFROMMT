library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity one_pulse_tb is
end entity;

architecture one_pulse_tb_arch of one_pulse_tb is 
	component one_pulse is
		port (
	
			clk 			: in  std_ulogic;
			rst 			: in  std_ulogic;
			input 			: in  std_ulogic;
			pulse 			: out std_ulogic);
	
	end component;

		signal clk_tb       : std_ulogic := '0';
		signal rst_tb     	: std_ulogic := '0';
	  	signal input_tb     : std_ulogic := '0';
	  	signal pulse_tb     : std_ulogic := '0';	
		
	
	begin

	DUT :  one_pulse port map ( 
			clk   => clk_tb,
			rst   => rst_tb,
		  	input => input_tb,
		  	pulse => pulse_tb);

	clk_tb <= not clk_tb after 20 ns;
	
	STIMULUS : process
	begin
--start
		input_tb <= '0'; rst_tb <= '0'; wait for 50 ns;
--check reset
		input_tb <= '0'; rst_tb <= '1'; wait for 50 ns;
		input_tb <= '1'; rst_tb <= '1'; wait for 50 ns;
--back to start
		input_tb <= '0'; rst_tb <= '0'; wait for 100 ns;
--check first input
		input_tb <= '1'; rst_tb <= '0'; wait for 150 ns;
		input_tb <= '0'; rst_tb <= '0'; wait for 50 ns;
--check long input
		input_tb <= '1'; wait for 200 ns;
		input_tb <= '0'; wait for 200 ns;
--check medium input
		input_tb <= '1'; wait for 100 ns;
		input_tb <= '0'; wait for 100 ns;
--check short input
		input_tb <= '1'; wait for 50 ns;
		input_tb <= '0'; wait for 50 ns;
		

	end process;

end architecture;