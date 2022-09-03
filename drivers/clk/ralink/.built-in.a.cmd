cmd_drivers/clk/ralink/built-in.a := rm -f drivers/clk/ralink/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/ralink/\1:g' | xargs ar cDPrST drivers/clk/ralink/built-in.a
