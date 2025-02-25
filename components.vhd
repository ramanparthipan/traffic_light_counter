library IEEE;
use ieee.std_logic_1164.all;

entity bcd7seg is
	port (bcd: in std_logic_vector(3 downto 0);
	en: in std_logic;
	hex: out std_logic_vector(0 to 6));
end bcd7seg;
	
architecture behaviour of bcd7seg is
begin
			hex <= "1111110" when en = '0' else -- show a dash
				 "0000001" when (bcd = "0000") else
				 "1001111" when (bcd = "0001") else
				 "0010010" when (bcd = "0010") else
				 "0000110" when (bcd = "0011") else
				 "1001100" when (bcd = "0100") else
				 "0100100" when (bcd = "0101") else
				 "1100000" when (bcd = "0110") else
				 "0001111" when (bcd = "0111") else
				 "0000000" when (bcd = "1000") else
				 "0001100" when (bcd = "1001") else
				 "1111111";
end behaviour;


library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is 
	port(clk: in std_logic;
	slow_clk: out std_logic);
end counter;
	
architecture behaviour of counter is
	signal count : std_logic_vector(24 downto 0);
	signal tick : std_logic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			count <= count + 1;
			if count = 0 then -- overflow, takes about 0.67s with 50 MHz clock
				tick<=not tick; -- change output from 0 to 1 or vice versa
			end if;
		end if;
	end process;
	slow_clk<=tick; -- one tick should be about 1.34s
end behaviour;