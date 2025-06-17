`timescale 1ns / 1ps

module tb_packet_filter;

  reg clk = 0;
  reg rst = 1;
  reg [7:0] data_in;
  reg valid_in;
  wire packet_allowed;
  wire done;

  // Instantiate DUT
  packet_filter dut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid_in(valid_in),
    .packet_allowed(packet_allowed),
    .done(done)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  // Sample packet with src IP = 192.168.1.100 (blocked IP)
  reg [7:0] test_packet [0:39];
  integer i;  // Declare outside initial block

  initial begin
    // Fill packet with dummy data
    for (i = 0; i < 40; i = i + 1)
      test_packet[i] = 8'h00;

    // Insert source IP at bytes 26-29: 0xC0A80164
    test_packet[26] = 8'hC0;
    test_packet[27] = 8'hA8;
    test_packet[28] = 8'h01;
    test_packet[29] = 8'h64;

    // Reset pulse
    #10 rst = 0;

    // Feed packet bytes
    for (i = 0; i < 40; i = i + 1) begin
      @(posedge clk);
      data_in <= test_packet[i];
      valid_in <= 1;
    end

    @(posedge clk);
    valid_in <= 0; // Stop sending

    // Wait for decision
    wait (done == 1);
    $display("Packet decision: %s", packet_allowed ? "ALLOWED" : "BLOCKED");

    if (packet_allowed == 0)
      $display("Test PASSED: Packet correctly BLOCKED.");
    else
      $display("Test FAILED: Packet should have been BLOCKED.");

    $finish;
  end

endmodule
