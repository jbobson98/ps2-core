
/* time_unit = 1ns, time_precision = 100ps */
`timescale 1ns / 100ps

module tb_ps2_scanner ();

/* Local Parameters */
localparam  CLK_PERIOD    = 3;
localparam  FF_SETUP_TIME = 0.190;
localparam  FF_HOLD_TIME  = 0.100;
localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  
/* DUT Port Signals */
reg tb_clk;
reg tb_rst;
reg tb_ps2_clk;
reg tb_ps2_data;
reg tb_rx_done;
reg [7:0] tb_rx_data_o;

/* Test Bench Signals */
integer tb_test_num;
string tb_test_case;

/* Generate DUT Clock */
always begin
    tb_clk = 1'b0;  // Start clock low to avoid false rising edge events at t=0
    #(CLK_PERIOD/2.0); // half of clock period for 50% duty cycle
    tb_clk = 1'b1;
    #(CLK_PERIOD/2.0);
end

/* Instantiate DUT */
ps2_scanner DUT (
    .clk(tb_clk),
    .rst(tb_rst),
    .ps2_clk(tb_ps2_clk),
    .ps2_data(tb_ps2_data),
    .rx_done(tb_rx_done),
    .rx_data_o(tb_rx_data_o)
);

/* Task: Resut DUT */
task reset_dut;
    begin
        tb_rst = 1'b1; // active the reset
        @(posedge tb_clk);
        @(posedge tb_clk); // assert reset for two positive clock edges
        @(negedge tb_clk); // Wait until safely away from rising edge of the clock before releasing
        tb_rst = 1'b0;
        @(negedge tb_clk);
        @(negedge tb_clk);  // Leave out of reset for a couple cycles before allowing other stimulus
    end
endtask

/* Task: PS/2 Idle */
task ps2_idle;
    // PS2 clk only oscillates while transmitting data
    begin
        tb_ps2_clk = 1'b1;
        tb_ps2_data = 1'b1;
    end
endtask


task ps2_transmit;
    localparam PS2_CLOCK_PERIOD = 25; // nano seconds
    input logic [7:0] to_send;
    begin
        ps2_idle();
        #(PS2_CLOCK_PERIOD);

        // Start bit
        tb_ps2_clk = 1'b0;
        #(PS2_CLOCK_PERIOD / 4);
        tb_ps2_data = 1'b0;
        #(PS2_CLOCK_PERIOD / 4);
        tb_ps2_clk = 1'b1;
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 1
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[0];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 2
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[1];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 3
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[2];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 4
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[3];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 5
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[4];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 6
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[5];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 7
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[6];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // data bit 8
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = to_send[7];
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // parity bit
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = 1'b1;
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        // stop bit
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b1;
        tb_ps2_data = 1'b1;
        #(PS2_CLOCK_PERIOD / 2);
        tb_ps2_clk = 1'b0;

        #(PS2_CLOCK_PERIOD / 2);
        ps2_idle();

    end
endtask



/* Test Bench Main Process */
initial begin
    // Initialize DUT inputs ---------------------
    $info("INIT TESTBENCH");
    tb_rst = 1'b0;
    ps2_idle();
    tb_test_num = 0;
    tb_test_case = "Test bench initializaton";
    #(0.1);

    $info("TEST: Power-on reset");
    tb_test_num = tb_test_num + 1;
    tb_test_case = "TEST: Power-on reset";
    #(0.1);
    tb_rst = 1'b1;
    #(CLK_PERIOD * 0.5);
    assert(tb_rx_done == 1'b0);
    assert(tb_rx_data_o == 8'b00000000);
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_rst = 1'b0;
    #(CHECK_DELAY);
    assert(tb_rx_done == 1'b1);
    assert(tb_rx_data_o == 8'b00000000);

    //
    tb_test_num = tb_test_num + 1;
    ps2_transmit(8'h1C); // 0001 1100
    ps2_transmit(8'hF0); // 0001 1100

end




/*
// Task to cleanly and consistently check DUT output values 
  task check_output;
    input logic  [3:0] expected_count;
    input logic expected_flag;
    input string check_tag;
  begin

	$info("Expected Flag: %d  Actual Flag: %d", expected_flag, tb_rollover_flag);
	$info("Expected Count: %d  Actual Count: %d", expected_count, tb_count_out);
    if(expected_count == tb_count_out) begin // Check passed
      $info("Correct count output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect count output %s during %s test case  VALUE = %d", check_tag, tb_test_case,tb_count_out);
    end

    if(expected_flag == tb_rollover_flag) begin // Check passed
      $info("Correct rollover flag output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect rollover flag output %s during %s test case", check_tag, tb_test_case);
    end

  end
  endtask
*/


/*  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_rollover_val = 0;
    tb_test_num = 0;               // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    // Wait some time before starting first test case
    #(0.1);
    
    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
$info("TEST CASE 1");
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_rollover_val = 4'b0111;
    tb_n_rst  = 1'b0;    // Activate reset
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_output( 0, 0,
                  "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output( 0,0, 
                  "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #(CHECK_DELAY);
    // Check that internal state was correctly keep after reset release
    check_output(0, 0,
                  "after reset was released");


    // ************************************************************************
    // Test Case 2: Rollover Value
    // ************************************************************************
$info("TEST CASE 2");
	@(posedge tb_clk); 
	tb_test_num = tb_test_num + 1;
	tb_test_case = "Rollover_Test";
   	tb_rollover_val = 4'b1001;
	tb_count_enable = 0;
	reset_dut();

	@(negedge tb_clk); 
	tb_count_enable = 1;
	#(CLK_PERIOD * 9);
	tb_count_enable = 0;
	#(CHECK_DELAY);
	check_output(9, 1, "###");
	


    // ************************************************************************
    // Test Case 3: Continuous Counting
    // ************************************************************************
$info("TEST CASE 3");
	@(posedge tb_clk); 
	tb_test_num = tb_test_num + 1;
	tb_test_case = "Continuos Counting";
	tb_rollover_val = 4'b1111;
	tb_count_enable = 0;
	reset_dut();

	@(negedge tb_clk); 
	tb_count_enable = 1;
	#(CLK_PERIOD * 17);
	tb_count_enable = 0;	
	#(CHECK_DELAY);
	check_output(2, 0, "CC");

    // ************************************************************************
    // Test Case 4: DC
    // ************************************************************************
$info("TEST CASE 4");
	@(posedge tb_clk); 
	tb_test_num = tb_test_num + 1;
	tb_test_case = "Discontinuos Counting";
	tb_rollover_val = 4'b1111;
	tb_count_enable = 0;
	reset_dut();
	
	@(negedge tb_clk); 	
	tb_count_enable = 1;
	#(CLK_PERIOD * 9);
	tb_count_enable = 0;	
	#(CHECK_DELAY);
	check_output(9, 0, "DC");
	
	@(negedge tb_clk); 
	tb_count_enable = 1;
	#(CLK_PERIOD * 3);
	tb_count_enable = 0;	
	#(CHECK_DELAY);
	check_output(12, 0, "DC");

    // ************************************************************************
    // Test Case 5: Clear
    // ************************************************************************
$info("TEST CASE 5");
	@(posedge tb_clk); 
	tb_test_num = tb_test_num + 1;
	tb_test_case = "Clearing";
	tb_rollover_val = 4'b1111;
	tb_count_enable = 0;
	reset_dut();

	@(negedge tb_clk); 
	tb_count_enable = 1;
	#(CLK_PERIOD * 8);
	normal_clear;
	#(CLK_PERIOD);
	tb_count_enable = 0;
	#(CHECK_DELAY);
	check_output(1, 0, "DC");
  end
*/

endmodule