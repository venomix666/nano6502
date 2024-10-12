// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtop.h"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

int main(int argc, char** argv) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

    // Set Vtop's input signals
    top->rst_n_i = 1;
    top->clk_i = 0;

    top->freq1_lsb = 0x00;
    top->freq1_msb = 0x18;
    top->pulse1_lsb = 0x00;
    top->pulse1_msb = 0x00;
    top->ctrl1 = 0x00;
    top->attack_decay1 = 0x00;
    top->sustain_release1 = 0x00;

    top->freq2_lsb = 0x00;
    top->freq2_msb = 0x23;
    top->pulse2_lsb = 0x00;
    top->pulse2_msb = 0x00;
    top->ctrl2 = 0x00;
    top->attack_decay2 = 0x00;
    top->sustain_release2 = 0x00;

    top->freq3_lsb = 0x00;
    top->freq3_msb = 0x18;
    top->pulse3_lsb = 0x00;
    top->pulse3_msb = 0x00;
    top->ctrl3 = 0x00;
    top->attack_decay3 = 0x00;
    top->sustain_release3 = 0x00;

    top->mixer_volume = 0x10;

    uint8_t done=0;
    // Simulate until $finish
    while (!contextp->gotFinish()) {
    //while(!done) { 
       // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1);  // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        top->clk_i = !top->clk_i;

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        if (!top->clk_i) {
            if (contextp->time() > 1 && contextp->time() < 100) {
                top->rst_n_i = 0;  // Assert reset
            } else {
                top->rst_n_i = 1;  // Deassert reset
            }
        
            // Start a note
            if(contextp->time() == 110) {
                top->attack_decay1 = 0x88;
                top->sustain_release1 = 0x28;
                top->pulse1_msb = 0x03;
            }
            if(contextp->time() == 112) {
                top->ctrl1 = 0x21;
            }

        }

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();

        // Read outputs
        VL_PRINTF("[%" PRId64 "] clk=%x rstl=%x\n",
                  contextp->time(), top->clk_i, top->rst_n_i);
    	if(contextp->time() > 100000) done=1;
    }

    // Final model cleanup
    top->final();

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Final simulation summary
    //contextp->statsPrintSummary();

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
