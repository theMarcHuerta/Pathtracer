// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */



module user_proj_pathtracer #(
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,

    // IOs
    input  [23:0] io_in,
    output [23:0] io_out,
    output [23:0] io_oeb,

);

    // Internal signals
    wire [11:0] inputChannel_dat;
    wire inputChannel_vld;
    wire inputChannel_rdy;
    wire [7:0] output_pxl_dat;
    wire output_pxl_vld;
    wire output_pxl_rdy;

    // Instantiate Pathtracer
    Pathtracer pathtracer_inst (
        .clk(wb_clk_i),
        .arst_n(~wb_rst_i),
        .inputChannel_rsc_dat(inputChannel_dat),
        .inputChannel_rsc_vld(inputChannel_vld),
        .inputChannel_rsc_rdy(inputChannel_rdy),
        .output_pxl_serial_rsc_dat(output_pxl_dat),
        .output_pxl_serial_rsc_vld(output_pxl_vld),
        .output_pxl_serial_rsc_rdy(output_pxl_rdy)
    );

    assign io_out[0] = inputChannel_rdy;
    assign io_out[8:1] = output_pxl_dat;
    assign io_out[9] = output_pxl_rdy;
    assign inputChannel_dat = io_in[21:10];
    assign inputChannel_vld = io_in[22];
    assign output_pxl_vld = io_in[23];

    assign io_oeb[9:0] = 10'b1111111111;
    assign io_oeb[23:10] = 14'd0;

endmodule







// 	input wb_clk_i;
// 	input wb_rst_i;
// 	input wbs_stb_i;
// 	input wbs_cyc_i;
// 	input wbs_we_i;
// 	input [3:0] wbs_sel_i;
// 	input [31:0] wbs_dat_i;
// 	input [31:0] wbs_adr_i;



// 	output wire wbs_ack_o;
// 	output wire [31:0] wbs_dat_o;
// 	output reg [63:0] load_recv_msg;
// 	output reg load_recv_val;
// 	input load_recv_rdy;
// 	output reg [31:0] instruction_recv_msg;
// 	output reg instruction_recv_val;
// 	input instruction_recv_rdy;
// 	input [31:0] store_send_msg;
// 	input store_send_val;
// 	output wire store_send_rdy;



// 	wire [31:0] internal_wbs_dat_i;
// 	wire [31:0] internal_wbs_adr_i;
// 	reg store_transaction_in_progress;
// 	assign internal_wbs_dat_i = (wbs_stb_i && wbs_cyc_i ? wbs_dat_i : 32'b00000000000000000000000000000000);
// 	assign internal_wbs_adr_i = (wbs_stb_i && wbs_cyc_i ? wbs_adr_i : 32'b00000000000000000000000000000000);
// 	assign wbs_ack_o = (wbs_cyc_i && wbs_stb_i) && ((((internal_wbs_adr_i == 32'h30000000) && instruction_recv_rdy) || ((internal_wbs_adr_i > 32'h30000000) && (((!wbs_we_i && store_send_val) && store_send_rdy) && store_transaction_in_progress))) || ((((internal_wbs_adr_i > 32'h30000000) && wbs_we_i) && load_recv_rdy) && instruction_recv_rdy));
// 	assign store_send_rdy = ((!wbs_we_i && wbs_cyc_i) && wbs_stb_i) && (internal_wbs_adr_i > 32'h30000000);
// 	assign wbs_dat_o = store_send_msg;

// 	always @(posedge wb_clk_i or posedge wb_rst_i)
// 		if (wb_rst_i)
// 			store_transaction_in_progress <= 0;
// 		else if (wbs_ack_o)
// 			store_transaction_in_progress <= 0;
// 		else if (((instruction_recv_val && load_recv_val) && (internal_wbs_adr_i > 32'h30000000)) && !wbs_we_i)
// 			store_transaction_in_progress <= 1;
// 	always @(*) begin
// 		load_recv_msg = 64'b0000000000000000000000000000000000000000000000000000000000000000;
// 		load_recv_val = 0;
// 		instruction_recv_msg = 32'b00000000000000000000000000000000;
// 		instruction_recv_val = 0;
// 		if (!store_transaction_in_progress) begin
// 			if (internal_wbs_adr_i == 32'h30000000) begin
// 				instruction_recv_msg = internal_wbs_dat_i;
// 				instruction_recv_val = wbs_cyc_i && wbs_stb_i;
// 			end
// 			else if (internal_wbs_adr_i > 32'h30000000) begin
// 				load_recv_msg = {(internal_wbs_adr_i - 32'h30000004) >> 2, internal_wbs_dat_i};
// 				load_recv_val = wbs_cyc_i && wbs_stb_i;
// 				if (wbs_we_i)
// 					instruction_recv_msg = 32'b00000000000000000000000000000000;
// 				else
// 					instruction_recv_msg = 32'b00001000000000000000000000000000;
// 				instruction_recv_val = wbs_cyc_i && wbs_stb_i;
// 			end
// 		end
// 	end
// endmodule


