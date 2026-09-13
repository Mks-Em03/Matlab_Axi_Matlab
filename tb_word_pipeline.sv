// AXI4-Stream testbench for word4_pipeline (HDL Coder DUT).
// DUT slave port  = input  (fed by this Master)
// DUT master port = output (consumed by this Slave)
`timescale 1ns/1ps

module tb_word4_pipeline;
  localparam int W          = 32;
  localparam int N          = 10;
  localparam int CLK_NS     = 10;      // 100 MHz
  localparam realtime BUDGET = 100us;

  logic             clk, rst_n;
  logic [W-1:0]     s_tdata;
  logic             s_tvalid, s_tready;
  logic [W-1:0]     m_tdata;
  logic             m_tvalid, m_tready;

  word4_pipeline dut (
    .clk        (clk),
    .reset_n    (rst_n),
    .s_axis_tdata  (s_tdata),
    .s_axis_tvalid (s_tvalid),
    .s_axis_tready (s_tready),
    .m_axis_tdata  (m_tdata),
    .m_axis_tvalid (m_tvalid),
    .m_axis_tready (m_tready)
  );

  initial clk = 0;
  always #(CLK_NS/2) clk = ~clk;

  task automatic axis_push(input logic [W-1:0] d);
    s_tdata  <= d;
    s_tvalid <= 1;
    do @(posedge clk); while (!s_tready);
    s_tvalid <= 0;
  endtask

  task automatic axis_pop(output logic [W-1:0] d);
    m_tready <= 1;
    do @(posedge clk); while (!m_tvalid);
    d = m_tdata;
    m_tready <= 0;
  endtask

  logic [15:0] vec [N];
  int unsigned packets;

  initial begin
    rst_n = 0; s_tvalid = 0; s_tdata = 0; m_tready = 0; packets = 0;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    vec = '{16'd10,16'd20,16'd30,16'd40,16'd50,
            16'd60,16'd70,16'd80,16'd90,16'd100};

    fork
      begin : drive
        realtime t0;
        t0 = $realtime;
        for (int i = 0; i < N; i++) axis_push(vec[i]);
        // optional idle
        repeat (8) @(posedge clk);
        if ($realtime - t0 > BUDGET)
          $fatal(1, "Input burst itself exceeded 100 us");
      end
      begin : monitor
        logic [W-1:0] got;
        realtime t0, t1;
        t0 = $realtime;
        axis_pop(got);
        t1 = $realtime;
        packets++;
        if (got[15:0] !== vec[3])
          $fatal(1, "word4 mismatch got=%0h exp=%0h", got[15:0], vec[3]);
        if (got[31:16] !== packets)
          $fatal(1, "count mismatch got=%0d exp=%0d", got[31:16], packets);
        if (t1 - t0 > BUDGET)
          $fatal(1, "Latency %0t missed 100 us budget", t1 - t0);
        $display("PASS  word4=%0d  count=%0d  latency=%0t", got[15:0], got[31:16], t1-t0);
      end
    join

    // Backpressure check: stall the slave for a few cycles on packet 2
    vec = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8,16'd9,16'd10};
    fork
      begin
        for (int i = 0; i < N; i++) axis_push(vec[i]);
      end
      begin
        logic [W-1:0] got;
        m_tready <= 0;
        repeat (5) @(posedge clk);
        axis_pop(got);
        packets++;
        if (got[15:0] !== 16'd4) $fatal(1, "word4 mismatch under stall");
        $display("PASS stall  word4=%0d count=%0d", got[15:0], got[31:16]);
      end
    join

    $display("All tests passed.");
    $finish;
  end
endmodule