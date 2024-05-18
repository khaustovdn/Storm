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
        public unowned Adw.EntryRow player_name_row;
        [GtkChild]
        public unowned Adw.EntryRow game_id_row;
        [GtkChild]
        public unowned Adw.ComboRow connection_type_row;
        [GtkChild]
        public unowned Adw.NavigationView navigation_view;
        [GtkChild]
        public unowned ListRow settings_row;
        [GtkChild]
        public unowned Gtk.Button start_button;

        public GameSetupPage game_setup_page { get; default = new GameSetupPage (); }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.start_button.clicked.connect (client_connect_handle);
        }

        private void client_connect_handle () {
            if (connection_type_row.get_selected () == ConnectionType.CREATE) {
                long game_id = 0;
                if (game_id_row.get_text_length () > 0 && long.try_parse (game_id_row.get_text (), out game_id)) {
                    string user_name = this.player_name_row.get_text ();
                    if (user_name.length > 0) {
                        Game game = new Game (game_id);
                        Player player = new Player (user_name, game_id);
                        player.start ();
                        game.players.add (player);
                        navigation_view.push (game_setup_page);
                    } else {
                    }
                } else {
                }
            }
        }
    }
}