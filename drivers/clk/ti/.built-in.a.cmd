cmd_drivers/clk/ti/built-in.a := rm -f drivers/clk/ti/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/ti/\1:g' | xargs ar cDPrST drivers/clk/ti/built-in.a
