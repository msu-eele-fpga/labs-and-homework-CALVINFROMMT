library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;


entity led_patterns_avalon is
	port (
		clk 				: in 	std_ulogic;
		reset 			: in 	std_ulogic;
		
-- avalon memory-mapped slave interface
		avs_read 		: in 	std_ulogic;
		avs_write 		: in 	std_ulogic;
		avs_address 	: in 	std_ulogic_vector(1  downto 0);
		avs_readdata 	: out std_ulogic_vector(31 downto 0);
		avs_writedata 	: in 	std_ulogic_vector(31 downto 0);
		
-- external I/O; export to top-level
		push_button 	: in 	std_ulogic;
		switches 		: in 	std_ulogic_vector(3 downto 0);
		led 				: out std_ulogic_vector(7 downto 0));
		
end entity;

architecture led_patterns_avalon_arch of led_patterns_avalon is 


component LED_pattern is 
	generic(system_clock_period : time := 20 ns);
	port(
			clk					 : in  std_ulogic;		
			reset			   	 : in  std_ulogic;
			push_button		    : in  std_ulogic;
			switches		   	 : in  std_ulogic_vector(3 downto 0);
			hps_led_control	 : in  std_ulogic;
			base_period			 : in  std_ulogic_vector(7 downto 0);
			led_reg				 : in  std_ulogic_vector(7 downto 0);
			led					 : out std_ulogic_vector(7 downto 0));		

end component;


signal hps_led_controler 	: std_ulogic := '0';
signal base_period 			: std_ulogic_vector(7 downto 0) := "00010000" ;-- for base_period 
signal led_reg 				: std_ulogic_vector(7 downto 0) := "11111111";


signal holder 					: std_ulogic_vector(31 downto 0) := (others => '0');



begin

LED_PAT: LED_Pattern 
	port map(
		clk 					=> clk, 
		reset	 				=> reset, 
		push_button 		=> push_button, 
		switches 			=> switches, 
		hps_led_control 	=> hps_led_controler, 
		base_period 		=> base_period, 
		led_reg 				=> led_reg, 
		led 					=> led);
		
		
avalon_register_read : process(clk) 
begin 
	if rising_edge(clk) and avs_read = '1' then 
		case avs_address is 
			when "00" 	=> avs_readdata 		<= holder(31 downto 1) & hps_led_controler;
			when "01" 	=> avs_readdata 		<= holder(31 downto 8) & led_reg;
			when "10" 	=> avs_readdata 		<= holder(31 downto 8) & base_period;
			when others => avs_readdata 		<= (others => '0');
			
		end case;
	end if;
end process;

avalon_register_write : process(clk, reset)

begin
	if reset = '1' then 
		hps_led_controler <= '0'; 			-- so in hardwhare control mode is led_fabric; 
		led_reg 				<= "11100111"; -- 11100111 picked configuration that will dictate led_reg working.
		base_period 		<= "00010000"; -- 1 second, value with floating point.
		
	elsif rising_edge(clk) and avs_write = '1' then
		case avs_address is
			when "00" 	=> hps_led_controler <= 	avs_writedata(0);
			when "01" 	=> led_reg 				<= 	avs_writedata(7 downto 0);
			when "10" 	=> base_period 		<= 	avs_writedata(7 downto 0);
			when others => null;
		end case;
	end if;
	
end process;
	
end architecture;

-- Connect nodes in platform designer 
-- Platform designer gives 3 extra signals has led-led and push buttons and switches.  