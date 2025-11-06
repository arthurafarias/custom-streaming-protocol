library ieee;

use ieee.std_logic_1164.all;

entity custom_stream_split is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    y_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : in std_logic := '0';

    a_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : out std_logic := '0';

    b_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    b_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    b_cs_fs : out std_logic := '0'

);

end custom_stream_split;

architecture impl of custom_stream_split is
begin

    custom_stream_split_process: process(mclk) begin
        if (rising_edge(mclk)) then
            if (mrstn = '0') then

                a_cs_addr <= ( others => '0' );
                a_cs_data <= ( others => '0' );
                a_cs_fs <= '0';
                
                b_cs_addr <= ( others => '0' );
                b_cs_data <= ( others => '0' );
                b_cs_fs <= '0';

            else

                a_cs_addr <= y_cs_addr;
                a_cs_data <= y_cs_data;
                a_cs_fs <= y_cs_fs;

                b_cs_addr <= y_cs_addr;
                b_cs_data <= y_cs_data;
                b_cs_fs <= y_cs_fs;
                
            end if;
        end if;
    end process;

end impl;