/* game-board.vala
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
    public class GameBoard : Gtk.Grid  {
        public int line_count { get; construct; }

        public GameBoard (int line_count) {
            Object (line_count: line_count);
        }

        construct {
            this.setup ();
        }

        private void setup () {
            for (int i = 0; i < this.line_count; i++) {
                for (int j = 0; j < this.line_count; j++) {
                    Cell cell = new Cell (i, j);
                    this.attach (cell, i, j, 1, 1);
                }
            }
        }
    }
}