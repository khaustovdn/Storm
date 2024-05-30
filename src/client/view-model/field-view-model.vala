/* field-view-model.vala
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
    public class FieldViewModel : Object {
        public FieldViewModel() {
            Object();
        }

        public void attack(Gtk.Image image, int column, int row) {
            Storm.game.client.send(Storm.game.client.serialize("attack", "column", column.to_string(), "row", row.to_string()));
            var is_attacked_msg = Storm.game.client.receive();
            try {
                var is_attacked_doc = new GXml.Document.from_string(is_attacked_msg);
                if (is_attacked_doc != null) {
                    var is_attacked = is_attacked_doc.first_element_child.get_attribute("value");
                    if (is_attacked != null) {
                        if (is_attacked == "true") {
                            image.set_from_resource("/io/github/Storm/attacked.svg");
                        } else if (is_attacked == "false") {
                            image.set_from_resource("/io/github/Storm/missed.svg");
                        }
                    }
                    if (is_attacked_doc.first_element_child.local_name == "win-attack") {
                        message("win");
                    }
                }
            } catch (Error e) {
            }
        }
    }
}