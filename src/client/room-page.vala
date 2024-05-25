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

        public Adw.Breakpoint breakpoint { get; private set; }
        private unowned Board board { get; set; }

        public RoomPage () {
            Object ();
        }

        construct {
            this.setup_board ();
            this.setup_breakpoint ();
            this.connect_signals ();
        }

        private void setup_board () {
            this.board = new Board (player.name, player.ships);
            this.map_box.prepend (this.board);
        }

        private void setup_breakpoint () {
            this.breakpoint = new Adw.Breakpoint (Adw.BreakpointCondition.parse ("min-width: 860px"));
        }

        private void connect_signals () {
            this.random_button.clicked.connect (() => {
                this.board.create_ships ();
                this.apply_button.set_sensitive (true);
            });
            this.apply_button.clicked.connect (this.handle_apply_button_click);
        }

        private void handle_apply_button_click () {
            if (player.ships.contains ('#')) {
                player.send (board.to_document ());

                try {
                    var msg = player.receive ();
                    var document = new GXml.Document ();
                    document.read_from_string (msg);
                    var player_name = document.first_element_child.get_attribute ("player_name");
                    var new_board = new Board (player_name, new Gee.ArrayList<char> ());
                    this.load_game_page (new_board);
                } catch (Error e) {
                    warning (@"Failed to get the data to start the game. $(e.message)");
                }
            }
        }

        private void load_game_page (Board board) {
            var game_page = new GamePage (board);
            this.breakpoint.add_setter (game_page.map_box, "orientation", Gtk.Orientation.HORIZONTAL);
            this.navigation_view.push (game_page);
        }
    }
}