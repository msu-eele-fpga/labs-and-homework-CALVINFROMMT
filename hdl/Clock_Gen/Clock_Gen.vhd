library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;


entity Clock_Gen is
	port(
			clk					: in  std_ulogic;		
			reset			   	: in  std_ulogic;
			base_period			: in  unsigned(29 downto 0);
			clock_twobase		: out std_ulogic;	
			clock_halfbase		: out std_ulogic;	
			clock_quarterbase	: out std_ulogic;	
			clock_eigthbase		: out std_ulogic;
			clock_sixthbase		: out std_ulogic);
end entity;

architecture Clock_Gen_arch of Clock_Gen is 

signal halfbase_count 			: unsigned(29 downto 0);
signal quarterbase_count 		: unsigned(29 downto 0);
signal eighthbase_count 		: unsigned(29 downto 0);
signal sixthbase_count			: unsigned(29 downto 0);
signal twobase_count 			: unsigned(29 downto 0);

-- Signals used in the process then will be used to connect synthesisable output.
signal p_halfbase			: std_ulogic := '0';
signal p_quarterbase		: std_ulogic := '0';
signal p_eigthbase		: std_ulogic := '0';
signal p_sixthbase 		: std_ulogic := '0';
signal p_twobase 			: std_ulogic := '0';

signal h_count : unsigned(29 downto 0)	:= (others => '0');
signal q_count : unsigned(29 downto 0)	:= (others => '0');
signal e_count : unsigned(29 downto 0)	:= (others => '0');
signal s_count : unsigned(29 downto 0)	:= (others => '0');
signal t_count : unsigned(29 downto 0)	:= (others => '0');


	begin

halfbase_count 		<= shift_right(base_period,1);
quarterbase_count 	<= shift_right(base_period,2);
eighthbase_count 		<= shift_right(base_period,3);
sixthbase_count 		<= shift_right(base_period,4);
twobase_count			<= shift_left (base_period,1);

half_base : process(clk,reset)
	begin
		if reset = '1' then
            h_count  <= (others => '0');
            p_halfbase 	<= '0';
		elsif rising_edge(clk) then
			if h_count > halfbase_count then
                h_count <= (others => '0');
				p_halfbase <= not p_halfbase;
            else
                h_count <= h_count + 1;
            end if;
        end if;
	end process;

quarter_base : process(clk,reset)
	begin
		if reset = '1' then
            q_count  <= (others => '0');
            p_quarterbase 	<= '0';
		elsif rising_edge(clk) then
			if q_count > quarterbase_count then
                q_count <= (others => '0');
				p_quarterbase <= not p_quarterbase;
            else
                q_count <= q_count + 1;
            end if;
        end if;
	end process;

eighth_base : process(clk,reset)
	begin
		if reset = '1' then
            e_count  	<= (others => '0');
            p_eigthbase <= '0';
		elsif rising_edge(clk) then
			if e_count > eighthbase_count then
                e_count 	<= (others => '0');
				p_eigthbase <= not p_eigthbase;
            else
                e_count <= e_count + 1;
            end if;
        end if;
	end process;

sixth_base : process(clk,reset)
	begin
		if reset = '1' then
            s_count  	<= (others => '0');
            p_sixthbase <= '0';
		elsif rising_edge(clk) then
			if s_count > sixthbase_count then
                s_count 	<= (others => '0');
				p_sixthbase <= not p_sixthbase;
            else
                s_count <= s_count + 1;
            end if;
        end if;
	end process;

two_base : process(clk,reset)
	begin
		if reset = '1' then
            t_count  	<= (others => '0');
            p_twobase <= '0';
		elsif rising_edge(clk) then
			if t_count > twobase_count then
                t_count 	<= (others => '0');
				p_twobase <= not p_twobase;
            else
                t_count <= t_count + 1;
            end if;
        end if;
	end process;


		clock_halfbase 		<= p_halfbase;
		clock_quarterbase 	<= p_quarterbase;
		clock_eigthbase 		<= p_eigthbase;
		clock_sixthbase 		<= p_sixthbase;
		clock_twobase  		<= p_halfbase;


end architecture;