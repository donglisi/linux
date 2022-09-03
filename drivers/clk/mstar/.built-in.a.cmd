cmd_drivers/clk/mstar/built-in.a := rm -f drivers/clk/mstar/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/mstar/\1:g' | xargs ar cDPrST drivers/clk/mstar/built-in.a
