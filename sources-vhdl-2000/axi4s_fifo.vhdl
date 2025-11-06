library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.custom_stream.all;

entity custom_stream_fifo is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32;
    CUSTOM_STREAM_WIDTH  : integer := 1920;
    CUSTOM_STREAM_HEIGHT : integer := 1080;
    CUSTOM_STREAM_PIPELINE_STAGES : integer := 0;
    INPUT_CLOCK_FREQ : integer := 100000000;
    OUTPUT_CLOCK_FREQ : integer := 100000000
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    sclk : in std_logic := '0';
    srstn : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0'

);

end custom_stream_fifo;

architecture impl of custom_stream_fifo is

    type fifo_vector_type is array (integer range<>) of std_logic_vector(CUSTOM_STREAM_DATA_WIDTH+CUSTOM_STREAM_ADDR_WIDTH-1 downto 0);

    -- the delay between the frames is denoted
    constant FRAME_LENGTH : integer := CUSTOM_STREAM_WIDTH*CUSTOM_STREAM_HEIGHT;
    constant FIFO_LENGTH : integer := 4 + FRAME_LENGTH * OUTPUT_CLOCK_FREQ / INPUT_CLOCK_FREQ;
    signal pixel_fifo : fifo_vector_type(FIFO_LENGTH-1 downto 0) := ( others => ( others => '0' ) );

    signal fifo_head : integer := 1;
    signal fifo_tail : integer := 0;

    signal input_clk : std_logic := '0';
    signal input_clk_last : std_logic := '0';
    signal input_clk_rising_edge : std_logic := '0';

    signal output_clk : std_logic := '0';
    signal output_clk_last : std_logic := '0';
    signal output_clk_rising_edge : std_logic := '0';

begin

    input_clk <= mclk;
    output_clk <= sclk;

    input_cs_clk_process: process(mclk) begin
        if (rising_edge(mclk)) then
            if (mrstn = '0' or srstn = '0') then
                input_clk_last <= '0';
                input_clk_rising_edge <= '0';
                else
                input_clk_last <= input_clk;
                input_clk_rising_edge <= (input_clk xor input_clk_last) and input_clk;
            end if;
        end if;
    end process;

    output_cs_clk_process: process(mclk) begin
        if (rising_edge(mclk)) then
            if (mrstn = '0' or srstn = '0') then
                output_clk_last <= '0';
                output_clk_rising_edge <= '0';
                else
                output_clk_last <= output_clk;
                output_clk_rising_edge <= (output_clk xor output_clk_last) and output_clk;
            end if;
        end if;
    end process;

    head_increment_process: process(mclk)
            variable y_cs_addr_integer : integer := 0;
    begin

        if (rising_edge(mclk)) then
            if (mrstn = '0' or srstn = '0') then
                pixel_fifo <= ( others => ( others => '0' ) );
                fifo_head <= 1;
            else
                if (input_clk_rising_edge = '1' and a_cs_fs = '1') then
                    -- data is encoded as a tuple of addr and data
                    pixel_fifo(fifo_head) <= a_cs_addr & a_cs_data;
        
                    if (fifo_head < FIFO_LENGTH and fifo_head /= (fifo_tail - 1)) then
                        fifo_head <= fifo_head + 1;
                    elsif(fifo_tail /= 0) then
                        fifo_head <= 0;
                    end if;

                end if;

            end if;
        end if;

        if (rising_edge(mclk) and output_clk_rising_edge = '1') then
            if (mrstn = '0' or srstn = '0') then
                y_cs_addr <= ( others => '0' );
                y_cs_data <= ( others => '0' );
                y_cs_fs <= '0';
                fifo_tail <= 0;
                else
                -- data is decoded as a tuple of addr and data
                y_cs_addr_integer := to_integer(unsigned(pixel_fifo(fifo_head)(CUSTOM_STREAM_DATA_WIDTH+CUSTOM_STREAM_ADDR_WIDTH-1 downto CUSTOM_STREAM_DATA_WIDTH)));
                y_cs_addr <= std_logic_vector(to_unsigned(y_cs_addr_integer, y_cs_addr'length));
                y_cs_data <= pixel_fifo(fifo_head)(CUSTOM_STREAM_DATA_WIDTH-1 downto 0);

                -- generate frame sync signal, since the scheme
                if (y_cs_addr_integer > 0 and y_cs_addr_integer < FRAME_LENGTH) then
                    y_cs_fs <= '1';
                else
                    y_cs_fs <= '0';
                end if;

                if (fifo_tail /= (fifo_head - 1) and fifo_tail < FIFO_LENGTH) then
                elsif(fifo_head /= 0) then
                    fifo_tail <= 0;
                end if;
            end if;
        end if;
        
    end process;

end impl;