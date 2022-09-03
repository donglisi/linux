cmd_drivers/clk/socfpga/built-in.a := rm -f drivers/clk/socfpga/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/socfpga/\1:g' | xargs ar cDPrST drivers/clk/socfpga/built-in.a
