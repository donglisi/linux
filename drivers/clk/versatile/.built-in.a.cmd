cmd_drivers/clk/versatile/built-in.a := rm -f drivers/clk/versatile/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/versatile/\1:g' | xargs ar cDPrST drivers/clk/versatile/built-in.a
