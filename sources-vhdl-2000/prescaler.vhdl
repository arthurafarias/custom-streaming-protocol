library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.custom_stream.all;

entity prescaler is
generic(
    INPUT_CLK_FREQ_HZ : integer := 100000000;
    PRESCALER_LENGTH : integer := 32
);

port(
    rstn : in std_logic := '0';
    clkin : in std_logic := '0';
    clkout : out std_logic := '0';
    count_max : in unsigned(PRESCALER_LENGTH-1 downto 0) := ( others => '0' );
    count_threshold : in unsigned(PRESCALER_LENGTH-1 downto 0) := ( others => '0' )
);

end prescaler;

architecture impl of prescaler is
    signal count : unsigned(PRESCALER_LENGTH-1 downto 0) := ( others => '0' );
begin

    prescaler_process: process(clkin) begin
        if (rising_edge(clkin)) then
            
            if (rstn = '0') then
                count <= ( others => '0' );
                clkout <= '0';
            else
                if (count < count_max) then
                    count <= count + 1;
                    if (count < count_threshold) then
                        clkout <= '0';
                    else
                        clkout <= '1';
                    end if;
                else
                    clkout <= '0';
                    count <= to_unsigned(0, PRESCALER_LENGTH);
                end if;
            end if;
        end if;

    end process;

end impl;
