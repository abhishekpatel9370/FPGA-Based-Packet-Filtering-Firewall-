module packet_filter (
    input clk,
    input rst,
    input [7:0] data_in,            // Incoming byte from UART or AXI Stream
    input       valid_in,           // Byte valid signal
    input [31:0] blocked_ip,        // IP read from BRAM at address = ip_index
    output reg [7:0] bram_addr,     // BRAM address to fetch blocked IP
    output reg  packet_allowed,     // 1 = allowed, 0 = blocked
    output reg  done                // 1 = decision made
);

    reg [7:0] buffer[0:39];         // Buffer to hold packet header
    reg [5:0] byte_counter;
    reg [2:0] state;
    reg [31:0] src_ip;
    reg [7:0] ip_index;
    reg match_found;

    localparam IDLE       = 0,
               READ_PKT   = 1,
               EXTRACT_IP = 2,
               CHECK_BRAM = 3,
               DECIDE     = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_counter    <= 0;
            state           <= IDLE;
            done            <= 0;
            packet_allowed  <= 0;
            ip_index        <= 0;
            match_found     <= 0;
            bram_addr       <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    packet_allowed <= 0;
                    match_found <= 0;
                    if (valid_in) begin
                        buffer[0] <= data_in;
                        byte_counter <= 1;
                        state <= READ_PKT;
                    end
                end

                READ_PKT: begin
                    if (valid_in) begin
                        buffer[byte_counter] <= data_in;
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == 6'd39) begin
                            state <= EXTRACT_IP;
                        end
                    end
                end

                EXTRACT_IP: begin
                    src_ip <= {buffer[26], buffer[27], buffer[28], buffer[29]};
                    ip_index <= 0;
                    bram_addr <= 0;
                    state <= CHECK_BRAM;
                end

                CHECK_BRAM: begin
                    bram_addr <= ip_index;  // Tell BRAM what IP to send next

                    if (blocked_ip == src_ip) begin
                        match_found <= 1;
                        state <= DECIDE;
                    end else if (ip_index == 8'd255) begin
                        // No match after full scan
                        state <= DECIDE;
                    end else begin
                        ip_index <= ip_index + 1;
                        bram_addr <= ip_index + 1;
                    end
                end

                DECIDE: begin
                    packet_allowed <= ~match_found;
                    done <= 1;
                    state <= IDLE;
                    byte_counter <= 0;
                end
            endcase
        end
    end

endmodule
