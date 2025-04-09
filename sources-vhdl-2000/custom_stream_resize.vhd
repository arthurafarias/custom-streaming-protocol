library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use work.custom_stream.all;

entity custom_stream_resize is
generic
(
    CUSTOM_STREAM_INPUT_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_INPUT_DATA_WIDTH : integer := 32;
    CUSTOM_STREAM_OUTPUT_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_OUTPUT_DATA_WIDTH : integer := 16;
    CUSTOM_STREAM_DATA_SIGNED : boolean := true
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_INPUT_ADDR_WIDTH-1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_INPUT_DATA_WIDTH-1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_OUTPUT_ADDR_WIDTH-1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(CUSTOM_STREAM_OUTPUT_DATA_WIDTH-1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0'

);

end custom_stream_resize;

architecture impl of custom_stream_resize is
begin
    process(mclk)
    begin
    if (rising_edge(mclk)) then
        if (mrstn = '0') then
            y_cs_addr <= ( others => '0' );
            y_cs_data <= ( others => '0' );
        else
            y_cs_addr <= std_logic_vector(resize(unsigned(a_cs_addr), y_cs_addr'length));
            
            if (CUSTOM_STREAM_DATA_SIGNED) then
                y_cs_data <= std_logic_vector(resize(signed(a_cs_data), y_cs_addr'length));
            else
                y_cs_data <= std_logic_vector(resize(unsigned(a_cs_data), y_cs_addr'length));
            end if;
            
            y_cs_fs <= a_cs_fs;
        end if;
    end if;
    end process;

end impl;