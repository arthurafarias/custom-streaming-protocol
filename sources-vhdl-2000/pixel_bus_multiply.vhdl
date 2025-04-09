library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity pixel_bus_multiply is
generic(
    PIXEL_BUS_ADDR_WIDTH : integer := 32;
    PIXEL_BUS_DATA_WIDTH : integer := 32;
    PIXEL_BUS_WIDTH  : integer := 1920;
    PIXEL_BUS_HEIGHT : integer := 1080;
    PIPELINE_LENGTH : integer := 4
);

port(

    -- clock downsampling will be fucked up without an ack ;)
    
    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    value : in std_logic_vector(PIXEL_BUS_DATA_WIDTH-1 downto 0) := ( others => '0');

    a_pixel_clk : in std_logic := '0';
    a_pixel_addr : in std_logic_vector(PIXEL_BUS_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_pixel_data : in std_logic_vector(PIXEL_BUS_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_pixel_fs : in std_logic := '0';

    y_pixel_clk : out std_logic := '0';
    y_pixel_addr : out std_logic_vector(PIXEL_BUS_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_pixel_data : out std_logic_vector(PIXEL_BUS_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_pixel_fs : out std_logic := '0'
);

end pixel_bus_multiply;

architecture impl of pixel_bus_multiply is

    type pixel_addr_pipeline_vector_type is array (integer range<>) of std_logic_vector(PIXEL_BUS_ADDR_WIDTH-1 downto 0);
    type pixel_data_pipeline_vector_type is array (integer range<>) of std_logic_vector(PIXEL_BUS_DATA_WIDTH-1 downto 0);

    signal pixel_addr_pipeline : pixel_addr_pipeline_vector_type(PIPELINE_LENGTH-1 downto 0) := ( others => ( others => '0' ) );
    signal pixel_data_pipeline : pixel_data_pipeline_vector_type(PIPELINE_LENGTH-1 downto 0) := ( others => ( others => '0' ) );
    signal pixel_fs_pipeline : std_logic_vector(PIPELINE_LENGTH-1 downto 0) := (others => '0');
    signal multiplication : std_logic_vector(2*PIXEL_BUS_DATA_WIDTH-1 downto 0) := (others => '0');

begin

    pixel_bus_multiply_process: process(mclk)
        variable result : integer := 0;
        begin
        if (rising_edge(mclk)) then
            if (mrstn = '0') then
                y_pixel_clk <= '0';
                y_pixel_addr <= ( others => '0' );
                y_pixel_data <= ( others => '0' );
                y_pixel_fs <= '0';
            else
                y_pixel_clk <= a_pixel_clk;
                y_pixel_fs <= pixel_fs_pipeline(pixel_fs_pipeline'length-1);
                y_pixel_addr <= pixel_addr_pipeline(pixel_addr_pipeline'length - 1);
                y_pixel_data <= pixel_data_pipeline(pixel_data_pipeline'length - 1);

                result := to_integer(unsigned(a_pixel_data)) * to_integer(unsigned(value));
                multiplication <= std_logic_vector(to_unsigned(result, multiplication'length));
                pixel_data_pipeline(0) <= multiplication(pixel_data_pipeline(0)'length - 1 downto 0);

                for i in 1 to PIPELINE_LENGTH-1 loop
                    pixel_data_pipeline(i) <= pixel_data_pipeline(i-1);
                end loop;
            end if;
        end if;
    end process;

end impl;