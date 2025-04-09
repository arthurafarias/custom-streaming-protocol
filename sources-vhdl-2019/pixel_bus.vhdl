library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

package pixel_bus is
 
  type pixel_bus_port_r is record
    pixel_clk : std_logic;
    pixel_addr : std_logic_vector;
    pixel_data : std_logic_vector;
    pixel_fs : std_logic;
  end record pixel_bus_port_r;
  
  subtype pixel_bus_port_v is std_logic_vector;
  
    pure function pixel_bus_input_r2v (r : pixel_bus_port_r) return std_logic_vector;
    pure function pixel_bus_input_v2r (v : pixel_bus_port_v; addr_width: integer; data_width: integer) return pixel_bus_port_r;
   
end package pixel_bus;
 
-- Package Body Section
package body pixel_bus is

pure function pixel_bus_input_r2v (r : pixel_bus_port_r) return std_logic_vector is
        variable vect : pixel_bus_port_v((2 + r.pixel_addr'length + r.pixel_data'length) - 1 downto 0);
    begin
    vect := r.pixel_clk & r.pixel_fs & r.pixel_addr & r.pixel_data;
    return vect;
end pixel_bus_input_r2v;

pure function pixel_bus_input_v2r (v : pixel_bus_port_v; addr_width: integer; data_width: integer) return pixel_bus_port_r is
        variable r : pixel_bus_port_r( pixel_addr(addr_width-1 downto 0), pixel_data(data_width-1 downto 0) );
    begin
    r.pixel_clk := v((2 + addr_width + data_width) - 1);
    r.pixel_fs := v((1 + addr_width + data_width) - 1);
    r.pixel_addr := v((addr_width + data_width) - 1 downto 0);
    r.pixel_data := v((data_width) - 1 downto 0);
    return r;
end pixel_bus_input_v2r;
 
end package body pixel_bus;