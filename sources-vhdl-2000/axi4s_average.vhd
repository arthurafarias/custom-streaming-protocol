library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity custom_stream_average is
generic(

    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32;
    
    FRAME_LENGTH : integer := 4096;
    SAMPLES : integer := 10
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0'

);

end custom_stream_average;

architecture impl of custom_stream_average is

type memory_type is array(integer range<>) of std_logic_vector(CUSTOM_STREAM_DATA_WIDTH-1 downto 0);
signal memory : memory_type(FRAME_LENGTH downto 0) := ( others => ( others => '0' ));
signal memory_value : signed(CUSTOM_STREAM_DATA_WIDTH-1 downto 0);

signal a_cs_addr_d0 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH-1 downto 0);
signal a_cs_fs_d0 : std_logic := '0';

begin

    custom_stream_process: process(mclk) begin
        
        if (rising_edge(mclk)) then
            if (mrstn = '0') then
                y_cs_addr <= (others => '0');
                y_cs_data <= (others => '0');
                y_cs_fs <= '0';
                memory <= ( others => ( others => '0' ));
                memory_value <= ( others => '0' );
            else
                a_cs_fs_d0 <= a_cs_fs;
                y_cs_fs <= a_cs_fs_d0;
                
                a_cs_addr_d0 <= a_cs_addr;
                y_cs_addr <= a_cs_addr_d0;
                
                memory_value <= signed(memory(to_integer(unsigned(a_cs_addr))));
                y_cs_data <= std_logic_vector(memory_value + (signed(a_cs_data) - memory_value) / SAMPLES);
            end if;
        end if;

    end process;

end impl;