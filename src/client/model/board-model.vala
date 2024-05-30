/* board-model.vala
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
    public class Board : Gee.ArrayList<FieldFlag> {
        public string name { get; construct; }

        public Board (string name) {
            Object (name: name);
        }

        construct {
            for (var i = 0; i < LINE_COUNT * LINE_COUNT; i++) {
                this.add (FieldFlag.WATER);
            }
        }

        private bool ship_is_good (int size, bool is_horiz, int row_top, int col_left) {
            if (is_horiz) {
                for (int i = int.max (0, row_top - 1); i <= int.min (LINE_COUNT - 1, row_top + 1); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (LINE_COUNT - 1, col_left + size); j++) {
                        if (this.get (i * LINE_COUNT + j) == FieldFlag.SHIP)return false;
                    }
                }
                return true;
            } else {
                for (int i = int.max (0, row_top - 1); i <= int.min (LINE_COUNT - 1, row_top + size); i++) {
                    for (int j = int.max (0, col_left - 1); j <= int.min (LINE_COUNT - 1, col_left + 1); j++) {
                        if (this.get (i * LINE_COUNT + j) == FieldFlag.SHIP)return false;
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
            } while (!this.ship_is_good (size, is_horiz, row_top, col_left));

            if (is_horiz) {
                for (int j = col_left; j < col_left + size; j++) {
                    this.set (row_top * LINE_COUNT + j, FieldFlag.SHIP);
                }
            } else {
                for (int i = row_top; i < row_top + size; i++) {
                    this.set (i * LINE_COUNT + col_left, FieldFlag.SHIP);
                }
            }
        }

        public void place_ships () {
            for (int i = 0; i < 1; i++) {
                this.set_ship_with_size (4);
            }
            for (int i = 0; i < 2; i++) {
                this.set_ship_with_size (3);
            }
            for (int i = 0; i < 3; i++) {
                this.set_ship_with_size (2);
            }
            for (int i = 0; i < 4; i++) {
                this.set_ship_with_size (1);
            }
        }

        public void send_board () {
            var number_string = "";
            this.map<int> (x => (int) x).@foreach (x => {
                number_string += x.to_string ();
                return true;
            });
            Storm.game.client.send (Storm.game.client.serialize ("board", "list", number_string));
        }
    }
}