library ieee;

use ieee.std_logic_1164.all;

entity pixel_bus_split is
generic(
    PIXEL_BUS_ADDR_WIDTH : integer := 32;
    PIXEL_BUS_DATA_WIDTH : integer := 32;
    PIXEL_BUS_WIDTH  : integer := 1920;
    PIXEL_BUS_HEIGHT : integer := 1080
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    y_pixel_clk : in std_logic := '0';
    y_pixel_addr : in std_logic_vector(PIXEL_BUS_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_pixel_data : in std_logic_vector(PIXEL_BUS_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_pixel_fs : in std_logic := '0';

    a_pixel_clk : out std_logic := '0';
    a_pixel_addr : out std_logic_vector(PIXEL_BUS_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_pixel_data : out std_logic_vector(PIXEL_BUS_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_pixel_fs : out std_logic := '0';

    b_pixel_clk : out std_logic := '0';
    b_pixel_addr : out std_logic_vector(PIXEL_BUS_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    b_pixel_data : out std_logic_vector(PIXEL_BUS_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    b_pixel_fs : out std_logic := '0'

);

end pixel_bus_split;

architecture impl of pixel_bus_split is
begin

    pixel_bus_split: process(mclk) begin
        if (rising_edge(mclk)) then
            if (mrstn = '0') then

                a_pixel_clk <= '0';
                a_pixel_addr <= ( others => '0' );
                a_pixel_data <= ( others => '0' );
                a_pixel_fs <= '0';

                b_pixel_clk <= '0';
                b_pixel_addr <= ( others => '0' );
                b_pixel_data <= ( others => '0' );
                b_pixel_fs <= '0';

            else

                a_pixel_clk <= y_pixel_clk;
                a_pixel_addr <= y_pixel_addr;
                a_pixel_data <= y_pixel_data;
                a_pixel_fs <= y_pixel_fs;

                b_pixel_clk <= y_pixel_clk;
                b_pixel_addr <= y_pixel_addr;
                b_pixel_data <= y_pixel_data;
                b_pixel_fs <= y_pixel_fs;
                
            end if;
        end if;
    end process;

end impl;