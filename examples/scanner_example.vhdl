library ieee;
use ieee.std_logic_1164.all;


entity scanner_example is
    port (
            clk      : in std_logic;
            rst      : in std_logic;
            ps2_clk  : in std_logic;
            ps2_data : in std_logic;
            led_out  : out std_logic;
            led_out2 : out std_logic;
            led_out3 : out std_logic;
            led_out4 : out std_logic
        );
end scanner_example;

architecture rtl of scanner_example is



    -- PS2 Scanner Signals
    signal scanner_data : std_logic_vector(7 downto 0);
    signal scanner_rx_done : std_logic;

    -- Components
    component ps2_scanner
        port(clk       : in std_logic;
             rst       : in std_logic;
             ps2_clk   : in std_logic;
             ps2_data  : in std_logic;
             rx_done   : out std_logic;
             rx_data_o : out std_logic_vector(7 downto 0));
    end component;
begin

    -- PS2 Scanner
    SCANNER: ps2_scanner
        port map ( clk => clk,
                   rst => rst,
                   ps2_clk => ps2_clk,
                   ps2_data => ps2_data,
                   rx_done => scanner_rx_done,
                   rx_data_o => scanner_data );
    
    process(clk, rst)
    begin
        if rst = '1' then
            led_out <= '0';
            led_out2 <= '0';
            led_out3 <= '0';
            led_out4 <= '0';
        elsif rising_edge(clk) then
        
            if scanner_rx_done = '1' then
                led_out4 <= '1';
                case scanner_data is
                    when x"AA" =>
                        led_out <= '1';
                    when x"72" =>
                        led_out2 <= '0';
                    when x"75" =>
                        led_out2 <= '1';
                    when x"1C" =>
                        led_out3 <= '1';
                    when x"1B" =>
                        led_out3 <= '0';
                    when others =>
                end case;
            else
                led_out4 <= '0';
            end if;

        end if;
    end process;


    --led_out <= '1' when (scanner_rx_done = '1' and scanner_data = x"1C") else '0';

end rtl;
