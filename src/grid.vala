/* grid.vala
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
    public class Grid : Gtk.DrawingArea {
        public int line_count { get; construct; default = 1; }
        public Gee.ArrayList<Point> cells { get; default = new Gee.ArrayList<Point> (); }

        public Grid () {
            Object ();
        }

        construct {
            this.set_draw_func (this.draw);
            Gtk.GestureClick click = new Gtk.GestureClick ();
            click.pressed.connect (click_handler);
            this.add_controller (click);
        }

        private void click_handler (int n_press, double x, double y) {
        }

        private void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            this.draw_grid (drawing_area, cairo, width, height);
            this.draw_values (drawing_area, cairo, width, height);
        }

        private void draw_values (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            cairo.set_font_size (12);
            cairo.set_source_rgba (0.5, 0.5, 0.5, 1.0);


            for (int i = 1; i < this.line_count; i++) {
                cairo.move_to (width * i / this.line_count + width / (this.line_count * 2) - (width % this.line_count) / 2, height / (this.line_count * 2) + (height % this.line_count) / 2);
                cairo.show_text (((int) i - 1 + 'a').to_string ("%c"));
                cairo.move_to (width / (this.line_count * 2) - (width % this.line_count) / 2 - (i.to_string ().length - 1) * 4, height * i / this.line_count + height / (this.line_count * 2) + (height % this.line_count) / 2);
                cairo.show_text (i.to_string ());
            }
        }

        private void draw_grid (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            cairo.set_line_width (0.2);
            cairo.set_source_rgba (0.5, 0.5, 0.5, 1.0);
            for (int i = 0; i < this.line_count; i++) {
                cairo.move_to (width * i / this.line_count, 0);
                cairo.line_to (width * i / this.line_count, height);
                cairo.move_to (0, height * i / this.line_count);
                cairo.line_to (width, height * i / this.line_count);
            }
            cairo.stroke ();
        }
    }
}