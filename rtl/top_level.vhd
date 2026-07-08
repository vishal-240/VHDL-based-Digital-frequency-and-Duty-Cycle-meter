LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY top_level IS
    PORT (
        clk_50M : IN STD_LOGIC;
        ext_reset : IN STD_LOGIC;
        ext_sig : IN STD_LOGIC;

        freq_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        duty_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END top_level;

ARCHITECTURE Structural OF top_level IS

    COMPONENT control_fsm
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            input_edge : IN STD_LOGIC;
            gate_1sec_tick : IN STD_LOGIC;
            cnt_reset : OUT STD_LOGIC;
            cnt_enable : OUT STD_LOGIC;
            latch_enable : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT clock_divider
        GENERIC (
            SYS_CLK_FREQ : INTEGER;
            TARGET_FREQ : INTEGER
        );
        PORT (
            clk_in : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            clk_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT counter_module
        GENERIC (WIDTH : INTEGER);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            count_pulse : IN STD_LOGIC;
            count_out : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Internal routing signals
    SIGNAL sync_sig_1, sync_sig_2, edge_pulse : STD_LOGIC;
    SIGNAL clk_1sec : STD_LOGIC;
    SIGNAL internal_cnt_reset, internal_cnt_enable, internal_latch : STD_LOGIC;

    -- Counter output wires
    SIGNAL raw_freq : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL raw_period : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL raw_high_time : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Latch registers
    SIGNAL freq_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL duty_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN
    -- 1. Input Synchronizer
    PROCESS (clk_50M)
    BEGIN
        IF rising_edge(clk_50M) THEN
            sync_sig_1 <= ext_sig;
            sync_sig_2 <= sync_sig_1;
        END IF;
    END PROCESS;

    -- 2. Edge Detector
    PROCESS (clk_50M)
    BEGIN
        IF rising_edge(clk_50M) THEN
            edge_pulse <= sync_sig_1 AND NOT sync_sig_2;
        END IF;
    END PROCESS;

    -- 3. Module Instantiations
    U_FSM : COMPONENT control_fsm
        PORT MAP(
            clk => clk_50M,
            reset => ext_reset,
            input_edge => edge_pulse,
            gate_1sec_tick => clk_1sec,
            cnt_reset => internal_cnt_reset,
            cnt_enable => internal_cnt_enable,
            latch_enable => internal_latch
        );

    U_CLK_DIV : COMPONENT clock_divider
        GENERIC MAP(
            SYS_CLK_FREQ => 50000000,
            TARGET_FREQ => 1
        )
        PORT MAP(
            clk_in => clk_50M,
            reset => ext_reset,
            clk_out => clk_1sec
        );

    -- Frequency Counter (Counts input edges during the 1-second gate)
    U_FREQ_COUNTER : COMPONENT counter_module
        GENERIC MAP(WIDTH => 32)
        PORT MAP(
            clk => clk_50M,
            reset => internal_cnt_reset,
            enable => internal_cnt_enable,
            count_pulse => edge_pulse,
            count_out => raw_freq
        );

    -- Period Counter (Counts system clock ticks during the measurement window)
    U_PERIOD_COUNTER : COMPONENT counter_module
        GENERIC MAP(WIDTH => 32)
        PORT MAP(
            clk => clk_50M,
            reset => internal_cnt_reset,
            enable => internal_cnt_enable,
            count_pulse => '1', -- Always counts when enabled
            count_out => raw_period
        );

    -- High-Time Counter (Counts system clock ticks ONLY when input is HIGH)
    U_HIGH_TIME_COUNTER : COMPONENT counter_module
        GENERIC MAP(WIDTH => 32)
        PORT MAP(
            clk => clk_50M,
            reset => internal_cnt_reset,
            enable => internal_cnt_enable,
            count_pulse => sync_sig_2, -- Counts only when synchronized input is HIGH
            count_out => raw_high_time
        );

    -- 4. Output Latching and Duty Cycle Calculation Process
    PROCESS (clk_50M)
        VARIABLE period_val : INTEGER;
        VARIABLE high_val : INTEGER;
        VARIABLE duty_calc : INTEGER;
    BEGIN
        IF rising_edge(clk_50M) THEN
            IF internal_latch = '1' THEN
                -- Latch frequency directly
                freq_reg <= raw_freq;

                -- Calculate Duty Cycle percentage safely
                period_val := to_integer(unsigned(raw_period));
                high_val := to_integer(unsigned(raw_high_time));

                IF period_val > 0 THEN
                    duty_calc := (high_val * 100) / period_val;
                    duty_reg <= STD_LOGIC_VECTOR(to_unsigned(duty_calc, 8));
                ELSE
                    duty_reg <= (OTHERS => '0'); -- Prevent divide by zero error
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Assign internal registers to output ports
    freq_out <= freq_reg;
    duty_out <= duty_reg;

END Structural;