library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;


entity LED_pattern is
	generic( system_clock_period : time := 20 ns);
	port(
			clk					 : in  std_ulogic;		
			reset			   	 : in  std_ulogic;
			push_button		     : in  std_ulogic;
			switches		   	 : in  std_ulogic_vector(3 downto 0);
			hps_led_control		 : in  boolean;
			base_period			 : in  unsigned(7 downto 0);
			led_reg				 : in  std_ulogic_vector(7 downto 0);
			led					 : out std_ulogic_vector(7 downto 0));		
end entity;

architecture LED_pattern_arch of LED_pattern is
-------------------------------------------------------------------------------
-- CLOCK STUFF and COUNTERS
constant SYS_CLK_FREQ: unsigned(25 downto 0) := (to_unsigned((1 sec / system_clock_period), 26));
constant N_BITS_CLK_CYCLES_FULL: natural := 34;
constant N_BITS_CLK_CYCLES : natural := 30;

signal period_base_clk_full_prec: unsigned(N_BITS_CLK_CYCLES_FULL-1 downto 0);

signal period_base_clk: unsigned(N_BITS_CLK_CYCLES-1 downto 0);

-- Counters 
signal LED7_counter : integer := 0;						-- Counter for 1 sec base rate LED
signal up_counter	: unsigned(6 downto 0) := "0000000";	-- Counter for going up
signal down_counter : unsigned(6 downto 0) := "1111111";	-- Counter for going down
signal ttls_counter : integer := 0;							-- Counter for my pattern
-------------------------------------------------------------------------------
-- Clock generators
component Clock_Gen is
	port (
			clk						: in  std_ulogic;		
			reset			   		: in  std_ulogic;
			base_period				: in  unsigned(29 downto 0);
			clock_twobase			: out std_ulogic;	
			clock_halfbase			: out std_ulogic;	
			clock_quarterbase		: out std_ulogic;	
			clock_eigthbase		: out std_ulogic;
			clock_sixthbase		: out std_ulogic);
end component; 

signal Clock_twobase 			: std_ulogic;
signal Clock_halfbase			: std_ulogic;
signal Clock_quarterbase		: std_ulogic;
signal Clock_eigthbase			: std_ulogic;
signal Clock_sixthbase			: std_ulogic;
-------------------------------------------------------------------------------
-- STATE SIGNALS 
type State_Type is (S0, S1, S2, S3, S4 ,TS);
signal current_state, next_state, previous : State_Type := S0;
signal button_count 	: integer := 0; -- value for button debounce 1 sec before completing state

-- Tansition State
signal TS_counter		: integer := 0;
signal TS_flag 		: std_ulogic := '0';
signal TS_enable 		: std_ulogic := '0';
-------------------------------------------------------------------------------
-- OUTPUT SIGNALS
signal PAT0_out 		: unsigned(6 downto 0) 	:= "1000000";	-- One Shift Right
signal PAT1_out 		: unsigned(6 downto 0) 	:= "0000011";	-- Two Shift Left
signal PAT2_out 		: unsigned(6 downto 0) 	:= "0000000";	-- 7 bit counter UP	
signal PAT3_out 		: unsigned(6 downto 0) 	:= "1111111";	-- 7 bit counter DOWN
signal PAT4_out 		: unsigned(6 downto 0) 	:= "0000000";	-- My pattern (SONG)
signal PAT_LED7     	: std_ulogic 				:= '0';					-- LED7 Patterns
signal PATTS_out		: std_ulogic_vector(3 downto 0) := "0000";	-- 1 sec flas
signal led_fabric  	: std_ulogic_vector(7 downto 0); -- This will be what LED_pattern generates.

-------------------------------------------------------------------------------
-- CONDITIONER FOR BUTTON
component aysnc_conditioner is
	port (
		clk 		: in  std_ulogic;
		rst 		: in  std_ulogic;
		async 	: in  std_ulogic;
		sync 		: out std_ulogic);

end component;

signal debounce_button : std_logic;

-------------------------------------------------------------------------------
	begin

period_base_clk_full_prec <= SYS_CLK_FREQ * base_period;

period_base_clk <= period_base_clk_full_prec(N_BITS_CLK_CYCLES_FULL-1 downto 4); 

clock_generator: Clock_Gen
		port map( 			
			clk						=> clk,
			reset			   		=> reset,
			base_period				=> period_base_clk,
			clock_twobase			=> Clock_twobase,
			clock_halfbase			=> Clock_halfbase,
			clock_quarterbase		=> Clock_quarterbase,
			clock_eigthbase		=> Clock_eigthbase,
			clock_sixthbase		=> Clock_sixthbase);
			
