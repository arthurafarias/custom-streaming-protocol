library ieee;

use ieee.std_logic_1164.all;

entity custom_stream_mux_2x1 is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    sel : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    b_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    b_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    b_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0'

);

end custom_stream_mux_2x1;

architecture impl of custom_stream_mux_2x1 is
begin


    custom_stream_mux_2x1_process: process(mclk) begin
        if (rising_edge(mclk)) then
            if (mrstn = '0') then
                y_cs_addr <= ( others => '0' );
                y_cs_data <= ( others => '0' );
                y_cs_fs <= '0';
            else
                case(sel) is
                    when '0' =>
                        y_cs_addr <= a_cs_addr;
                        y_cs_data <= a_cs_data;
                        y_cs_fs <= a_cs_fs;
                    when '1' =>
                        y_cs_addr <= b_cs_addr;
                        y_cs_data <= b_cs_data;
                        y_cs_fs <= b_cs_fs;
                    when others =>
                end case;
            end if;
        end if;
    end process;

end impl;