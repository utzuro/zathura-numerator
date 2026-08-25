/* SPDX-License-Identifier: Zlib */

#ifndef ZATHURA_LINKS_INTERNAL_H
#define ZATHURA_LINKS_INTERNAL_H

#include "links.h"

#include <gtk/gtk.h>

/**
 * Evaluate link
 *
 * @param zathura Zathura instance
 * @param link The link
 */
void zathura_link_evaluate(zathura_t* zathura, zathura_link_t* link);

/**
 * Display a link using girara_notify
 *
 * @param zathura Zathura instance
 * @param link The link
 */
void zathura_link_display(zathura_t* zathura, zathura_link_t* link);

/**
 * Copy a link into the clipboard using and display it using girara_notify
 *
 * @param zathura Zathura instance
 * @param link The link
 * @param selection target clipboard
 */
void zathura_link_copy(zathura_t* zathura, zathura_link_t* link, GdkClipboard* selection);

#endif