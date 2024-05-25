/* game-page.vala
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
    [GtkTemplate (ui = "/io/github/Storm/ui/game-page.ui")]
    public class GamePage : Adw.NavigationPage {
        [GtkChild]
        public unowned Gtk.Box map_box;

        public Board opponent_map { get; construct; }

        public new unowned Board board { get; construct; }

        public GamePage (Board opponent_map) {
            Object (opponent_map: opponent_map);
        }

        construct {
            this.board = new Board (player.name, player.ships);
            this.map_box.append (this.board);
            this.map_box.append (this.opponent_map);
            this.board.show_ships ();
        }
    }
}