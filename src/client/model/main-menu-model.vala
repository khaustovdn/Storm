/* main-window-model.vala
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
    public class MainMenu : Object {
        public MainMenu () {
            Object ();
        }

        public bool ? is_name_unique (string name) {
            Storm.game.client.send (Storm.game.client.serialize ("unique-name", "name", name));
            try {
                var unique_name_msg = Storm.game.client.receive ();
                var doc = new GXml.Document.from_string (unique_name_msg);
                return bool.parse (doc.first_element_child.get_attribute ("is-unique"));
            } catch (Error e) {
                warning (@"Failed to deserialize the document $(e.message)");
                return null;
            }
        }

        public bool ? is_port_unique (string port, ConnectionFlag type) {
            Storm.game.client.send (Storm.game.client.serialize ("unique-port", "port", port, "type", type.to_string ()));
            try {
                var unique_port_msg = Storm.game.client.receive ();
                var doc = new GXml.Document.from_string (unique_port_msg);
                return bool.parse (doc.first_element_child.get_attribute ("is-unique"));
            } catch (Error e) {
                warning (@"Failed to deserialize the document $(e.message)");
                return null;
            }
        }

        public void show_ship_placement_view (INavigationService service, string name, string port, ConnectionFlag type) {
            Storm.game.player = new Player (name);
            Storm.game.client
             .send (Storm.game.client
                     .serialize ("ship-placement",
                                 "name", name,
                                 "port", port,
                                 "type", type.to_string ()));
            var view = new ShipPlacementView (service);
            service.navigation.push (view);
        }

        public void close_ship_placement_view () {
            Storm.game.client.send (Storm.game.client.serialize ("end"));
        }
    }
}