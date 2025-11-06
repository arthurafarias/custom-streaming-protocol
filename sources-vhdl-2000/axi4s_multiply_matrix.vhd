library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity custom_stream_multiply_matrix is
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

    bypass : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0';

    -- user ports ends
    -- do not modify the ports beyond this line
    multiply_bram_clk : out std_logic := '0';
    multiply_bram_rst : out std_logic := '0';
    multiply_bram_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_din : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_dout : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_en : out std_logic := '0';
    multiply_bram_we : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH/8 - 1 downto 0) := ( others => '0' )

);

end custom_stream_multiply_matrix;

architecture impl of custom_stream_multiply_matrix is

    ATTRIBUTE X_INTERFACE_INFO : STRING;
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_clk: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port CLK";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_addr: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port ADDR";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_din: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port DIN";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_dout: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port DOUT";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_en: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port EN";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_rst: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port RST";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_we: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port WE";

    signal a_cs_addr_d0 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_addr_d1 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_data_d0 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_data_d1 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_fs_d0 : std_logic := '0';
    signal a_cs_fs_d1 : std_logic := '0';
    
    signal result : signed(CUSTOM_STREAM_DATA_WIDTH*2 - 1 downto 0) := ( others => '0');
    
    signal col : unsigned(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    signal row : unsigned(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' ); 
    signal index : unsigned(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    signal index_d0 : unsigned(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
begin

    multiply_bram_clk <= mclk;    
    multiply_bram_rst <= '0';
    multiply_bram_en <= '1';
    multiply_bram_we <= ( others => '0' );
    multiply_bram_addr <= std_logic_vector(index);

	process(mclk)
	   
	begin

		if (rising_edge(mclk)) then
			if (mrstn = '0') then
                y_cs_data <= ( others => '0' );
                y_cs_addr <= ( others => '0' );
                y_cs_fs <= '0';
                result <= to_signed(0, result'length);
                
			else
			    -- solve index
                row <= unsigned(a_cs_addr) / CUSTOM_STREAM_WIDTH;
                col <= unsigned(a_cs_addr) - (row * CUSTOM_STREAM_WIDTH);
                index <= col * CUSTOM_STREAM_WIDTH + row;
                index_d0 <= index;
                
                 -- data pipeline
			     a_cs_data_d0 <= a_cs_data;
			     a_cs_data_d1 <= a_cs_data_d0;
			     
			     -- sync pipeline
			     a_cs_fs_d0 <= a_cs_fs;
			     a_cs_fs_d1 <= a_cs_fs_d0;
			     y_cs_fs <= a_cs_fs_d1;
			     
			     result <= signed(a_cs_data_d1) * signed(multiply_bram_dout) + result;
			     
			end if;
		end if;
	end process;

end impl;