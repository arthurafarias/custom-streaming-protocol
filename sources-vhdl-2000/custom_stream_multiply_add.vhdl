library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity custom_stream_multiply_add is
generic(
    CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
    CUSTOM_STREAM_DATA_WIDTH : integer := 32;
    CUSTOM_STREAM_SCALE_FACTOR : integer := 14
);

port(

    mclk : in std_logic := '0';
    mrstn : in std_logic := '0';

    bypass : in std_logic := '0';

    a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    a_cs_fs : in std_logic := '0';

    y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_data : out std_logic_vector(2*CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    y_cs_fs : out std_logic := '0';

    -- user ports ends
    -- do not modify the ports beyond this line
    multiply_bram_clk : out std_logic := '0';
    multiply_bram_rst : out std_logic := '0';
    multiply_bram_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_din : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_dout : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    multiply_bram_en : out std_logic := '0';
    multiply_bram_we : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH/8 - 1 downto 0) := ( others => '0' );

    -- user ports ends
    -- do not modify the ports beyond this line
    add_bram_clk : out std_logic := '0';
    add_bram_rst : out std_logic := '0';
    add_bram_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
    add_bram_din : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    add_bram_dout : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    add_bram_en : out std_logic := '0';
    add_bram_we : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH/8 - 1 downto 0) := ( others => '0' )

);

end custom_stream_multiply_add;

architecture impl of custom_stream_multiply_add is

    ATTRIBUTE X_INTERFACE_INFO : STRING;
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_clk: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port CLK";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_addr: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port ADDR";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_din: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port DIN";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_dout: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port DOUT";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_en: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port EN";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_rst: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port RST";
	ATTRIBUTE X_INTERFACE_INFO of multiply_bram_we: signal is "xilinx.com:interface:bram:1.0 multiply_bram_port WE";
	
	ATTRIBUTE X_INTERFACE_INFO of add_bram_clk: signal is "xilinx.com:interface:bram:1.0 add_bram_port CLK";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_addr: signal is "xilinx.com:interface:bram:1.0 add_bram_port ADDR";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_din: signal is "xilinx.com:interface:bram:1.0 add_bram_port DIN";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_dout: signal is "xilinx.com:interface:bram:1.0 add_bram_port DOUT";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_en: signal is "xilinx.com:interface:bram:1.0 add_bram_port EN";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_rst: signal is "xilinx.com:interface:bram:1.0 add_bram_port RST";
	ATTRIBUTE X_INTERFACE_INFO of add_bram_we: signal is "xilinx.com:interface:bram:1.0 add_bram_port WE";

    signal a_cs_addr_d0 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_addr_d1 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_data_d0 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_data_d1 : std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
    signal a_cs_fs_d0 : std_logic := '0';
    signal a_cs_fs_d1 : std_logic := '0';
    
    signal result : signed(2*CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0');

begin

    -- no difference in signal propagation a fifo should be used to be clocked accordingly.

    add_bram_clk <= mclk;
    add_bram_rst <= '0';
    add_bram_en <= '1';
    add_bram_we <= ( others => '0' );
    add_bram_addr <= a_cs_addr;
    

    multiply_bram_clk <= mclk;    
    multiply_bram_rst <= '0';
    multiply_bram_en <= '1';
    multiply_bram_we <= ( others => '0' );
    multiply_bram_addr <= a_cs_addr;

	process(mclk)
	   
	begin

		if (rising_edge(mclk)) then
			if (mrstn = '0') then
                y_cs_data <= ( others => '0' );
                y_cs_addr <= ( others => '0' );
                y_cs_fs <= '0';
			else
			
                a_cs_fs_d0 <= a_cs_fs;
                a_cs_fs_d1 <= a_cs_fs_d0;
                y_cs_fs <= a_cs_fs_d0;

                a_cs_addr_d0 <= a_cs_addr;
                a_cs_addr_d1 <= a_cs_addr_d0;
                y_cs_addr <= a_cs_addr_d0;
                
                a_cs_data_d0 <= a_cs_data;
                a_cs_data_d1 <= a_cs_data_d0; 
                
                if (bypass = '0') then
                    y_cs_data <= std_logic_vector(shift_right(signed(a_cs_data_d0) * signed(multiply_bram_dout), CUSTOM_STREAM_SCALE_FACTOR) + signed(add_bram_dout));
                else
                    y_cs_data <= std_logic_vector(resize(signed(a_cs_data_d0), y_cs_data'length));
                end if;

			end if;
		end if;
	end process;

end impl;