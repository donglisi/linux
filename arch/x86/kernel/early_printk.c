#include <linux/console.h>
#include <asm/io.h>
#include <asm/setup.h>

static unsigned long early_serial_base = 0x3f8;  /* ttyS0 */

#define XMTRDY          0x20

#define DLAB		0x80

#define TXR             0       /*  Transmit register (WRITE) */
#define RXR             0       /*  Receive register  (READ)  */
#define IER             1       /*  Interrupt Enable          */
#define IIR             2       /*  Interrupt ID              */
#define FCR             2       /*  FIFO control              */
#define LCR             3       /*  Line control              */
#define MCR             4       /*  Modem control             */
#define LSR             5       /*  Line Status               */
#define MSR             6       /*  Modem Status              */
#define DLL             0       /*  Divisor Latch Low         */
#define DLH             1       /*  Divisor latch High        */

static unsigned int io_serial_in(unsigned long addr, int offset)
{
	return inb(addr + offset);
}

static void io_serial_out(unsigned long addr, int offset, int value)
{
	outb(value, addr + offset);
}

static unsigned int (*serial_in)(unsigned long addr, int offset) = io_serial_in;
static void (*serial_out)(unsigned long addr, int offset, int value) = io_serial_out;

static int early_serial_putc(unsigned char ch)
{
	unsigned timeout = 0xffff;

	while ((serial_in(early_serial_base, LSR) & XMTRDY) == 0 && --timeout)
		cpu_relax();
	serial_out(early_serial_base, TXR, ch);
	return timeout ? 0 : -1;
}

static void early_serial_write(struct console *con, const char *s, unsigned n)
{
	while (*s && n-- > 0) {
		if (*s == '\n')
			early_serial_putc('\r');
		early_serial_putc(*s);
		s++;
	}
}

static __init void early_serial_hw_init(unsigned divisor)
{
	unsigned char c;

	serial_out(early_serial_base, LCR, 0x3);	/* 8n1 */
	serial_out(early_serial_base, IER, 0);	/* no interrupt */
	serial_out(early_serial_base, FCR, 0);	/* no fifo */
	serial_out(early_serial_base, MCR, 0x3);	/* DTR + RTS */

	c = serial_in(early_serial_base, LCR);
	serial_out(early_serial_base, LCR, c | DLAB);
	serial_out(early_serial_base, DLL, divisor & 0xff);
	serial_out(early_serial_base, DLH, (divisor >> 8) & 0xff);
	serial_out(early_serial_base, LCR, c & ~DLAB);
}

#define DEFAULT_BAUD 9600

static __init void early_serial_init(char *s)
{
	unsigned divisor;
	unsigned long baud = DEFAULT_BAUD;
	char *e;

	if (*s == ',')
		++s;

	if (*s) {
		unsigned port;
		if (!strncmp(s, "0x", 2)) {
			early_serial_base = simple_strtoul(s, &e, 16);
		} else {
			static const int __initconst bases[] = { 0x3f8, 0x2f8 };

			if (!strncmp(s, "ttyS", 4))
				s += 4;
			port = simple_strtoul(s, &e, 10);
			if (port > 1 || s == e)
				port = 0;
			early_serial_base = bases[port];
		}
		s += strcspn(s, ",");
		if (*s == ',')
			s++;
	}

	if (*s) {
		baud = simple_strtoull(s, &e, 0);

		if (baud == 0 || s == e)
			baud = DEFAULT_BAUD;
	}

	/* Convert from baud to divisor value */
	divisor = 115200 / baud;

	/* These will always be IO based ports */
	serial_in = io_serial_in;
	serial_out = io_serial_out;

	/* Set up the HW */
	early_serial_hw_init(divisor);
}

static struct console early_serial_console = {
	.name =		"earlyser",
	.write =	early_serial_write,
	.flags =	CON_PRINTBUFFER,
	.index =	-1,
};

static void early_console_register(struct console *con, int keep_early)
{
	if (con->index != -1) {
		printk(KERN_CRIT "ERROR: earlyprintk= %s already used\n",
		       con->name);
		return;
	}
	early_console = con;
	if (keep_early)
		early_console->flags &= ~CON_BOOT;
	else
		early_console->flags |= CON_BOOT;
	register_console(early_console);
}

int __init setup_early_printk(char *buf)
{
	int keep;

	if (!buf)
		return 0;

	if (early_console)
		return 0;

	keep = (strstr(buf, "keep") != NULL);

	while (*buf != '\0') {
		if (!strncmp(buf, "serial", 6)) {
			buf += 6;
			early_serial_init(buf);
			early_console_register(&early_serial_console, keep);
			if (!strncmp(buf, ",ttyS", 5))
				buf += 5;
		}
		if (!strncmp(buf, "ttyS", 4)) {
			early_serial_init(buf + 4);
			early_console_register(&early_serial_console, keep);
		}
		buf++;
	}
	return 0;
}
