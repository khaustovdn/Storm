/* map.vala
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

    [GtkTemplate (ui = "/io/github/Storm/ui/map.ui")]
    public class Map : Gtk.Frame {
        [GtkChild]
        public unowned Adw.ActionRow name_row;
        [GtkChild]
        public unowned Gtk.Grid grid;

        public Gee.ArrayList<char> ships { get; construct; }

        public Map (string name, Gee.ArrayList<char> ships) {
            Object (ships: ships);
            this.name_row.set_subtitle (name);
        }

        construct {
            for (int i = 0; i < LINE_COUNT; i++) {
                for (int j = 0; j < LINE_COUNT; j++) {
                    var cell = new Cell (i, j);
                    if (name_row.get_subtitle () != player.name) {
                        cell.button.clicked.connect (() => {
                            var document = cell.to_document ();
                            player.send (document);
                            var msg = player.receive ();
                            var atack_document = new GXml.Document ();
                            atack_document.read_from_string (msg);
                            if (atack_document.first_element_child.get_attribute ("value") == "true") {
                                cell.add_css_class ("ship");
                            } else {
                                cell.add_css_class ("empty");
                            }
                        });
                    }
                    this.grid.attach (cell, i, j);

                    if (this.ships.size != LINE_COUNT * LINE_COUNT) {
                        this.ships.add (' ');
                    }
                }
            }
        }

        public GXml.Document? to_document () {
            try {
                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("ships", (string) this.ships.to_array ());
                element.initialize ("set_map");
                document.read_from_string (element.write_string ());
                return document;
            } catch (Error e) {
                warning (@"Failed to create xml document. $(e.message)");
            }
            return null;
        }

        bool ship_is_good (int size, bool is_horiz, int row_top, int col_left) {
            if (is_horiz) {
                for (int i = int.max (0, row_top - 1); i <= int.min (9, row_top + 1); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (9, col_left + size); j++) {
                        if (ships[i * 10 + j] == '#')return false;
                    }
                }

                return true;
            } else {
                for (int i = int.max (0, row_top - 1); i <= int.min (9, row_top + size); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (9, col_left + 1); j++) {
                        if (ships[i * 10 + j] == '#')return false;
                    }
                }

                return true;
            }
        }

        void set_ship_with_size (int size) {
            Rand rand = new Rand ();
            bool is_horiz = (rand.next_int () % 2) == 0;
            int row_top = 0;
            int col_left = 0;

            do {
                do {
                    row_top = rand.int_range (0, 10);
                } while (!is_horiz && row_top > 10 - size);

                do {
                    col_left = rand.int_range (0, 10);
                } while (is_horiz && col_left > 10 - size);
            } while (!ship_is_good (size, is_horiz, row_top, col_left));

            if (is_horiz) {
                for (int j = col_left; j < col_left + size; j++) {
                    ships[row_top * 10 + j] = '#';
                }
            } else {
                for (int i = row_top; i < row_top + size; i++) {
                    ships[i * 10 + col_left] = '#';
                }
            }
        }

        public void create_ships () {
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
                    if (this.ships.get (i * LINE_COUNT + j) == '#') {
                        this.grid.get_child_at (j, i).add_css_class ("ship");
                    }
                }
            }
        }
    }
}