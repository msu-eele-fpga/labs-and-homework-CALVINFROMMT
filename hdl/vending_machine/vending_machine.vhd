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

begin

SM: process(clk,rst)
	begin
		if(rst = '1') then 
			current_state <= zero_cents;
		elsif(rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process;
	
NS : process(current_state, nickel, dime)
	begin
		case (current_state) is
			when zero_cents => 
				if nickel = '1' then 
					next_state 	<= five_cents;
					dispense 	<= '0';
					amount 		<= 5;
				elsif dime = '1' then
					next_state 	<= ten_cents;
					dispense 	<= '0';
					amount 		<= 10;
				else
					next_state 	<= zero_cents;
					dispense 	<= '0';
					amount 		<= 0;
				end if;
			when five_cents =>
				if nickel = '1' then 
					next_state 	<= ten_cents;
					dispense 	<= '0';
					amount 		<= 10;
				elsif dime = '1' then
					next_state 	<= fifteen_cents;
					dispense 	<= '1';
					amount 		<= 15;
				else
					next_state 	<= five_cents;
					dispense 	<= '0';
					amount 		<= 5;
				end if;
			when ten_cents =>
				if nickel = '1' then 
					next_state 	<= fifteen_cents;
					dispense 	<= '1';
					amount 		<= 15;
				elsif dime = '1' then
					next_state 	<= fifteen_cents;
					dispense 	<= '1';
					amount 		<= 15;
				else
					next_state 	<= ten_cents;
					dispense 	<= '0';
					amount 		<= 10;
				end if;
			when fifteen_cents => 
				next_state 	<= zero_cents;
				dispense 	<= '0';
				amount 		<= 0;
			end case;
		end process;

end architecture;
