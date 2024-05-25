/* cell.vala
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
    [GtkTemplate (ui = "/io/github/Storm/ui/cell.ui")]
    public class Cell : Gtk.Frame {
        [GtkChild]
        public unowned Gtk.Button button;

        public int row { get; construct; }
        public int column { get; construct; }

        public Cell (int row, int column) {
            Object (row: row, column: column);
        }

        construct {
            this.set_can_focus (false);
            this.set_name ("cell" + row.to_string () + column.to_string ());
            this.add_css_class ("cell");
        }

        public GXml.Document? to_document () {
            try {
                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("position_x", this.row.to_string ());
                element.set_attribute ("position_y", this.column.to_string ());
                element.initialize ("atack");
                document.read_from_string (element.write_string ());
                return document;
            } catch (Error e) {
                warning (@"Failed to create xml document. $(e.message)");
            }
            return null;
        }
    }
}