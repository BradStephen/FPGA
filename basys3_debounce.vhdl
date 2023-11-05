library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer is
    Port (
        clk : in STD_LOGIC;                  -- System clock
        btn_in : in STD_LOGIC;               -- Button input
        btn_out : out STD_LOGIC;             -- Debounced button output
        debounce_out : out STD_LOGIC         -- Signal to observe on oscilloscope
    );
end Debouncer;

architecture Behavioral of Debouncer is
    -- Constants
    constant DEBOUNCE_TIME : natural := 500000; -- Number of clock cycles for debounce, adjust according to clk frequency and required debounce time
    -- Signals
    signal btn_state : STD_LOGIC := '0';           -- Internal state of the button
    signal counter : UNSIGNED(19 downto 0) := (others => '0'); -- 20-bit counter for simplicity
begin

    -- Debouncing process
    Debounce_Process: process(clk)
    begin
        if rising_edge(clk) then
            -- Check if button state is stable
            if btn_in = btn_state then
                -- Reset counter when the input matches the stable state
                counter <= (others => '0');
            else
                -- Increment counter when the input doesn't match the stable state
                if counter < DEBOUNCE_TIME then
                    counter <= counter + 1;
                else
                    -- Update the stable state when the input has been different for long enough
                    btn_state <= btn_in;
                end if;
            end if;
        end if;
    end process;

    -- Output the stable state of the button
    btn_out <= btn_state;

    -- This signal can be observed on an oscilloscope to see the effect of debouncing
    debounce_out <= btn_in when counter < DEBOUNCE_TIME else btn_state;

end Behavioral;