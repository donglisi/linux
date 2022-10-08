/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _CONSOLE_CMDLINE_H
#define _CONSOLE_CMDLINE_H

struct console_cmdline
{
	char	name[16];			/* Name of the driver	    */
	int	index;				/* Minor dev. to use	    */
	bool	user_specified;			/* Specified by command line vs. platform */
	char	*options;			/* Options for the driver   */
};

#endif
