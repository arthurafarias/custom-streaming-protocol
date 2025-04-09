`ifndef custom_stream_v1_0
`define custom_stream_v1_0

interface custom_stream_v1_0();
  logic [31:0] cs_addr = 0;                              // Address
  logic [31:0] cs_data = 0;                              // Data
  logic cs_fs = 0;                                      // Frame Sync
  logic cs_user = 0;                                    // User Signaling

  modport MASTER (
    output cs_addr, cs_data, cs_fs, 
    inout cs_user
    );

  modport SLAVE (
    input cs_addr, cs_data, cs_fs, 
    inout cs_user
    );

  modport MONITOR (
    input cs_addr, cs_data, cs_fs, cs_user
    );

endinterface // custom_stream_v1_0

`endif