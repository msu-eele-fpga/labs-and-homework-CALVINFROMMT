library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aysnc_conditioner is
	port (
		clk 	: in  std_ulogic;
		rst 	: in  std_ulogic;
		async 	: in  std_ulogic;
		sync 	: out std_ulogic);

end entity aysnc_conditioner;

architecture aysnc_conditioner_arch of aysnc_conditioner is 
-- Intantiate synchronizer, debouncer, and one pulse components 
	component synchronizer is 
		port(
			clk		: in  std_ulogic;
			async	: in  std_ulogic;
			sync	: out std_ulogic);
	end component;

	component debouncer is
		port(
        	clk       		: in   std_ulogic;
        	rst       		: in   std_ulogic;
        	input       	: in   std_ulogic;
        	debounced		: out  std_ulogic);
	end component;

	component one_pulse is
		port (
			clk 	: in  std_ulogic;
			rst 	: in  std_ulogic;
			input 	: in  std_ulogic;
			pulse 	: out std_ulogic);
	end component;

-- Need two internal signals to connect the synchronizer output with the input to the debouncer 
--  and the output of the debouncer to the input of the one-pulse.
signal debounced_sig	: std_ulogic;
signal syn_sync			: std_ulogic;

begin
	DUT1: synchronizer port map(clk			=> clk,
								async 		=> async,
								sync  		=> syn_sync);

	DUT2: debouncer port map(	clk   		=> clk,
								rst			=> rst,
								input 		=> syn_sync,
								debounced  	=> debounced_sig);

	DUT3: one_pulse port map(	clk			=> clk,
								rst 		=> rst,
								input 		=> debounced_sig,
								pulse  		=> sync);


end architecture;