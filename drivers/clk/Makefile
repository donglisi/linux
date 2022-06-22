# SPDX-License-Identifier: GPL-2.0
# common clock types
obj-$(CONFIG_HAVE_CLK)		+= clk-devres.o clk-bulk.o clkdev.o
obj-$(CONFIG_COMMON_CLK)	+= clk.o
obj-$(CONFIG_CLK_KUNIT_TEST)	+= clk_test.o
obj-$(CONFIG_COMMON_CLK)	+= clk-divider.o
obj-$(CONFIG_COMMON_CLK)	+= clk-fixed-factor.o
obj-$(CONFIG_COMMON_CLK)	+= clk-fixed-rate.o
obj-$(CONFIG_COMMON_CLK)	+= clk-gate.o
obj-$(CONFIG_CLK_GATE_KUNIT_TEST) += clk-gate_test.o
obj-$(CONFIG_COMMON_CLK)	+= clk-multiplier.o
obj-$(CONFIG_COMMON_CLK)	+= clk-mux.o
obj-$(CONFIG_COMMON_CLK)	+= clk-composite.o
obj-$(CONFIG_COMMON_CLK)	+= clk-fractional-divider.o
obj-$(CONFIG_COMMON_CLK)	+= clk-gpio.o
ifeq ($(CONFIG_OF), y)
obj-$(CONFIG_COMMON_CLK)	+= clk-conf.o
endif

# hardware specific clock types
# please keep this section sorted lexicographically by file path name
obj-$(CONFIG_COMMON_CLK_APPLE_NCO)  	+= clk-apple-nco.o
obj-$(CONFIG_MACH_ASM9260)		+= clk-asm9260.o
obj-$(CONFIG_COMMON_CLK_AXI_CLKGEN)	+= clk-axi-clkgen.o
obj-$(CONFIG_ARCH_AXXIA)		+= clk-axm5516.o
obj-$(CONFIG_COMMON_CLK_BD718XX)	+= clk-bd718x7.o
obj-$(CONFIG_COMMON_CLK_BM1880)		+= clk-bm1880.o
obj-$(CONFIG_COMMON_CLK_CDCE706)	+= clk-cdce706.o
obj-$(CONFIG_COMMON_CLK_CDCE925)	+= clk-cdce925.o
obj-$(CONFIG_ARCH_CLPS711X)		+= clk-clps711x.o
obj-$(CONFIG_COMMON_CLK_CS2000_CP)	+= clk-cs2000-cp.o
obj-$(CONFIG_ARCH_SPARX5)		+= clk-sparx5.o
obj-$(CONFIG_COMMON_CLK_EN7523)		+= clk-en7523.o
obj-$(CONFIG_COMMON_CLK_FIXED_MMIO)	+= clk-fixed-mmio.o
obj-$(CONFIG_COMMON_CLK_FSL_FLEXSPI)	+= clk-fsl-flexspi.o
obj-$(CONFIG_COMMON_CLK_FSL_SAI)	+= clk-fsl-sai.o
obj-$(CONFIG_COMMON_CLK_GEMINI)		+= clk-gemini.o
obj-$(CONFIG_COMMON_CLK_ASPEED)		+= clk-aspeed.o
obj-$(CONFIG_MACH_ASPEED_G6)		+= clk-ast2600.o
obj-$(CONFIG_ARCH_HIGHBANK)		+= clk-highbank.o
obj-$(CONFIG_CLK_HSDK)			+= clk-hsdk-pll.o
obj-$(CONFIG_COMMON_CLK_K210)		+= clk-k210.o
obj-$(CONFIG_LMK04832)			+= clk-lmk04832.o
obj-$(CONFIG_COMMON_CLK_LAN966X)	+= clk-lan966x.o
obj-$(CONFIG_COMMON_CLK_LOCHNAGAR)	+= clk-lochnagar.o
obj-$(CONFIG_COMMON_CLK_MAX77686)	+= clk-max77686.o
obj-$(CONFIG_COMMON_CLK_MAX9485)	+= clk-max9485.o
obj-$(CONFIG_ARCH_MILBEAUT_M10V)	+= clk-milbeaut.o
obj-$(CONFIG_ARCH_MOXART)		+= clk-moxart.o
obj-$(CONFIG_ARCH_NOMADIK)		+= clk-nomadik.o
obj-$(CONFIG_ARCH_NPCM7XX)	    	+= clk-npcm7xx.o
obj-$(CONFIG_ARCH_NSPIRE)		+= clk-nspire.o
obj-$(CONFIG_COMMON_CLK_OXNAS)		+= clk-oxnas.o
obj-$(CONFIG_COMMON_CLK_PALMAS)		+= clk-palmas.o
obj-$(CONFIG_CLK_LS1028A_PLLDIG)	+= clk-plldig.o
obj-$(CONFIG_COMMON_CLK_PWM)		+= clk-pwm.o
obj-$(CONFIG_CLK_QORIQ)			+= clk-qoriq.o
obj-$(CONFIG_COMMON_CLK_RK808)		+= clk-rk808.o
obj-$(CONFIG_COMMON_CLK_HI655X)		+= clk-hi655x.o
obj-$(CONFIG_COMMON_CLK_S2MPS11)	+= clk-s2mps11.o
obj-$(CONFIG_COMMON_CLK_SCMI)           += clk-scmi.o
obj-$(CONFIG_COMMON_CLK_SCPI)           += clk-scpi.o
obj-$(CONFIG_COMMON_CLK_SI5341)		+= clk-si5341.o
obj-$(CONFIG_COMMON_CLK_SI5351)		+= clk-si5351.o
obj-$(CONFIG_COMMON_CLK_SI514)		+= clk-si514.o
obj-$(CONFIG_COMMON_CLK_SI544)		+= clk-si544.o
obj-$(CONFIG_COMMON_CLK_SI570)		+= clk-si570.o
obj-$(CONFIG_COMMON_CLK_STM32F)		+= clk-stm32f4.o
obj-$(CONFIG_COMMON_CLK_STM32H7)	+= clk-stm32h7.o
obj-$(CONFIG_COMMON_CLK_STM32MP157)	+= clk-stm32mp1.o
obj-$(CONFIG_COMMON_CLK_TPS68470)      += clk-tps68470.o
obj-$(CONFIG_CLK_TWL6040)		+= clk-twl6040.o
obj-$(CONFIG_ARCH_VT8500)		+= clk-vt8500.o
obj-$(CONFIG_COMMON_CLK_RS9_PCIE)	+= clk-renesas-pcie.o
obj-$(CONFIG_COMMON_CLK_VC5)		+= clk-versaclock5.o
obj-$(CONFIG_COMMON_CLK_WM831X)		+= clk-wm831x.o
obj-$(CONFIG_COMMON_CLK_XGENE)		+= clk-xgene.o

# please keep this section sorted lexicographically by directory path name
obj-$(CONFIG_X86)			+= x86/
