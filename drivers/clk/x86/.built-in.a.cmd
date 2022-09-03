cmd_drivers/clk/x86/built-in.a := rm -f drivers/clk/x86/built-in.a; echo clk-pmc-atom.o | sed -E 's:([^ ]+):drivers/clk/x86/\1:g' | xargs ar cDPrST drivers/clk/x86/built-in.a
