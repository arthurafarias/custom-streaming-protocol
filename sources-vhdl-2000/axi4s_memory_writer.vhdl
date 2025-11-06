library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity custom_stream_memory_writer is
	generic (
		-- users to add parameters here

		CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
		CUSTOM_STREAM_DATA_WIDTH : integer := 32
	);
	port (

		mclk : in std_logic := '0';
		mrstn : in std_logic := '0';
		-- users to add ports here

		intr : out std_logic := '0';

		a_cs_addr : in std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
		a_cs_data : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		a_cs_fs : in std_logic := '0';

		-- user ports ends
		-- do not modify the ports beyond this line
		bram_clk : out std_logic := '0';
		bram_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
		bram_din : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		bram_dout : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		bram_en : out std_logic := '0';
		bram_rst : out std_logic := '1';
		bram_we : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH/8 - 1 downto 0) := ( others => '0' )

		
	);
end custom_stream_memory_writer;

architecture arch_imp of custom_stream_memory_writer is

	ATTRIBUTE X_INTERFACE_INFO : STRING;
	ATTRIBUTE X_INTERFACE_INFO of bram_clk: signal is "xilinx.com:interface:bram:1.0 bram_port CLK";
	ATTRIBUTE X_INTERFACE_INFO of bram_addr: signal is "xilinx.com:interface:bram:1.0 bram_port ADDR";
	ATTRIBUTE X_INTERFACE_INFO of bram_din: signal is "xilinx.com:interface:bram:1.0 bram_port DIN";
	ATTRIBUTE X_INTERFACE_INFO of bram_dout: signal is "xilinx.com:interface:bram:1.0 bram_port DOUT";
	ATTRIBUTE X_INTERFACE_INFO of bram_en: signal is "xilinx.com:interface:bram:1.0 bram_port EN";
	ATTRIBUTE X_INTERFACE_INFO of bram_rst: signal is "xilinx.com:interface:bram:1.0 bram_port RST";
	ATTRIBUTE X_INTERFACE_INFO of bram_we: signal is "xilinx.com:interface:bram:1.0 bram_port WE";

	signal a_cs_fs_d0 : std_logic := '0';

begin

	bram_clk <= mclk;
	
	process(mclk) begin
	if (rising_edge(mclk)) then
	   if (mrstn = '0') then
	       bram_addr <= ( others => '0');
	       bram_din <= ( others => '0');
	       bram_we <= ( others => '0');
	       bram_en <= '0';
	       bram_rst <= '1';
	   else
	       bram_addr <= a_cs_addr;
	       bram_din <= a_cs_data;
	       bram_we <= ( others => a_cs_fs);
	       bram_en <= '1';
	       bram_rst <= '0';
		   a_cs_fs_d0 <= a_cs_fs;
		   intr <= (a_cs_fs xor a_cs_fs_d0) and a_cs_fs;
	   end if;
	end if;
	end process;

end arch_imp;
