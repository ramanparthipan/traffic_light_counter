library IEEE;
use ieee.std_logic_1164.all;

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
	signal bcd: std_logic_vector(3 downto 0);
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
		
		process (clk, reset)
			variable count : INTEGER;
		begin
			if reset = '0' then
				state <= G;
			elsif rising_edge(clk) then
				case state is
					when G =>
						if request = '0' then
							state <= Y;
							count := 0;
						end if;
					when Y =>
						if count = 250000000 then
							state <= R;
							count := 0;
						else
							count := count + 1;
						end if;
					when R => 
						if count = 500000000 then 
							state <= W;
							count := 0;
						else
							count := count + 1;
						end if;
					when W => -- wait state to prevent traffic clogging
					 if count = 200000000 then 
							state <= G;
							count := 0;
						else
							count := count + 1;
						end if;
				end case;
			end if;
		end process;
	
	process (state)
	begin
		case state is
			when G => 
				output <= "10001";
			when Y =>
				output <= "10010";
			when R =>
				output <= "01100";
			when W =>
				output <= "10001"; --same as green
		end case;
	end process;
	
	en <= '1';
	bcd <= "0110";
	
	u2: bcd7seg
	port map(bcd=>bcd, en=>en, hex=>hex0);
	u3: bcd7seg
	port map(bcd=>bcd, en=>en, hex=>hex1);
	
	
	
end tlc_arch;