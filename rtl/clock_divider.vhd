LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY clock_divider IS
    GENERIC (
        SYS_CLK_FREQ : INTEGER := 50000000;
        TARGET_FREQ : INTEGER := 1
    );
    PORT (
        clk_in : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        clk_out : OUT STD_LOGIC
    );
END clock_divider;

ARCHITECTURE Behavioral OF clock_divider IS
    SIGNAL counter : INTEGER := 0;
    SIGNAL clk_out_reg : STD_LOGIC := '0';
BEGIN
    PROCESS (clk_in, reset)
    BEGIN
        IF reset = '1' THEN
            counter <= 0;
            clk_out_reg <= '0';
        ELSIF rising_edge(clk_in) THEN
            counter <= counter + 1;
            -- Divide by 2 because we toggle to create a 50% duty cycle clock
            IF counter >= (SYS_CLK_FREQ / (TARGET_FREQ)) - 1 THEN
                counter <= 0;
                clk_out_reg <= NOT clk_out_reg;
            END IF;
        END IF;
    END PROCESS;

    clk_out <= clk_out_reg;
END Behavioral;