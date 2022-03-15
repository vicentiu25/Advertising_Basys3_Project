library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity reclama is
Port ( 
clk: in STD_LOGIC ;
btn : in STD_LOGIC_VECTOR(4 downto 0);
sw : in std_logic_VECTOR(15 downto 0);
led : out std_logic_VECTOR(15 downto 0);
an : out STD_LOGIC_VECTOR(3 downto 0);
cat : out STD_LOGIC_VECTOR (6 downto 0));
end reclama;
 
architecture Behavioral of reclama is

signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
signal one_second_enable: std_logic;
signal displayed_text: string (3 downto 0);
signal LED_BCD: character ;
signal reset: std_logic;
signal dText: string (0 to 9);
signal cnt: std_logic_vector(15 downto 0) := (others => '0');	

begin
dText <= "abcdefghij";
led<=sw;
    
COUNTER: process(clk)
	begin
		if rising_edge(clk) then
			cnt <= cnt + 1;	
		end if;	
	end process;
	
MUX_CAT: with LED_BCD select
	Cat <=  "0001000" when 'a',
			"0000000" when 'b',   
            "1000110" when 'c',   
            "0100001" when 'd',   
            "0000110" when 'e',   
            "0001110" when 'f',   
            "0000010" when 'g',   
            "0001001" when 'h',   
            "1001111" when 'i',   
            "1100001" when 'j',   
            "1000111" when 'l',   
            "1000000" when 'o',   
            "0001100" when 'p',   
            "0101111" when 'r',   
            "0010010" when 's',   
            "0000111" when 't',   
            "1000001" when 'u',   
            "0100100" when 'z',   
            "1111111" when others;   

MUX_AN: with cnt(15 downto 14) select
	an <=   "1110" when "00", 
			"1101" when "01",
			"1011" when "10",
			"0111" when others;

MUX_DIGITS: with cnt(15 downto 14) select
	LED_BCD <= 	displayed_text(0) when "00", 
				displayed_text(1) when "01",
				displayed_text(2) when "10",
				displayed_text(3) when others;

DIV_FRECV: process(clk, reset)
begin
        if(reset='1') then
            one_second_counter <= (others => '0');
        elsif(rising_edge(clk)) then
            if(one_second_counter>=x"5F5E0FF") then
                one_second_counter <= (others => '0');
            else
                one_second_counter <= one_second_counter + "0000001";
            end if;
        end if;
end process;
one_second_enable <= '1' when one_second_counter=x"5F5E0FF" else '0';

DISPLAY_MODES: process(clk, reset,sw)
    variable ind : integer :=0;
    variable letter : integer :=3;
    variable letterD : integer :=0;
begin
    if(rising_edge(clk)) then
    if(one_second_enable='1') then
    case sw(3 downto 0) is
    when "1000" =>
    
    if(ind /= 0 and ind mod 4 = 0) then 
        displayed_text(letter) <= dText(letterD);
        letter := letter - 1;
        letterD := letterD + 1;
    end if;
        
    if(letter = -1) then 
        letter := 3; 
        displayed_text(2 downto 0) <= "   ";  
    end if;
    
    if(ind mod 2 = 0) then
        displayed_text(letter) <= dText(letterD);
    else
        displayed_text(letter) <= ' ';
    end if;
    
    if(letter = -1) then 
        letter := 3; 
        displayed_text(3 downto 0) <= "    ";
        ind := ind -1;   
    end if;
    
    if(letterD = dText'length ) then
        displayed_text(3 downto 0) <= "    ";   
        ind :=0;
        letter := 3;
        letterD := 0;
    end if;
    ind := ind +1;
    when "0100" =>
        if ( ind mod 2 = 0) then
            if(ind mod 4 = 0) then
                displayed_text (3) <= dText(ind);
                if(ind+1 >= dText'length) then
                    displayed_text (2) <= ' ';
                else
                    displayed_text (2) <= dText(ind+1);
                end if;
                if(ind+2 >= dText'length) then
                    displayed_text (1) <= ' ';
                else
                    displayed_text (1) <= dText(ind+2);
                end if;
                if(ind+3 >= dText'length) then
                    displayed_text (0) <= ' ';
                else
                    displayed_text (0) <= dText(ind+3);
                end if;
            else
                displayed_text (3) <= dText(ind-2);
                if(ind-1 >= dText'length) then
                    displayed_text (2) <= ' ';
                else
                    displayed_text (2) <= dText(ind-1);
                end if;
                if(ind >= dText'length) then
                    displayed_text (1) <= ' ';
                else
                    displayed_text (1) <= dText(ind);
                end if;
                if(ind+1 >= dText'length) then
                    displayed_text (0) <= ' ';
                else
                    displayed_text (0) <= dText(ind+1);
                end if;
            end if;
        else
            displayed_text (3 downto 0) <= "    ";
        end if;
        ind := ind + 1;
        if(ind = (((dText'length - 1) /4) * 4)+3) then
            ind := -1;
        end if;
    when "0010" =>
        displayed_text (3) <= displayed_text (2);
        displayed_text (2) <= displayed_text (1);
        displayed_text (1) <= displayed_text (0);
        if(ind >= dText'length) then
            displayed_text (0) <= ' ';
        else
            displayed_text (0) <= dText(ind);
        end if;
        ind := ind + 1;
        if(ind = dText'length + 4) then
            ind :=0;
        end if;
    when "0001" =>
        if(ind >= dText'length) then
            displayed_text (0) <= ' ';
        else
            displayed_text (0) <= dText(ind);
        end if;
        displayed_text (3 downto 1) <= "   ";
        ind := ind + 1;
        if(ind = dText'length + 2) then
            ind :=0;
         end if;
    when others => 
        displayed_text (3 downto 0) <= "    ";
        ind :=0;
        letter := 3;
        letterD := 0;
    end case;
    end if;
    end if;
end process;

end Behavioral;
