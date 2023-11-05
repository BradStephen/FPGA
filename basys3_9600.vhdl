library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Tx is
    Port (
        clk : in STD_LOGIC;               -- System clock
        btn : in STD_LOGIC;               -- Button input
        tx : out STD_LOGIC;               -- UART transmit line
        led : out STD_LOGIC_VECTOR (3 downto 0)  -- LEDs for debugging
    );
end UART_Tx;

architecture Behavioral of UART_Tx is
    signal tx_start : STD_LOGIC := '0';
    signal tx_idle : STD_LOGIC := '1';
    signal tx_bit : STD_LOGIC_VECTOR(9 downto 0) := "1111111111"; -- Start bit, data bits (LSB first), stop bit
    signal clk_count : INTEGER := 0;
    signal btn_reg : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- For debouncing
    signal btn_edge : STD_LOGIC := '0'; -- Edge detector for button press
    constant CLOCK_DIVIDER : INTEGER := 10417; -- Adjust this for your baud rate
    constant DATA_BYTE : STD_LOGIC_VECTOR(7 downto 0) := "10101010"; -- Data to transmit (0xAA)
begin

    -- Button debouncing and edge detection
    process(clk)
    begin
        if rising_edge(clk) then
            btn_reg <= btn_reg(0) & btn;
            if btn_reg = "01" then
                btn_edge <= '1';
            else
                btn_edge <= '0';
            end if;
        end if;
    end process;

    -- UART transmission process
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_edge = '1' then
                -- Load the transmit register with start bit, data byte, and stop bit
                tx_bit <= '0' & DATA_BYTE & '1';
                tx_idle <= '0';
                tx_start <= '1';
            elsif tx_start = '1' then
                if clk_count < CLOCK_DIVIDER - 1 then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    -- Shift out the bits
                    if tx_bit /= "1111111111" then
                        tx <= tx_bit(0);
                        tx_bit <= '1' & tx_bit(9 downto 1);
                    else
                        tx_idle <= '1';
                        tx_start <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Assign the tx output to the tx signal
    tx <= '1' when tx_idle = '1' else tx_bit(0);

    -- Assign LEDs to the state of the transmission for visual debugging
    led(0) <= not tx_idle;
    led(1) <= tx;
    led(2) <= btn_edge;
    led(3) <= '0'; -- Unused
end Behavioral;
