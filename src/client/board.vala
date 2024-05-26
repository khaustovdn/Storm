/* board.vala
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
    private const uint16 LINE_COUNT = 10;

    [GtkTemplate (ui = "/io/github/Storm/ui/board.ui")]
    public class Board : Gtk.Frame {
        [GtkChild]
        public unowned Adw.ActionRow name_row;
        [GtkChild]
        public unowned Gtk.Grid grid;

        public Gee.ArrayList<char> ships { get; set; }

        public Board (string player_name, Gee.ArrayList<char>? ships) {
            Object (ships : ships);
            this.initialize (player_name);
        }

        private void initialize (string player_name) {
            this.name_row.set_subtitle (player_name);
            this.construct_ships ();

            for (int i = 0; i < LINE_COUNT; i++) {
                for (int j = 0; j < LINE_COUNT; j++) {
                    this.setup_field (i, j, player_name);
                }
            }
        }

        private void setup_field (int i, int j, string player_name) {
            var field = new Field (i, j);
            field.button.clicked.connect (() => field.handle_click (player_name));
            this.grid.attach (field, i, j);
        }

        public GXml.Document? to_document () {
            try {
                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("ships", (string) this.ships.to_array ());
                element.initialize ("construct_board");
                document.read_from_string (element.write_string ());
                return document;
            } catch (Error e) {
                warning (@"Failed to create xml document. $(e.message)");
            }
            return null;
        }

        private bool ship_is_good (int size, bool is_horiz, int row_top, int col_left) {
            if (is_horiz) {
                for (int i = int.max (0, row_top - 1); i <= int.min (LINE_COUNT - 1, row_top + 1); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (LINE_COUNT - 1, col_left + size); j++) {
                        if (this.ships.get (i * LINE_COUNT + j) == '#')return false;
                    }
                }
                return true;
            } else {
                for (int i = int.max (0, row_top - 1); i <= int.min (LINE_COUNT - 1, row_top + size); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (LINE_COUNT - 1, col_left + 1); j++) {
                        if (this.ships.get (i * LINE_COUNT + j) == '#')return false;
                    }
                }
                return true;
            }
        }

        private void set_ship_with_size (int size) {
            var rand = new Rand ();
            var is_horiz = (rand.next_int () % 2) == 0;
            var row_top = 0;
            var col_left = 0;

            do {
                do {
                    row_top = rand.int_range (0, LINE_COUNT);
                } while (!is_horiz && row_top > LINE_COUNT - size);

                do {
                    col_left = rand.int_range (0, LINE_COUNT);
                } while (is_horiz && col_left > LINE_COUNT - size);
            } while (!ship_is_good (size, is_horiz, row_top, col_left));

            if (is_horiz) {
                for (int j = col_left; j < col_left + size; j++) {
                    this.ships.set (row_top * LINE_COUNT + j, '#');
                }
            } else {
                for (int i = row_top; i < row_top + size; i++) {
                    this.ships.set (i * LINE_COUNT + col_left, '#');
                }
            }
        }

        public void construct_ships () {
            if (this.ships == null || this.ships.size < LINE_COUNT * LINE_COUNT - 1) {
                this.ships = new Gee.ArrayList<char> ();
                for (int i = 0; i < LINE_COUNT * LINE_COUNT; i++) {
                    this.ships.add ('0');
                }
            }
        }

        public void create_ships () {
            this.construct_ships ();

            for (int i = 0; i < 1; i++) {
                set_ship_with_size (4);
            }
            for (int i = 0; i < 2; i++) {
                set_ship_with_size (3);
            }
            for (int i = 0; i < 3; i++) {
                set_ship_with_size (2);
            }
            for (int i = 0; i < 4; i++) {
                set_ship_with_size (1);
            }

            this.show_ships ();
        }

        public void show_ships () {
            for (int i = 0; i < LINE_COUNT; i++) {
                for (int j = 0; j < LINE_COUNT; j++) {
                    switch (this.ships.get (i * LINE_COUNT + j)) {
                    case '#' :
                        this.grid.get_child_at (j, i).add_css_class ("ship");
                        break;
                    case '1':
                        ((Field) this.grid.get_child_at (j, i)).image.set_from_resource ("/io/github/Storm/attacked.svg");
                        break;
                    case '2':
                        ((Field) this.grid.get_child_at (j, i)).image.set_from_resource ("/io/github/Storm/missed.svg");
                        break;
                    }
                }
            }
        }
    }
}