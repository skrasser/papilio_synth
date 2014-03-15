library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac is
  port (pulse  : out STD_LOGIC;
        data   : in  STD_LOGIC_VECTOR(7 downto 0);
        clk    : in  STD_LOGIC
       );
end dac;

architecture behavioral of dac is
  signal sum : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
begin
  pulse <= sum(8);
  
  process(clk)
  begin
    if rising_edge(clk) then
      sum <= std_logic_vector(unsigned("0" & sum(7 downto 0)) + unsigned("0" & data));
    end if;
  end process;   

end behavioral;
