# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import textwrap
import shutil

EXTRA_LEN = len(': ')


def format_steps(name, desc, indent, max_len, width):
    # format name

    if name != '':
        namef = "{}{{:<{}}}".format(indent * ' ', max_len)
        namef = namef.format(name + ':')
    else:
        namef = (indent + max_len) * ' '

    # format description
    descl = []
    for line in desc.splitlines():
        descl += textwrap.wrap(line, width=width-max_len-indent)
    second_line_desc = textwrap.indent('\n'.join(descl[1:]),
                                       (max_len + indent) * ' ')
    descl = '\n'.join([descl[0], second_line_desc]).strip()

    return namef + descl + '\n'


def format_options(opts, header, footer, indent, pre_len, term_width):
    opt_text = ""
    opt_len = max([0] + [len(x.get_name()) for x in opts])
    opt_len += EXTRA_LEN
    if opts:
        opt_text += format_steps("", header, 0, pre_len,
                                 term_width)
    for opt in opts:
        desc = f"{opt.get_help()} (type: {opt.get_type_help()})"
        opt_text += format_steps(opt.get_name(), desc,
                                 indent + pre_len,
                                 opt_len,
                                 term_width)
    return opt_text + footer


def print_avail_steps(avail_steps):
    """Return a nice formatted string with all available steps."""
    indent = 2
    ret = ""
    steps = sorted([(x.get_name(), x.get_description(), x.options())
                    for x in avail_steps])
    max_len = max([len(x[0]) for x in steps])
    max_len += EXTRA_LEN

    term_width = shutil.get_terminal_size((80, 20)).columns

    global_opts = {}
    for step in steps:
        for opt in step[2]:
            if opt.is_global():
                global_opts[opt.get_name()] = opt

    intro = "The following global options are accepted:\n"
    ret += format_options(global_opts.values(), intro, '\n', indent,
                          0, term_width)

    ret += "Available Steps:\n"
    for step in steps:
        ret += format_steps(step[0], step[1], indent, max_len, term_width)

        # format extra options
        intro = "The step accepts the following options:\n"
        opts = [x for x in step[2] if not x.is_global()]
        ret += format_options(opts, intro, '', indent, max_len+indent,
                              term_width)
    return ret.strip()
