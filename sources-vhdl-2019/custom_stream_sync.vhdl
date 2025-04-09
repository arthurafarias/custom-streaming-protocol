library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

use work.custom_stream.all;

entity custom_stream_sync is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32;
    CUSTOM_STREAM_WIDTH  : integer := 1920;
    CUSTOM_STREAM_HEIGHT : integer := 1080;

    CUSTOM_STREAM_PIPELINE_STAGES : integer := 0
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    a : in custom_stream_input( pixel_addr(CUSTOM_STREAM_ADDR_WIDTH-1 downto 0), pixel_data(CUSTOM_STREAM_DATA_WIDTH-1 downto 0));
    y : in custom_stream_output( pixel_addr(CUSTOM_STREAM_ADDR_WIDTH-1 downto 0), pixel_data(CUSTOM_STREAM_DATA_WIDTH-1 downto 0))

);

end custom_stream_sync;

architecture impl of custom_stream_sync is
begin

    custom_stream_process: process(mclk) begin
        
        if (rising_edge(mclk)) then
            if (mrstn = '0') then
                y.pixel_clk <= '0';
                y.pixel_addr <= (others => '0');
                y.pixel_data <= (others => '0');
                y.pixel_fs <= '0';
            else
                y <= a;
            end if;
        end if;

    end process;

end impl;