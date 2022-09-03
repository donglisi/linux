	.global startup_64

	.text
startup_64:
	mov $0x3f8, %dx
	mov $'X', %al
	out %al, (%dx)
	mov $'\n', %al
	out %al, (%dx)
	hlt
