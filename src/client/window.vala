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
    private const uint16 PORT = 3333;
    private const string HOST = "127.0.0.1";

    private enum PlayerRole {
        CREATOR,
        PLAYER
    }

    [GtkTemplate (ui = "/io/github/Storm/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned EntryRow player_name_row;
        [GtkChild]
        public unowned EntryRow room_port_row;
        [GtkChild]
        public unowned ListRow settings_row;
        [GtkChild]
        public unowned Adw.ComboRow connection_type_row;
        [GtkChild]
        public unowned Gtk.Button room_button;
        [GtkChild]
        public unowned Adw.NavigationView navigation_view;
        [GtkChild]
        public unowned Adw.Breakpoint breakpoint;

        public Gee.ArrayList<Room> rooms { get; construct; }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.player_name_row.changed.connect (this.validate_row);
            this.room_port_row.changed.connect (this.validate_row);
            this.room_button.clicked.connect (this.client_connect_handle);
            this.room_button.set_sensitive (false);
            this.rooms = new Gee.ArrayList<Room> ();
        }

        private void validate_row () {
            var is_valid_player_name_row = this.player_name_row.validate_row ();
            var is_valid_room_port_row = this.room_port_row.validate_numeric_row ();
            var is_active = is_valid_player_name_row && is_valid_room_port_row;
            this.room_button.set_sensitive (is_active);
        }

        private void client_connect_handle () {
            var name = this.player_name_row.get_text ();
            var room_port = this.room_port_row.get_text ();
            Room? room = null;

            if (this.connection_type_row.get_selected () == PlayerRole.CREATOR) {
                // Need to check if a room with the specified port does not exist
                room = new Room (room_port);
            } else if (this.connection_type_row.get_selected () == PlayerRole.PLAYER) {
                room = this.rooms.first_match (x => x.port == room_port);
            }

            if (room != null) {
                // Need to create a game class with rooms and all connected players to handle all actions
                var player = new Player (name, room, HOST, PORT);
                var room_page = new RoomPage (player);
                this.add_breakpoint (room_page.breakpoint);
                this.navigation_view.push (room_page);
            } else {
                warning ("Failed to connect to the room");
            }
        }
    }
}