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
        public Player player { get; construct; }

        public Map (Player player) {
            Object (player: player);
        }

        construct {
            this.name_row.set_subtitle (this.player.name);
            this.ships = new Gee.ArrayList<char> ();

            for (int i = 0; i < LINE_COUNT; i++) {
                for (int j = 0; j < LINE_COUNT; j++) {
                    var cell = new Cell (i, j);
                    cell.button.clicked.connect (() => {
                        var element = cell.to_element ();
                        this.player.send (element);
                    });
                    this.grid.attach (cell, i, j);
                    this.ships.add (' ');
                }
            }
        }

        public GXml.Element? to_element () {
            try {
                var element = new GXml.Element ();
                element.set_attribute ("String", (string) this.ships.to_array ());
                element.initialize ("Ships");
                return element;
            } catch (Error e) {
                warning (@"Failed to create xml element. $(e.message)");
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

        private void show_ships () {
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