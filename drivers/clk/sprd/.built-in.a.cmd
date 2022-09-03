cmd_drivers/clk/sprd/built-in.a := rm -f drivers/clk/sprd/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/sprd/\1:g' | xargs ar cDPrST drivers/clk/sprd/built-in.a
