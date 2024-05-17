/* window.vala
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
    private const uint16 PORT = 8080;

    private enum ConnectionType {
        CREATE,
        JOIN
    }

    [GtkTemplate (ui = "/io/github/Storm/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned Adw.NavigationView navigation_view;
        [GtkChild]
        public unowned ListRow settings_row;
        [GtkChild]
        public unowned Gtk.Button start_button;
        [GtkChild]
        public unowned GameSetupPage game_setup_page;
        [GtkChild]
        public unowned Adw.ComboRow connection_type_row;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.add_breakpoint (this.game_setup_page.breakpoint);

            this.settings_row.activated.connect (() => {
                print ("%d, %d\n", this.get_width (), this.get_height ());
            });
        }
    }
}