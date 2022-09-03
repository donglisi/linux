cmd_drivers/clk/mediatek/built-in.a := rm -f drivers/clk/mediatek/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/mediatek/\1:g' | xargs ar cDPrST drivers/clk/mediatek/built-in.a
