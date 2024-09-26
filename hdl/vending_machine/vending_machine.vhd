library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is 
port(
      clk 		: in  std_ulogic;
      rst       	: in  std_ulogic;
      nickel    	: in  std_ulogic;
      dime      	: in  std_ulogic;
      dispense  	: out std_ulogic;
      amount    	: out natural range 0 to 15 );

end entity;

architecture vending_machine_arch of vending_machine is

type vending_state is(zero_cents, five_cents, ten_cents, fifteen_cents);

signal current_state 	: vending_state;
signal next_state	: vending_state; 
signal dispense_v 	: std_ulogic := '0';
signal amount_v		: natural range 0 to 15 := 0; 

begin

SM: process(clk,rst)
	begin
		if(rst = '1') then 
			current_state <= zero_cents;
			dispense <= '0';
			amount <= 0;
		elsif(rising_edge(clk)) then
			current_state <= next_state;
			dispense <= dispense_v;
			amount <= amount_v;
		end if;
	end process;
	
NS : process(current_state, nickel, dime)
	begin
		case (current_state) is
			when zero_cents => 
				if dime = '1' then
					next_state 	<= ten_cents;
					dispense_v 	<= '0';
					amount_v	 	<= 10;
				elsif nickel = '1' then 
					next_state 	<= five_cents;
					dispense_v 	<= '0';
					amount_v 	<= 5; 
				else
					next_state 	<= zero_cents;
					dispense_v 	<= '0';
					amount_v	 	<= 0;
				end if;
			when five_cents =>
				if dime = '1' then
					next_state 	<= fifteen_cents;
					dispense_v 	<= '1';
					amount_v		<= 15;
				elsif nickel = '1' then 
					next_state 	<= ten_cents;
					dispense_v 	<= '0';
					amount_v	 	<= 10;
				else
					next_state 	<= five_cents;
					dispense_v 	<= '0';
					amount_v		<= 5;
				end if;
			when ten_cents =>
				if dime = '1' then 
					next_state 	<= fifteen_cents;
					dispense_v 	<= '1';
					amount_v		<= 15;	
				elsif nickel = '1' then 
					next_state 	<= fifteen_cents;
					dispense_v 	<= '1';
					amount_v		<= 15;
				else
					next_state 	<= ten_cents;
					dispense_v 	<= '0';
					amount_v		<= 10;
				end if;
			when fifteen_cents => 
				next_state 	<= zero_cents;
				dispense_v 	<= '0';
				amount_v	<= 0;
			end case;

		end process;

end architecture;
