/**
 ******************************************************************************
 * @file       pios_ibus_priv.h
 * @author     The LibrePilot Project, http://www.librepilot.org Copyright (C) 2016.
 *             dRonin, http://dRonin.org/, Copyright (C) 2016
 * @addtogroup PIOS PIOS Core hardware abstraction layer
 * @{
 * @addtogroup PIOS_IBus IBus receiver functions
 * @{
 * @brief Receives and decodes IBus protocol receiver packets
 *****************************************************************************/
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 * Additional note on redistribution: The copyright and license notices above
 * must be maintained in each individual source file that is a derivative work
 * of this source file; otherwise redistribution is prohibited.
 */


#ifndef PIOS_IBUS_PRIV_H
#define PIOS_IBUS_PRIV_H

#include <pios.h>
#include <pios_usart_priv.h>

/* IBUS receiver instance configuration */
extern const struct pios_rcvr_driver pios_ibus_rcvr_driver;

extern int32_t PIOS_IBUS_Init(uint32_t *ibus_id,
                              const struct pios_com_driver *driver,
                              uint32_t lower_id);

#endif // PIOS_IBUS_PRIV_H

/**
 * @}
 * @}
 */
