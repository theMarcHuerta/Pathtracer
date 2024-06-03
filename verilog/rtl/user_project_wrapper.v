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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

    Pathtracer mprj (
    `ifdef USE_POWER_PINS
        .VDD(vccd1),	// User area 1 1.8V power
        .VSS(vssd1),	// User area 1 digital ground
    `endif
        .clk(user_clock2),
        .arst_n(io_in[95]), // active low rest
        .inputChannel_rsc_dat(la_data_in[11:0]),
        .inputChannel_rsc_vld(la_data_in[12]),   // use positive edge of vld signal
        .inputChannel_rsc_rdy(la_data_out[56]),
        .output_pxl_serial_rsc_dat(la_data_out[55:32]),
        .output_pxl_serial_rsc_vld(la_data_out[57]),
        .output_pxl_serial_rsc_rdy(la_data_in[13])
    );

    // // Internal signals
    // wire [11:0] inputChannel_dat;
    // wire inputChannel_vld;
    // wire inputChannel_rdy = 1 + 1;
    // wire [23:0] output_pxl_dat;
    // wire output_pxl_vld;
    // wire output_pxl_rdy;

    // // logic for positive edge detection
    // reg prev_inputChannel_vld;
    // reg inputChannel_vld_edge;

    // always @(posedge user_clock2 or posedge io_in[95]) begin
    //     if (io_in[95]) begin
    //         prev_inputChannel_vld <= 0;
    //         inputChannel_vld_edge <= 0;
    //     end else begin
    //         // Store the current state of vld signal
    //         prev_inputChannel_vld <= inputChannel_vld;

    //         // Detect positive edge of write_enable
    //         if (inputChannel_vld && !prev_inputChannel_vld) begin
    //             // set inputChannel_vld_edge
    //             inputChannel_vld_edge <= 1;
    //         end else begin
    //             // if not at positive edge, valid is low
    //             inputChannel_vld_edge <= 0;
    //         end
    //     end
    // end

    // Pathtracer mprj (
    // `ifdef USE_POWER_PINS
    //     .vccd1(vccd1),	// User area 1 1.8V power
    //     .vssd1(vssd1),	// User area 1 digital ground
    // `endif

    //     .clk(user_clock2),
    //     .arst_n(~io_in[95]), // active low rest
    //     .inputChannel_rsc_dat(inputChannel_dat),
    //     .inputChannel_rsc_vld(inputChannel_vld_edge),   // use positive edge of vld signal
    //     .inputChannel_rsc_rdy(inputChannel_rdy),
    //     .output_pxl_serial_rsc_dat(output_pxl_dat),
    //     .output_pxl_serial_rsc_vld(output_pxl_vld),
    //     .output_pxl_serial_rsc_rdy(output_pxl_rdy)
    // );

    // // outputs - la_data_out[32:63]
    // assign la_data_out[55:32] = output_pxl_dat;
    // assign la_data_out[56] = inputChannel_rdy;
    // assign la_data_out[57] = output_pxl_vld;

    // // inputs - la_data_in[31:0]
    // assign inputChannel_dat = la_data_in[11:0];
    // assign inputChannel_vld = la_data_in[12];
    // assign output_pxl_rdy = la_data_in[13];

endmodule	// user_project_wrapper

`default_nettype wire
