library ieee;

use ieee.std_logic_1164.all;

entity custom_stream_sync is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32;
    ADDR_DELAY_CYCLES : integer := 1;
    DATA_DELAY_CYCLES : integer := 1;
    FS_DELAY_CYCLES : integer := 1
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

end custom_stream_sync;

architecture impl of custom_stream_sync is

    type addr_pipeline_type is array(integer range<>) of std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH-1 downto 0);
    type data_pipeline_type is array(integer range<>) of std_logic_vector(CUSTOM_STREAM_DATA_WIDTH-1 downto 0);
    type fs_pipeline_type is array(integer range<>) of std_logic;

    signal addr_pipeline : addr_pipeline_type(0 to ADDR_DELAY_CYCLES - 1) := ( others => ( others => '0' ) );
    signal data_pipeline : data_pipeline_type(0 to DATA_DELAY_CYCLES - 1) := ( others => ( others => '0' ) );
    signal fs_pipeline : fs_pipeline_type(0 to FS_DELAY_CYCLES - 1) := ( others => '0' );

begin

    custom_stream_process: process(mclk) begin
        
        if (rising_edge(mclk)) then
            if (mrstn = '0') then
                y_cs_addr <= (others => '0');
                y_cs_data <= (others => '0');
                y_cs_fs <= '0';

                addr_pipeline <= ( others => (others => '0' ) );
                data_pipeline <= ( others => (others => '0' ) );
                fs_pipeline <= ( others => '0' );
                
            else

                addr_pipeline(0) <= a_cs_addr;
                data_pipeline(0) <= y_cs_data;
                fs_pipeline(0) <= y_cs_fs;

                y_cs_addr <= addr_pipeline(ADDR_DELAY_CYCLES-1);
                y_cs_data <= data_pipeline(DATA_DELAY_CYCLES-1);
                y_cs_fs <= fs_pipeline(FS_DELAY_CYCLES-1);
            
                for i in 1 to ADDR_DELAY_CYCLES-1 loop
                    addr_pipeline(i) <= addr_pipeline(i-1);
                end loop;

                for i in 1 to DATA_DELAY_CYCLES-1 loop
                    data_pipeline(i) <= data_pipeline(i-1);
                end loop;

                for i in 1 to FS_DELAY_CYCLES-1 loop
                    fs_pipeline(i) <= fs_pipeline(i-1);
                end loop;

            end if;
        end if;

    end process;

end impl;