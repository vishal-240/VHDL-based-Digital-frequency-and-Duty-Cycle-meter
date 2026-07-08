LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_top_level IS
END tb_top_level;

ARCHITECTURE sim OF tb_top_level IS

    COMPONENT top_level
        PORT (
            clk_50M : IN STD_LOGIC;
            ext_reset : IN STD_LOGIC;
            ext_sig : IN STD_LOGIC;
            freq_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            duty_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL tb_clk : STD_LOGIC := '0';
    SIGNAL tb_reset : STD_LOGIC := '1';
    SIGNAL tb_ext_sig : STD_LOGIC := '0';
    SIGNAL tb_freq_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL tb_duty_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    CONSTANT CLK_PERIOD : TIME := 20 ns; -- 50 MHz clock

BEGIN

    UUT : top_level PORT MAP(
        clk_50M => tb_clk,
        ext_reset => tb_reset,
        ext_sig => tb_ext_sig,
        freq_out => tb_freq_out,
        duty_out => tb_duty_out
    );

    -- Clock generator
    clk_process : PROCESS
    BEGIN
        tb_clk <= '0';
        WAIT FOR CLK_PERIOD/2;
        tb_clk <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;

    -- Stimulus generator
    stim_process : PROCESS
    BEGIN
        WAIT FOR 100 ns;
        tb_reset <= '0';
        WAIT FOR 100 ns;

        -- Generate a 1 kHz signal with a 25% duty cycle
        -- We will let it run long enough for the 1-second gate to open and close
        -- WARNING: Simulating 1 full second at 50MHz takes real computing time. 
        -- To test quickly, you can temporarily change TARGET_FREQ in top_level to 1000 (1ms gate).
        FOR i IN 1 TO 2000 LOOP
            tb_ext_sig <= '1';
            WAIT FOR 0.25 ms;
            tb_ext_sig <= '0';
            WAIT FOR 0.75 ms;
        END LOOP;

        WAIT FOR 2 ms;
        ASSERT FALSE REPORT "Simulation Finished Successfully" SEVERITY failure;
    END PROCESS;

END sim;