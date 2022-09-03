cmd_drivers/clk/ingenic/built-in.a := rm -f drivers/clk/ingenic/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/ingenic/\1:g' | xargs ar cDPrST drivers/clk/ingenic/built-in.a
