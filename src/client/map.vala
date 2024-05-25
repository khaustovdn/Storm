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
            Object (ships : ships);
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

        public void create_ships () {
            var rand = new Rand ();
            for (int i = 0; i < LINE_COUNT; i++) {
                this.ships.set (i * LINE_COUNT + rand.int_range (0, LINE_COUNT), '#');
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