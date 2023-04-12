-- CNOT gate testbench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Declare the module under test
entity cnot_gate is
end entity;

architecture sim of cnot_gate is

  -- Declare the signals used in the testbench
  signal a : std_logic;
  signal b : std_logic;
  signal output : std_logic;
  
  -- Instantiate the module under test
  component cnot_gate is
    port (
      a : in std_logic;
      b : in std_logic;
      output : out std_logic
    );
  end component;
  
begin

  -- Connect the inputs and outputs to the module under test
  cnot_inst : cnot_gate port map (a => a, b => b, output => output);
  
  -- Apply the test vectors
  process
  begin
    a <= '0';
    b <= '0';
    wait for 10 ns;
    a <= '1';
    b <= '1';
    wait for 10 ns;
    a <= '0';
    b <= '1';
    wait for 10 ns;
    a <= '1';
    b <= '0';
    wait for 10 ns;
    a <= '0';
    b <= '0';
    wait;
  end process;
  
  -- Print the output values
  process (output)
  begin
    if rising_edge(output) then
     report "a=" & std_logic'image(a) & " b=" & std_logic'image(b) & " output=" & std_logic'image(output);
	 end if;
  end process;

end sim;