// // SPDX-FileCopyrightText: 2020 Efabless Corporation
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //      http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.
// // SPDX-License-Identifier: Apache-2.0

// `default_nettype none
// /*
//  *-------------------------------------------------------------
//  *
//  * user_proj_example
//  *
//  * This is an example of a (trivially simple) user project,
//  * showing how the user project can connect to the logic
//  * analyzer, the wishbone bus, and the I/O pads.
//  *
//  * This project generates an integer count, which is output
//  * on the user area GPIO pads (digital output only).  The
//  * wishbone connection allows the project to be controlled
//  * (start and stop) from the management SoC program.
//  *
//  * See the testbenches in directory "mprj_counter" for the
//  * example programs that drive this user project.  The three
//  * testbenches are "io_ports", "la_test1", and "la_test2".
//  *
//  *-------------------------------------------------------------
//  */



// module user_proj_example #(
// )(
// `ifdef USE_POWER_PINS
//     inout vccd1,	// User area 1 1.8V supply
//     inout vssd1,	// User area 1 digital ground
// `endif

//     // Wishbone Slave ports (WB MI A)
//     input wb_clk_i,
//     input wb_rst_i,
//     input wbs_stb_i,
//     input wbs_cyc_i,
//     input wbs_we_i,
//     input [3:0] wbs_sel_i,
//     input [31:0] wbs_dat_i,
//     input [31:0] wbs_adr_i,
//     output wbs_ack_o,
//     output [31:0] wbs_dat_o,

//     // Logic Analyzer Signals
//     input  [127:0] la_data_in,
//     output [127:0] la_data_out,
//     input  [127:0] la_oenb,

//     // IOs
//     input  [33:0] io_in,
//     output [33:0] io_out,
//     output [33:0] io_oeb,

//     // IRQ
//     output [2:0] irq
// );

//     // Internal signals
//     wire [11:0] inputChannel_dat;
//     reg [11:0] inputChannel_dat_tmp;
//     wire inputChannel_vld;
//     reg inputChannel_vld_tmp;
//     wire inputChannel_rdy;

//     wire [23:0] output_pxl_dat;
//     wire output_pxl_vld;
//     wire output_pxl_rdy;

//     // Instantiate Pathtracer
//     Pathtracer pathtracer_inst (
//         .clk(wb_clk_i),
//         .arst_n(~wb_rst_i),
//         .inputChannel_rsc_dat(inputChannel_dat),
//         .inputChannel_rsc_vld(inputChannel_vld),
//         .inputChannel_rsc_rdy(inputChannel_rdy),
//         .output_pxl_serial_rsc_dat(output_pxl_dat),
//         .output_pxl_serial_rsc_vld(output_pxl_vld),
//         .output_pxl_serial_rsc_rdy(output_pxl_rdy)
//     );

//     assign io_out[24:0] = {output_pxl_vld, output_pxl_dat};
//     assign io_out[25] = output_pxl_rdy;

//     // Wishbone interface logic
//     always @(posedge wb_clk_i) begin
//         if (wb_rst_i) begin
//             wbs_ack_o <= 0;
//             inputChannel_vld_tmp <= 0;
//             output_pxl_vld_tmp <= 0;
//         end else begin
//             wbs_ack_o <= 0;  // Default to not acknowledging
//             if (wbs_cyc_i && wbs_stb_i) begin  // Wishbone cycle valid and strobe
//                 wbs_ack_o <= 1;  // Acknowledge the Wishbone transaction
//                 if (wbs_we_i) begin  // Wishbone write operation
//                     case (wbs_adr_i)
//                         32'h0000_0000: begin
//                             inputChannel_dat_tmp <= wbs_dat_i[11:0];
//                             inputChannel_vld_tmp <= 1;
//                         end
//                         32'h0000_0004: begin
//                             output_pxl_vld_tmp <= 1;  // Example control signal to Pathtracer
//                         end
//                         default: begin
//                             inputChannel_vld_tmp <= 0;  // Ensure vld is reset if not actively set
//                             output_pxl_vld_tmp <= 0;  // Reset output vld as well
//                         end
//                     endcase
//                 end else begin  // Wishbone read operation
//                     case (wbs_adr_i)
//                         32'h0000_0008: begin
//                             wbs_dat_o <= {8'b0, output_pxl_dat};  // Return 24-bit data left-justified
//                         end
//                     endcase
//                 end
//             end else begin
//                 inputChannel_vld_tmp <= 0;  // Reset valid flags when not in a valid cycle
//                 output_pxl_vld_tmp <= 0;
//             end
//         end
//     end

