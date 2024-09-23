library IEEE;
use IEEE.std_logic_1164.all;

entity synchronizer is
port(
	clk	: in  std_ulogic;
	async	: in  std_ulogic;
	sync	: out std_ulogic);
end entity;

architecture synchronizer_arch of synchronizer is

    signal current : std_ulogic;

begin
-- 2 D Flip Flop
    process (clk)
    begin
        if rising_edge(clk) then
            current <= async;
            sync    <= current;
	end if;
    end process;

end architecture;
