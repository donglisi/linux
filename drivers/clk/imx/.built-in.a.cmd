cmd_drivers/clk/imx/built-in.a := rm -f drivers/clk/imx/built-in.a; echo  | sed -E 's:([^ ]+):drivers/clk/imx/\1:g' | xargs ar cDPrST drivers/clk/imx/built-in.a
