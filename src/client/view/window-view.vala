/* window-view.vala
 *
 * Copyright 2024 khaustovdn
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Storm {
    [GtkTemplate (ui = "/io/github/Storm/ui/window-view.ui")]
    public class WindowView : Adw.ApplicationWindow, INavigationService {
        [GtkChild (name = "navigation-view")]
        public unowned Adw.NavigationView navigation { get; }
        [GtkChild (name = "main-menu-view")]
        public unowned MainMenuView main_menu;

        public WindowView (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.add_breakpoint (this.main_menu.breakpoint);
        }
    }
}