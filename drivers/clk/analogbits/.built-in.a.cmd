cmd_drivers/clk/analogbits/built-in.a := rm -f drivers/clk/analogbits/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/analogbits/\1:g' | xargs ar cDPrST drivers/clk/analogbits/built-in.a