//     assign inputChannel_dat = inputChannel_dat_tmp;
//     assign inputChannel_vld = inputChannel_vld_tmp;
//     assign output_pxl_vld = output_pxl_vld_tmp;

//     // Logic Analyzer and other outputs (if used)
//     assign la_data_out = 128'd0;  // Example: not used here

// endmodule







// 	input wb_clk_i;
// 	input wb_rst_i;
// 	input wbs_stb_i;
// 	input wbs_cyc_i;
// 	input wbs_we_i;
// 	input [3:0] wbs_sel_i;
// 	input [31:0] wbs_dat_i;
// 	input [31:0] wbs_adr_i;



// 	output wire wbs_ack_o;
// 	output wire [31:0] wbs_dat_o;
// 	output reg [63:0] load_recv_msg;
// 	output reg load_recv_val;
// 	input load_recv_rdy;
// 	output reg [31:0] instruction_recv_msg;
// 	output reg instruction_recv_val;
// 	input instruction_recv_rdy;
// 	input [31:0] store_send_msg;
// 	input store_send_val;
// 	output wire store_send_rdy;



// 	wire [31:0] internal_wbs_dat_i;
// 	wire [31:0] internal_wbs_adr_i;
// 	reg store_transaction_in_progress;
// 	assign internal_wbs_dat_i = (wbs_stb_i && wbs_cyc_i ? wbs_dat_i : 32'b00000000000000000000000000000000);
// 	assign internal_wbs_adr_i = (wbs_stb_i && wbs_cyc_i ? wbs_adr_i : 32'b00000000000000000000000000000000);
// 	assign wbs_ack_o = (wbs_cyc_i && wbs_stb_i) && ((((internal_wbs_adr_i == 32'h30000000) && instruction_recv_rdy) || ((internal_wbs_adr_i > 32'h30000000) && (((!wbs_we_i && store_send_val) && store_send_rdy) && store_transaction_in_progress))) || ((((internal_wbs_adr_i > 32'h30000000) && wbs_we_i) && load_recv_rdy) && instruction_recv_rdy));
// 	assign store_send_rdy = ((!wbs_we_i && wbs_cyc_i) && wbs_stb_i) && (internal_wbs_adr_i > 32'h30000000);
// 	assign wbs_dat_o = store_send_msg;

// 	always @(posedge wb_clk_i or posedge wb_rst_i)
// 		if (wb_rst_i)
// 			store_transaction_in_progress <= 0;
// 		else if (wbs_ack_o)
// 			store_transaction_in_progress <= 0;
// 		else if (((instruction_recv_val && load_recv_val) && (internal_wbs_adr_i > 32'h30000000)) && !wbs_we_i)
// 			store_transaction_in_progress <= 1;
// 	always @(*) begin
// 		load_recv_msg = 64'b0000000000000000000000000000000000000000000000000000000000000000;
// 		load_recv_val = 0;
// 		instruction_recv_msg = 32'b00000000000000000000000000000000;
// 		instruction_recv_val = 0;
// 		if (!store_transaction_in_progress) begin
// 			if (internal_wbs_adr_i == 32'h30000000) begin
// 				instruction_recv_msg = internal_wbs_dat_i;
// 				instruction_recv_val = wbs_cyc_i && wbs_stb_i;
// 			end
// 			else if (internal_wbs_adr_i > 32'h30000000) begin
// 				load_recv_msg = {(internal_wbs_adr_i - 32'h30000004) >> 2, internal_wbs_dat_i};
// 				load_recv_val = wbs_cyc_i && wbs_stb_i;
// 				if (wbs_we_i)
// 					instruction_recv_msg = 32'b00000000000000000000000000000000;
// 				else
// 					instruction_recv_msg = 32'b00001000000000000000000000000000;
// 				instruction_recv_val = wbs_cyc_i && wbs_stb_i;
// 			end
// 		end
// 	end
// endmodule