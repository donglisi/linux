cmd_drivers/clk/actions/built-in.a := rm -f drivers/clk/actions/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/actions/\1:g' | xargs ar cDPrST drivers/clk/actions/built-in.a
