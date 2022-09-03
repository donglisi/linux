cmd_drivers/clk/mvebu/built-in.a := rm -f drivers/clk/mvebu/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/mvebu/\1:g' | xargs ar cDPrST drivers/clk/mvebu/built-in.a
