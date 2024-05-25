/* room-page.vala
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
    [GtkTemplate (ui = "/io/github/Storm/ui/room-page.ui")]
    public class RoomPage : Adw.NavigationPage {
        [GtkChild]
        public unowned Adw.NavigationView navigation_view;
        [GtkChild]
        public unowned Gtk.Button random_button;
        [GtkChild]
        public unowned Gtk.Button apply_button;
        [GtkChild]
        public unowned Gtk.Box map_box;

        public Adw.Breakpoint breakpoint { get; construct; }
        public new unowned Map map { get; construct; }

        public RoomPage () {
            Object ();
        }

        construct {
            this.map = new Map (player.name, player.ships);
            this.map_box.prepend (this.map);
            this.random_button.clicked.connect (this.map.create_ships);
            this.breakpoint = new Adw.Breakpoint ((Adw.BreakpointCondition.parse ("min-width: 860px")));
            this.apply_button.clicked.connect (() => {
                player.send (map.to_document ());
                var msg = player.receive ();
                var document = new GXml.Document ();
                document.read_from_string (msg);
                var game_page = new GamePage (new Map (document.first_element_child.get_attribute ("player_name"), new Gee.ArrayList<char> ()));
                this.breakpoint.add_setter (game_page.map_box, "orientation", Gtk.Orientation.HORIZONTAL);
                this.navigation_view.push (game_page);
            });
        }
    }
}