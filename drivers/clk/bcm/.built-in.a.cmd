cmd_drivers/clk/bcm/built-in.a := rm -f drivers/clk/bcm/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/bcm/\1:g' | xargs ar cDPrST drivers/clk/bcm/built-in.a
