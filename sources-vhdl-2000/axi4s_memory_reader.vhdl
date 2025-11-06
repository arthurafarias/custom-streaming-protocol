library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity custom_stream_memory_reader is
	generic (
		-- users to add parameters here

		CUSTOM_STREAM_FRAME_WIDTH : integer := 128;
		CUSTOM_STREAM_FRAME_HEIGHT : integer := 128;

		CUSTOM_STREAM_ADDR_WIDTH : integer := 32;
		CUSTOM_STREAM_DATA_WIDTH : integer := 32
	);
	port (

		mclk : in std_logic := '0';
		mrstn : in std_logic := '0';
		-- users to add ports here

		y_cs_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
		y_cs_data : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		y_cs_fs : out std_logic := '0';

		-- user ports ends
		-- do not modify the ports beyond this line
		bram_clk : out std_logic := '0';
		bram_rst : out std_logic := '0';
		bram_addr : out std_logic_vector(CUSTOM_STREAM_ADDR_WIDTH - 1 downto 0) := ( others => '0' );
		bram_din : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		bram_dout : in std_logic_vector(CUSTOM_STREAM_DATA_WIDTH - 1 downto 0) := ( others => '0' );
		bram_en : out std_logic := '0';
		bram_we : out std_logic_vector(CUSTOM_STREAM_DATA_WIDTH/8 - 1 downto 0) := ( others => '0' )
	);
end custom_stream_memory_reader;

architecture arch_imp of custom_stream_memory_reader is

	ATTRIBUTE X_INTERFACE_INFO : STRING;
	ATTRIBUTE X_INTERFACE_MODE : STRING;
	ATTRIBUTE X_INTERFACE_INFO of bram_clk: signal is "xilinx.com:interface:bram:1.0 bram_port CLK";
	ATTRIBUTE X_INTERFACE_MODE of bram_clk: signal is "master";
	ATTRIBUTE X_INTERFACE_INFO of bram_addr: signal is "xilinx.com:interface:bram:1.0 bram_port ADDR";
	ATTRIBUTE X_INTERFACE_INFO of bram_din: signal is "xilinx.com:interface:bram:1.0 bram_port DIN";
	ATTRIBUTE X_INTERFACE_INFO of bram_dout: signal is "xilinx.com:interface:bram:1.0 bram_port DOUT";
	ATTRIBUTE X_INTERFACE_INFO of bram_en: signal is "xilinx.com:interface:bram:1.0 bram_port EN";
	ATTRIBUTE X_INTERFACE_INFO of bram_rst: signal is "xilinx.com:interface:bram:1.0 bram_port RST";
	ATTRIBUTE X_INTERFACE_INFO of bram_we: signal is "xilinx.com:interface:bram:1.0 bram_port WE";

	--pixel bus frame sync
	signal idle_sync_counter : std_logic_vector(31 downto 0) := ( others => '0');
	signal frame_sync_counter : std_logic_vector(31 downto 0) := ( others => '0' );
	signal frame_sync_counter_d0 : std_logic_vector(31 downto 0) := ( others => '0' );
	signal frame_sync_counter_d1 : std_logic_vector(31 downto 0) := ( others => '0' );
	signal frame_sync : std_logic := '0';
	signal frame_sync_d0 : std_logic := '0';
	signal frame_sync_d1 : std_logic := '0';

begin

	bram_addr <= frame_sync_counter;
	bram_en <= '1';
	bram_rst <= '0';
	bram_we <= (others => '0');
	bram_clk <= mclk;

	process(mclk)
	begin

		if (rising_edge(mclk)) then
			if (mrstn = '0') then
				frame_sync_counter <= ( others => '0');
				frame_sync <= '0';
				frame_sync_d0 <= '0';
				frame_sync_d1 <= '0';
			else
			
                frame_sync_d0 <= frame_sync;
                frame_sync_d1 <= frame_sync_d0;
                y_cs_fs <= frame_sync;
			     
                frame_sync_counter_d0 <= frame_sync_counter;
                frame_sync_counter_d1 <= frame_sync_counter_d0;
			     
				if (unsigned(frame_sync_counter) < ((CUSTOM_STREAM_FRAME_WIDTH * CUSTOM_STREAM_FRAME_HEIGHT * CUSTOM_STREAM_DATA_WIDTH/8) - 1)) then
				    frame_sync <= '1';
					frame_sync_counter <= std_logic_vector(unsigned(frame_sync_counter) + CUSTOM_STREAM_DATA_WIDTH/8);
					
                    y_cs_addr <= frame_sync_counter_d0;
                    y_cs_data <= bram_dout;
					
				elsif(signed(idle_sync_counter) < (CUSTOM_STREAM_FRAME_WIDTH * CUSTOM_STREAM_FRAME_HEIGHT * CUSTOM_STREAM_DATA_WIDTH/8)) then
					frame_sync <= '0';
					idle_sync_counter <= std_logic_vector(unsigned(idle_sync_counter) + CUSTOM_STREAM_DATA_WIDTH/8);
					
                    y_cs_addr <= frame_sync_counter_d0;
                    y_cs_data <= bram_dout;
                    
				else
				
					frame_sync <= '0';
					frame_sync_d0 <= '0';
					frame_sync_d1 <= '0';  
					
					frame_sync_counter <= ( others => '0' );
					frame_sync_counter_d1 <= ( others => '0' );
				    frame_sync_counter_d0 <= ( others => '0' );
					
					idle_sync_counter <= ( others => '0' );
					
					y_cs_addr <= ( others => '0' );
					y_cs_data <= ( others => '0' );
					
				end if;
			end if;
		end if;
	end process;

	-- user logic ends

end arch_imp;