-------------------------------------------------------------------------------
condition_button: aysnc_conditioner port map (
		clk 		=> clk,
		rst 		=> reset,
		async 	=> push_button,
		sync 		=> debounce_button);
-------------------------------------------------------------------------------
hps_led_controler : process (clk)
			begin
				if (hps_led_control = True) then
						led <= led_reg;
				else
						led <= led_fabric;
				end if;
			end process;
-------------------------------------------------------------------------------
-- LED 7 Blinks at the rate of the base_period. On for 1 sec, Off for 1 sec.  
LED7_PAT : process(clk, reset)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				LED7_counter <= 0;
				--LED7_counter <= (others => '0'); 
			else
				if (LED7_counter > period_base_clk) then
					PAT_LED7 <= not PAT_LED7;
					LED7_counter <= 0;
				else
					LED7_counter <= LED7_counter + 1;
				end if;
			end if;
		end if;
end process;
-- LED pattern for the other 7 LED's (6 downto 0).  This will rotate 1 LED to the right every half base clock.
LEDs_PAT0 : process (Clock_halfbase, reset, current_state)  -- rotate right 1 LED "0000000"
	begin
	if(rising_edge(Clock_halfbase)) then
		if(current_state = S0) then
			if(reset = '1') then
				PAT0_out <= "1000000";
			else
				PAT0_out <= rotate_right(PAT0_out,1);
			end if;
		else
			PAT0_out <= "1000000";
		end if;
	end if;
	end process;

LEDs_PAT1 : process (Clock_quarterbase, reset, current_state)
	begin
	if(rising_edge(Clock_quarterbase)) then
		if(current_state = S1) then
			if(reset = '1') then
				PAT1_out <= "0000011";
			else
				PAT1_out <= rotate_left(PAT1_out,1);
			end if;
		else
			PAT1_out <= "0000011";
		end if;
	end if;
	end process;

LEDs_PAT2 : process (Clock_twobase, reset, current_state)
	begin
	if(rising_edge(Clock_twobase)) then	
		if(current_state = S2) then
			if (reset = '1') then
				up_counter <= "0000000";
			else
				if (up_counter = "1111111") then
					up_counter <= "0000000";
				else
					up_counter <= up_counter + 1;
						
				end if; 
			end if;
			PAT2_out <= up_counter;
		else
			up_counter <= "0000000";
		end if;
	end if;

	end process;

LEDs_PAT3 : process (Clock_eigthbase, reset, current_state)
	begin
		if(rising_edge(Clock_eigthbase)) then
			if (reset = '1') then
				down_counter <= "1111111";
			elsif (current_state = S3) then
				if (down_counter = "0000000") then
					down_counter <= "1111111";
				else
					down_counter <= down_counter -  1;
				end if;
				PAT3_out <= down_counter;
			end if;
		end if;
	end process;

LEDs_PAT4 : process (Clock_eigthbase, reset, current_state)
	begin
	if(rising_edge(Clock_eigthbase)) then
		if (current_state = S4) then
			if (reset = '1') then
				ttls_counter <= 0;
			else
				case(ttls_counter) is 
					when 1 => PAT4_out <= "0000001";
					when 2 => PAT4_out <= "0000001";
					when 3 => PAT4_out <= "0001000";
					when 4 => PAT4_out <= "0001000";
					when 5 => PAT4_out <= "0000100";
					when 6 => PAT4_out <= "0000100";
					when 7 => PAT4_out <= "0001000";
					when 8 => PAT4_out <= "0000000";
					when 9 => PAT4_out <= "0010000";
					when 10 => PAT4_out <= "0010000"; 
					when 11 => PAT4_out <= "0100000";
					when 12 => PAT4_out <= "0100000";
					when 13 => PAT4_out <= "1000000";
					when 14 => PAT4_out <= "1000000";
					when 15 => PAT4_out <= "0000001";
					when 16 => PAT4_out <= "0000000";
					when 17 => PAT4_out <= "0001000";
					when 18 => PAT4_out <= "0001000";
					when 19 => PAT4_out <= "0010000";
					when 20 => PAT4_out <= "0010000";
					when 21 => PAT4_out <= "0100000";
					when 22 => PAT4_out <= "0100000";
					when 23 => PAT4_out <= "1000000";
					when 24 => PAT4_out <= "0000000";
					when 25 => PAT4_out <= "0001000";
					when 26 => PAT4_out <= "0001000";
					when 27 => PAT4_out <= "0010000";
					when 28 => PAT4_out <= "0010000";
					when 29 => PAT4_out <= "0100000";
					when 30 => PAT4_out <= "0100000";
					when 31 => PAT4_out <= "1000000";
					when 32 => PAT4_out <= "0000000";
					when 33 => PAT4_out <= "0000001";
					when 34 => PAT4_out <= "0000001";
					when 35 => PAT4_out <= "0001000";
					when 36 => PAT4_out <= "0001000";
					when 37 => PAT4_out <= "0000100";
					when 38 => PAT4_out <= "0000100";
					when 39 => PAT4_out <= "0001000";
					when 40 => PAT4_out <= "0000000";
					when 41 => PAT4_out <= "0010000";
					when 42 => PAT4_out <= "0010000";
					when 43 => PAT4_out <= "0100000";
					when 44 => PAT4_out <= "0100000";
					when 45 => PAT4_out <= "1000000";
					when 46 => PAT4_out <= "1000000";
					when 47 => PAT4_out <= "0000001";
					when 48 => PAT4_out <= "0000000";
					when others => PAT4_out <= "0000000";
				end case;
				ttls_counter <= ttls_counter +1;
			end if;
		else
			ttls_counter <= 0;
		end if;
	end if;
	end process;

