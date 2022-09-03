cmd_drivers/clk/sunxi-ng/built-in.a := rm -f drivers/clk/sunxi-ng/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/sunxi-ng/\1:g' | xargs ar cDPrST drivers/clk/sunxi-ng/built-in.a
