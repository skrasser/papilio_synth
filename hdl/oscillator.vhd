library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity oscillator is
  port (data     : out STD_LOGIC_VECTOR(7 downto 0);
        freq     : in  STD_LOGIC_VECTOR(15 downto 0);
        waveform : in  STD_LOGIC;
        clk      : in  STD_LOGIC
       );
end oscillator;

architecture behavioral of oscillator is
  component sawtooth
    port (data     : out STD_LOGIC_VECTOR(7 downto 0);
          freq     : in  STD_LOGIC_VECTOR(15 downto 0);
          clk      : in  STD_LOGIC
         );
  end component;
  signal phase  : STD_LOGIC_VECTOR(7 downto 0);
begin
  -- use sawtooth to get phase
  phasegen: sawtooth
    port map(phase, freq, clk);

  -- use input to select waveform
  process(clk, phase, waveform)
  begin
    if rising_edge(clk) then -- latched so data is stable
      if waveform = '0' then
        -- just using phase for raw sawtooth
        data <= phase;
      else
        if phase(7) = '0' then -- first half of sawtooth
          -- ramp up at twice the speed
          data <= phase(6 downto 0) & '0';
        else
          -- second half, ramp down
          data <= (phase(6 downto 0) xor "1111111") & '0';
        end if;
      end if;
    end if;
  end process;
  
end behavioral;
