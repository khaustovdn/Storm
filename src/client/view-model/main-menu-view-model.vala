/* main-menu-view-model.vala
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
    public class MainMenuViewModel : Object {
        public INavigationService service { get; construct; }
        public MainMenu model { get; construct; }

        public MainMenuViewModel (INavigationService service) {
            Object (service: service);
        }

        construct {
            this.model = new MainMenu ();
        }

        public void show_ship_placement_view (string name, string port, ConnectionFlag type) {
            if (is_valid_input (name, port, type)) {
                this.model.show_ship_placement_view (this.service, name, port, type);
            } else {
                warning ("Invalid data");
            }
        }

        public void close_ship_placement_view () {
            this.model.close_ship_placement_view ();
        }

        public bool is_valid_input (string name, string port, ConnectionFlag type) {
            return is_valid_name (name) && is_valid_port (port, type);
        }

        private bool is_valid_name (string name) {
            if (name.length == 0) {
                return false;
            }
            if (is_name_unique (name)) {
                return true;
            }
            return false;
        }

        private bool is_valid_port (string port, ConnectionFlag type) {
            if (port.length == 0) {
                return false;
            }
            if (is_port_unique (port, type) && is_port_number (port)) {
                return true;
            }
            return false;
        }

        private bool is_name_unique (string name) {
            return this.model.is_name_unique (name);
        }

        private bool is_port_unique (string port, ConnectionFlag type) {
            return this.model.is_port_unique (port, type);
        }

        private bool is_port_number (string? port) {
            return long.try_parse (port, null);
        }
    }
}