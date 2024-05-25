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

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.player_name_row.changed.connect (this.validate_row);
            this.room_port_row.changed.connect (this.validate_row);
            this.connection_type_row.notify["selected"].connect (this.validate_row);
            this.room_button.clicked.connect (this.handle_connection);
            this.room_button.set_sensitive (false);
            player = new Player (HOST, PORT);
        }

        private void validate_row () {
            try {
                var is_valid_player_name_row = this.player_name_row.validate_row ();
                var is_valid_room_port_row = this.room_port_row.validate_numeric_row ();
                var is_active = is_valid_player_name_row && is_valid_room_port_row;

                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("player_name", this.player_name_row.text);
                element.set_attribute ("room_port", this.room_port_row.text);
                element.set_attribute ("connection_type", ((PlayerRole) this.connection_type_row.get_selected ()).to_string ());
                element.initialize ("connection_validation");
                document.read_from_string (element.write_string ());
                player.send (document);

                var msg = player.receive ();
                this.room_button.set_sensitive (is_active && msg.contains ("true"));
            } catch (Error e) {
                warning (@"Connection failed to be validated. $(e.message)");
            }
        }

        private void handle_connection () {
            try {
                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("player_name", this.player_name_row.text);
                element.set_attribute ("room_port", this.room_port_row.text);
                element.initialize ("room_connection");
                document.read_from_string (element.write_string ());
                player.send (document);

                player.name = this.player_name_row.text;
                player.ships = new Gee.ArrayList<char> ();

                var room_page = new RoomPage ();
                this.add_breakpoint (room_page.breakpoint);
                this.navigation_view.push (room_page);
            } catch (Error e) {
                warning (@"Connection to the room failed. $(e.message)");
            }
        }
    }
}