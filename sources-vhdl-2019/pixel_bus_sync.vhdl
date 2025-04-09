library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

use work.pixel_bus.all;

entity pixel_bus_sync is
generic(
    PIXEL_BUS_ADDR_WIDTH : integer := 32;
    PIXEL_BUS_DATA_WIDTH : integer := 32;
    PIXEL_BUS_WIDTH  : integer := 1920;
    PIXEL_BUS_HEIGHT : integer := 1080;

    PIXEL_BUS_PIPELINE_STAGES : integer := 0
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    a : in pixel_bus_input( pixel_addr(PIXEL_BUS_ADDR_WIDTH-1 downto 0), pixel_data(PIXEL_BUS_DATA_WIDTH-1 downto 0));
    y : in pixel_bus_output( pixel_addr(PIXEL_BUS_ADDR_WIDTH-1 downto 0), pixel_data(PIXEL_BUS_DATA_WIDTH-1 downto 0))

);

end pixel_bus_sync;

architecture impl of pixel_bus_sync is
begin

    pixel_bus_process: process(mclk) begin
        
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