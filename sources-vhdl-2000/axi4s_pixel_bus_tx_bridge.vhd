library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use work.custom_stream.all;

entity custom_stream_adv7613_tx is
generic
(
    CUSTOM_STREAM_INPUT_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_INPUT_DATA_WIDTH : integer := 24;
    CUSTOM_STREAM_DATA_SIGNED : boolean := true;
    
    FRAME_WIDTH : integer := 320;
    FRAME_HEIGHT : integer := 240;
    
    FRAME_TOP_PORCH_COUNT : integer := 1;
    FRAME_FRONT_PORCH_COUNT : integer := 1;
    FRAME_BACK_PORCH_COUNT : integer := 1;
    FRAME_BOTTOM_PORCH_COUNT : integer := 1
    
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_INPUT_ADDR_WIDTH-1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_INPUT_DATA_WIDTH-1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    pb_clk : out std_logic := '0';
    pb_de : out std_logic := '0';
    pb_vsync : out std_logic := '0';
    pb_hsync : out std_logic := '0';
    pb_d : out std_logic_vector(CUSTOM_STREAM_INPUT_DATA_WIDTH-1 downto 0) := ( others => '0' )
    

);

end custom_stream_adv7613_tx;

architecture impl of custom_stream_adv7613_tx is

constant columns : integer := 0;
constant rows : integer := 0;

signal idx : unsigned(a_cs_addr'length-1 downto 0) := ( others => '0' );
signal row : unsigned(a_cs_addr'length-1 downto 0) := ( others => '0' );
signal col : unsigned(a_cs_addr'length-1 downto 0) := ( others => '0' );

begin

    pb_clk <= mclk;
    
    process(mclk)
    begin
    if (rising_edge(mclk)) then
        if (mrstn = '0') then
            pb_clk <= '0';
            pb_de <= '0';
            pb_vsync <= '0';
            pb_hsync <= '0';
            pb_d <= ( others => '0' );
        else
        
        idx <= shift_right(unsigned(a_cs_addr), to_integer(unsigned(a_cs_addr)) / 8);
        col <= idx mod columns;
        row <= idx / columns;
        
        if (a_cs_fs = '1') then
        
            pb_de <= '1';
            pb_d <= a_cs_data;
            
            if ((col >= FRAME_FRONT_PORCH_COUNT) and (col <= FRAME_BACK_PORCH_COUNT)) then
                pb_vsync <= '1';
            else
                pb_vsync <= '0';
            end if; 
            
            if ((row >= FRAME_TOP_PORCH_COUNT) and (row <= FRAME_BOTTOM_PORCH_COUNT)) then
                pb_hsync <= '1';
            else
                pb_hsync <= '0';
            end if;
            
        end if;
            
        end if;
    end if;
    
    end process;

end impl;