Transition_state : process(clk, reset, TS_enable)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				TS_counter <= 0; 
				TS_flag <= '0';
			elsif (TS_enable = '1') then 
				if (TS_counter > period_base_clk) then
					PATTS_out <= switches;
					TS_counter <= 0;
					TS_flag <= '1';
				else
					TS_counter <= TS_counter + 1;
					PATTS_out <= switches;
				end if;
			else 
				TS_flag <= '0';
			end if;
		end if;
end process;

-------------------------------------------------------------------------------
-- STATE PROCESSES
SM: process(clk) 
	begin
		if (rising_edge(clk)) then
			if (reset = '1')then
				current_state <= TS;
			else
				current_state <= next_state;  
			end if;	
		end if;
end process;


NS : process(debounce_button, TS_flag, current_state)
	begin
			case(current_state) is 
				when S0 => 
					if (debounce_button = '1') then
						next_state <= TS;
						
					else 
						next_state <= S0;
						
					end if;
				when S1 => 
					if (debounce_button = '1') then
						next_state <= TS;
						
					else 
						next_state <= S1;
					end if;
				when S2 => 
					if (debounce_button = '1') then
						next_state <= TS;
						
					else 
						next_state <= S2;
					end if;
				when S3 => 
					if (debounce_button = '1') then
						next_state <= TS;
						
					else 
						next_state <= S3;
					end if;
				when S4 => 
					if (debounce_button = '1') then
						next_state <= TS;
				
					else 
						next_state <= S4;
					end if;
				when TS => 
					if (TS_flag = '1') then
						case (switches) is						-- Transition is complete now we can go into next state.
							when "0000" => next_state <= S0;
								
							when "0001" => next_state <= S1;
								
							when "0010" => next_state <= S2;
								
							when "0011" => next_state <= S3;
								
							when "0100" => next_state <= S4;
								
							when others => next_state <= previous;
								
						end case;
					else 
						next_state <= TS;
					end if;
				when others =>
						if (debounce_button = '1') then
							next_state <= TS;
						else 
							next_state <= previous;
						end if;
				end case;
end process; 

OS : process(current_state, clk)
	begin
		if (rising_edge(clk)) then 
			case (current_state) is 
				when S0 => led_fabric <= PAT_LED7 & std_ulogic_vector(PAT0_out);
					TS_enable <= '0';
					previous <= S0;
				when S1 => led_fabric <= PAT_LED7 & std_ulogic_vector(PAT1_out);
					TS_enable <= '0';
					previous <= S1;
				when S2 => led_fabric <= PAT_LED7 & std_ulogic_vector(PAT2_out);
					TS_enable <= '0';
					previous <= S2;
				when S3 => led_fabric <= PAT_LED7 & std_ulogic_vector(PAT3_out);
					TS_enable <= '0';
					previous <= S3;
				when S4 => led_fabric <= PAT_LED7 & std_ulogic_vector(PAT4_out);
					TS_enable <= '0';
					previous <= S4;
				when TS => led_fabric <= PAT_LED7 & "000" & PATTS_out;
					TS_enable <= '1';
				when others => led_fabric <= "11111111"; -- If we somehow go to a non-case we will have the switch configuration.
					TS_enable <= '0';
			end case;
		end if;
end process;

end architecture;
