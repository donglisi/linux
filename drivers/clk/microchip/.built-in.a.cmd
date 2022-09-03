cmd_drivers/clk/microchip/built-in.a := rm -f drivers/clk/microchip/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/microchip/\1:g' | xargs ar cDPrST drivers/clk/microchip/built-in.a
