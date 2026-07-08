LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY counter_module IS
    GENERIC (WIDTH : INTEGER := 32);
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        count_pulse : IN STD_LOGIC; -- Set to '1' for continuous counting when enabled
        count_out : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END counter_module;

ARCHITECTURE Behavioral OF counter_module IS
    SIGNAL count_reg : unsigned(WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                count_reg <= (OTHERS => '0');
            ELSIF enable = '1' AND count_pulse = '1' THEN
                count_reg <= count_reg + 1;
            END IF;
        END IF;
    END PROCESS;
    count_out <= STD_LOGIC_VECTOR(count_reg);
END Behavioral;