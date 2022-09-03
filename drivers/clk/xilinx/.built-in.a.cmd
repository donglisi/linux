cmd_drivers/clk/xilinx/built-in.a := rm -f drivers/clk/xilinx/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/xilinx/\1:g' | xargs ar cDPrST drivers/clk/xilinx/built-in.a
