library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

package custom_stream is
 
  type custom_stream_port_r is record
    pixel_clk : std_logic;
    pixel_addr : std_logic_vector;
    pixel_data : std_logic_vector;
    pixel_fs : std_logic;
  end record custom_stream_port_r;
  
  subtype custom_stream_port_v is std_logic_vector;
  
    pure function custom_stream_input_r2v (r : custom_stream_port_r) return std_logic_vector;
    pure function custom_stream_input_v2r (v : custom_stream_port_v; addr_width: integer; data_width: integer) return custom_stream_port_r;
   
end package custom_stream;
 
-- Package Body Section
package body custom_stream is

pure function custom_stream_input_r2v (r : custom_stream_port_r) return std_logic_vector is
        variable vect : custom_stream_port_v((2 + r.pixel_addr'length + r.pixel_data'length) - 1 downto 0);
    begin
    vect := r.pixel_clk & r.pixel_fs & r.pixel_addr & r.pixel_data;
    return vect;
end custom_stream_input_r2v;

pure function custom_stream_input_v2r (v : custom_stream_port_v; addr_width: integer; data_width: integer) return custom_stream_port_r is
        variable r : custom_stream_port_r( pixel_addr(addr_width-1 downto 0), pixel_data(data_width-1 downto 0) );
    begin
    r.pixel_clk := v((2 + addr_width + data_width) - 1);
    r.pixel_fs := v((1 + addr_width + data_width) - 1);
    r.pixel_addr := v((addr_width + data_width) - 1 downto 0);
    r.pixel_data := v((data_width) - 1 downto 0);
    return r;
end custom_stream_input_v2r;
 
end package body custom_stream;