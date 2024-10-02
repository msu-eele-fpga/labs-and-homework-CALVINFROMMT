library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aysnc_conditioner_tb is
	port (
		clk 	: in  std_ulogic;
		rst 	: in  std_ulogic;
		async 	: in  std_ulogic;
		sync 	: out std_ulogic);
end entity aysnc_conditioner_tb;

architecture testbench of aysnc_conditioner_tb is 

  signal clk_tb     : std_ulogic := '0';
  signal rst_tb     : std_ulogic := '0';
  signal async_tb   : std_ulogic := '0';
  signal sync_tb		: std_ulogic := '0';

begin



end architecture;
