/* board-view.vala
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
    [GtkTemplate (ui = "/io/github/Storm/ui/board-view.ui")]
    public class BoardView : Gtk.Frame {
        [GtkChild (name = "name-row")]
        public unowned Adw.ActionRow name_row;
        [GtkChild (name = "grid")]
        public unowned Gtk.Grid grid;

        public new string name { get; construct; }
        public BoardViewModel view_model { private get; construct; }

        public BoardView (string name) {
            Object (name: name);
        }

        construct {
            this.place_grid ();
            this.name_row.set_subtitle (this.name);
            this.view_model = new BoardViewModel (this.name);
        }

        public void place_ships () {
            this.view_model.place_ships ();
            this.show_ships ();
        }

        private void show_ships () {
            for (var i = 0; i < LINE_COUNT; i++) {
                for (var j = 0; j < LINE_COUNT; j++) {
                    if (this.view_model.board.get (j * 10 + i) == FieldFlag.SHIP) {
                        this.grid.get_child_at (i, j).add_css_class ("ship");
                    }
                }
            }
        }

        private void place_grid () {
            for (int i = 0; i < LINE_COUNT; i++) {
                for (int j = 0; j < LINE_COUNT; j++) {
                    this.grid.attach (new FieldView (i, j), i, j);
                }
            }
        }
    }
}