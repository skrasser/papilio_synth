library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity envelope is
  port (data_in  : in  STD_LOGIC_VECTOR(7 downto 0);
        data_out : out STD_LOGIC_VECTOR(7 downto 0);
        attack   : in  STD_LOGIC_VECTOR(3 downto 0);  -- attack rate
        delay    : in  STD_LOGIC_VECTOR(3 downto 0);  -- delay rate
        sustain  : in  STD_LOGIC_VECTOR(3 downto 0);  -- sustain level
        release  : in  STD_LOGIC_VECTOR(3 downto 0);  -- release rate
        gate     : in  STD_LOGIC;
        clk      : in  STD_LOGIC
       );
end envelope;

architecture behavioral of envelope is
begin
  
  process(clk)
    constant state_idle    : std_logic_vector(2 downto 0) := "000";
    constant state_attack  : std_logic_vector(2 downto 0) := "001";
    constant state_delay   : std_logic_vector(2 downto 0) := "010";
    constant state_sustain : std_logic_vector(2 downto 0) := "011";
    constant state_release : std_logic_vector(2 downto 0) := "100";
    variable state   : std_logic_vector(2 downto 0) := state_idle;
    variable sum     : unsigned(22 downto 0) := (others => '0');
    variable rate    : unsigned(3 downto 0);
    variable vol     : unsigned(7 downto 0) := (others => '0');
    variable datamod : unsigned(15 downto 0);
    function trigger(asum : unsigned(22 downto 0);
                     arate : unsigned(3 downto 0)
                    ) return boolean is
    begin
      -- bit 7 is set after 1.024 msec
      if asum(to_integer(arate) + 7) = '1' then
        return true;
      else
        return false;
      end if;
    end trigger;
  begin
    if rising_edge(clk) then
      case state is
        when state_idle =>
          vol := (others => '0');
          sum := (others => '0');
          if gate = '1' then
            state := state_attack;
          end if;
        when state_attack =>
          sum := sum + 1;
          if trigger(sum, unsigned(attack)) then
            sum := (others => '0');
            vol := vol + 1;
            -- if up to maximum volume, then switch to delay state
            if vol = 255 then
              state := state_delay;
            end if;
          end if;
        when state_delay =>
          sum := sum + 1;
          if trigger(sum, unsigned(delay)) then
            sum := (others => '0');
            vol := vol - 1;
            if vol = unsigned(sustain & "0000") then
              state := state_sustain;
            end if;
          end if;
        when state_sustain =>
          -- stay in this state as long as the gate is active
          if gate = '0' then
            state := state_release;
            -- need to reset sum since this did not occur on trigger
            sum := (others => '0');
          end if;
        when state_release =>
          sum := sum + 1;
          if gate = '1' then
            -- new note played, go through idle state for setup
            state := state_idle;
          elsif trigger(sum, unsigned(release)) then
            sum := (others => '0');
            vol := vol - 1;
            if vol = 0 then
              state := state_idle;
            end if;
          end if;
        when others =>
          state := state_idle;
      end case;
      -- apply volume to incoming data
      datamod := unsigned(data_in) * vol;
      data_out <= std_logic_vector(datamod(15 downto 8));
    end if;
  end process;    

end behavioral;
