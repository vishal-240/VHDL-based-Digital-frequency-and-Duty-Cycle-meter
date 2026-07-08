LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control_fsm IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        input_edge : IN STD_LOGIC;
        gate_1sec_tick : IN STD_LOGIC;

        cnt_reset : OUT STD_LOGIC;
        cnt_enable : OUT STD_LOGIC;
        latch_enable : OUT STD_LOGIC
    );
END control_fsm;

ARCHITECTURE Behavioral OF control_fsm IS
    TYPE fsm_state IS (IDLE, WAIT_EDGE, MEASURE, CAPTURE, HOLD);
    SIGNAL state : fsm_state := IDLE;
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                state <= IDLE;
                cnt_reset <= '1';
                cnt_enable <= '0';
                latch_enable <= '0';
            ELSE
                CASE state IS
                    WHEN IDLE =>
                        cnt_reset <= '1';
                        cnt_enable <= '0';
                        latch_enable <= '0';
                        IF input_edge = '1' THEN
                            state <= WAIT_EDGE;
                        END IF;

                    WHEN WAIT_EDGE =>
                        cnt_reset <= '0';
                        cnt_enable <= '0';
                        latch_enable <= '0';
                        -- Wait for the 1-second gate to transition HIGH
                        IF gate_1sec_tick = '1' THEN
                            state <= MEASURE;
                        END IF;

                    WHEN MEASURE =>
                        cnt_reset <= '0';
                        cnt_enable <= '1';
                        latch_enable <= '0';
                        -- Wait for the 1-second gate to finish
                        IF gate_1sec_tick = '0' THEN
                            state <= CAPTURE;
                        END IF;

                    WHEN CAPTURE =>
                        cnt_reset <= '0';
                        cnt_enable <= '0';
                        latch_enable <= '1';
                        state <= HOLD;

                    WHEN HOLD =>
                        cnt_reset <= '0';
                        cnt_enable <= '0';
                        latch_enable <= '0';
                        -- Wait for a new 1-second gate tick to begin a new measurement cycle
                        IF gate_1sec_tick = '1' THEN
                            state <= IDLE;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;