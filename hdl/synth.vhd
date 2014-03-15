library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity synth is
  port (audio  : out STD_LOGIC;
        led    : out STD_LOGIC_VECTOR(7 downto 0);
        switch : in  STD_LOGIC_VECTOR(7 downto 0);
        clk    : in  STD_LOGIC
       );
end synth;

architecture behavioral of synth is

  component dac
    port (pulse  : out STD_LOGIC;
          data   : in  STD_LOGIC_VECTOR(7 downto 0);
          clk    : in  STD_LOGIC
         );
  end component;

  component oscillator
    port (data     : out STD_LOGIC_VECTOR(7 downto 0);
          freq     : in  STD_LOGIC_VECTOR(15 downto 0);
          waveform : in  STD_LOGIC;
          clk      : in  STD_LOGIC
         );
  end component;

  component envelope
    port (data_in  : in  STD_LOGIC_VECTOR(7 downto 0);
          data_out : out STD_LOGIC_VECTOR(7 downto 0);
          attack   : in  STD_LOGIC_VECTOR(3 downto 0);  -- attack rate
          delay    : in  STD_LOGIC_VECTOR(3 downto 0);  -- delay rate
          sustain  : in  STD_LOGIC_VECTOR(3 downto 0);  -- sustain level
          release  : in  STD_LOGIC_VECTOR(3 downto 0);  -- release rate
          gate     : in  STD_LOGIC;
          clk      : in  STD_LOGIC
         );
  end component;
  
  signal data   : STD_LOGIC_VECTOR(7 downto 0);
  signal vol    : STD_LOGIC_VECTOR(7 downto 0);
  signal rdata1 : STD_LOGIC_VECTOR(7 downto 0);
  signal data1  : STD_LOGIC_VECTOR(7 downto 0);
  signal freq1  : STD_LOGIC_VECTOR(15 downto 0) := x"1d1e";
  signal rdata2 : STD_LOGIC_VECTOR(7 downto 0);
  signal data2  : STD_LOGIC_VECTOR(7 downto 0);
  signal freq2  : STD_LOGIC_VECTOR(15 downto 0) := x"1150";
  signal waveform : STD_LOGIC_VECTOR(2 downto 1);
  signal gate   : STD_LOGIC_VECTOR(2 downto 1);

  signal at1 : std_logic_vector(3 downto 0) := x"8";
  signal de1 : std_logic_vector(3 downto 0) := x"8";
  signal su1 : std_logic_vector(3 downto 0) := x"d";
  signal re1 : std_logic_vector(3 downto 0) := x"a";

  signal at2 : std_logic_vector(3 downto 0) := x"6";
  signal de2 : std_logic_vector(3 downto 0) := x"3";
  signal su2 : std_logic_vector(3 downto 0) := x"9";
  signal re2 : std_logic_vector(3 downto 0) := x"9";
  
begin
 
  dac1: dac
    port map (audio, data, clk);

  osc1: oscillator
    port map (rdata1, freq1, waveform(1), clk);

  adsr1: envelope
    port map (rdata1, data1, at1, de1, su1, re1, gate(1), clk);

  osc2: oscillator
    port map (rdata2, freq2, waveform(2), clk);

  adsr2: envelope
    port map (rdata2, data2, at2, de2, su2, re2, gate(2), clk);
  
  vol <= switch(7 downto 4) & "0000";
  waveform <= switch (1 downto 0);
  gate <= switch (3 downto 2);
  
  process(clk)
    variable mixed : STD_LOGIC_VECTOR(8 downto 0);
    variable scled : STD_LOGIC_VECTOR(15 downto 0);
  begin
    if rising_edge(clk) then
      mixed := std_logic_vector(unsigned('0' & data1) + unsigned(data2));
      scled := std_logic_vector(unsigned(mixed(8 downto 1)) * unsigned(vol));
      data <= scled(15 downto 8);
    end if;
  end process;

  led <= data;
  
end behavioral;
