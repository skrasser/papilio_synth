library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sawtooth is
  port (data : out STD_LOGIC_VECTOR(7 downto 0);
        freq : in  STD_LOGIC_VECTOR(15 downto 0);
        clk  : in  STD_LOGIC
       );
end sawtooth;

architecture behavioral of sawtooth is
  signal sum : STD_LOGIC_VECTOR(21 downto 0) := (others => '0');
  signal adata : STD_LOGIC_VECTOR(7 downto 0);
begin
  data <= adata;
  
  process(clk)
  begin
    if rising_edge(clk) then
      sum <= std_logic_vector(unsigned("0" & sum(20 downto 0)) + unsigned(freq));
      if sum(21) = '1' then
        adata <= std_logic_vector(unsigned(adata) + 1);
      end if;
    end if;
  end process;   

end behavioral;
