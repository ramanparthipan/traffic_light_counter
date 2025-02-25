library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ftr_tlc is
	port(
		clk: in std_logic;
		request: in std_logic;
		reset: in std_logic;
		output: out std_logic_vector(4 downto 0);
		hex0: out std_logic_vector(0 to 6);
		hex1: out std_logic_vector(0 to 6)
		);
end ftr_tlc;

architecture tlc_arch of ftr_tlc is
	type state_type is (G, Y, R, W);
	signal state: state_type;
	signal tick: std_logic;
	signal bcd0: std_logic_vector(3 downto 0);
	signal bcd1: std_logic_vector(3 downto 0);
	signal en: std_logic;
	component counter
		port(clk: in std_logic;
		slow_clk: out std_logic);
	end component;
	component bcd7seg
		port (bcd: in std_logic_vector(3 downto 0);
		en: in std_logic;
		hex: out std_logic_vector(0 to 6));
end component;
begin
		u1: counter 
		port map(clk=>clk, slow_clk=>tick);
		
		process (tick, reset)
			variable timer : INTEGER;
		begin
			if reset = '0' then
				state <= G;
			elsif rising_edge(tick) then -- request button needs to be pushed for ~1s for it to be registered.
				case state is
					when G =>
						if request = '0' then
							state <= Y;
							timer := 5;
						end if;
					when Y =>
						if timer = 0 then
							state <= R;
							timer := 10;
						else
							timer := timer - 1;
						end if;
					when R => 
						if timer = 0 then 
							state <= W;
							timer := 10;
						else
							timer := timer - 1;
						end if;
					when W => -- wait state to prevent traffic clogging
					 if timer = 0 then 
							state <= G;
							timer := 0; -- doesn't matter
						else
							timer := timer - 1;
						end if;
				end case;
			end if;
			if timer = 10 then
				bcd0 <= std_logic_vector(to_unsigned(0, 4));
				bcd1 <= std_logic_vector(to_unsigned(1, 4));
			else
				bcd0 <= std_logic_vector(to_unsigned(timer, 4));
				bcd1 <= std_logic_vector(to_unsigned(0, 4));
			end if;
		end process;
	
	process (state)
	begin
		case state is
			when G => 
				output <= "10001";
				en <= '0';
			when Y =>
				output <= "10010";
				en <= '1';
			when R =>
				output <= "01100";
				en <= '1';
			when W =>
				output <= "10001"; --same as green
				en <= '0';
		end case;
	end process;
	
	u2: bcd7seg
	port map(bcd=>bcd0, en=>en, hex=>hex0);
	u3: bcd7seg
	port map(bcd=>bcd1, en=>en, hex=>hex1);
	
	
	
end tlc_arch;