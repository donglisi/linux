cmd_drivers/clk/imgtec/built-in.a := rm -f drivers/clk/imgtec/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/imgtec/\1:g' | xargs ar cDPrST drivers/clk/imgtec/built-in.a
