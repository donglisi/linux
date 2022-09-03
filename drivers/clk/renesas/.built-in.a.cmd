cmd_drivers/clk/renesas/built-in.a := rm -f drivers/clk/renesas/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/renesas/\1:g' | xargs ar cDPrST drivers/clk/renesas/built-in.a
