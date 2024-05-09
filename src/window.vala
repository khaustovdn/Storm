/* window.vala
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
    [GtkTemplate (ui = "/io/github/Storm/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned ListRow settings_row;
        [GtkChild]
        public unowned Gtk.Button start_button;
        [GtkChild]
        public unowned GameSetupPage game_setup_page;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            this.add_breakpoint (game_setup_page.breakpoint);

            this.settings_row.activated.connect (() => {
                print ("%d, %d\n", this.get_width (), this.get_height ());
            });

            start_button.clicked.connect (() => {
                try {
                    SocketService service = new SocketService ();
                    service.add_inet_port (3333, null);
                    service.incoming.connect (on_incoming_connection);
                    service.start ();
                } catch (Error e) {
                    printerr ("%s\n", e.message);
                }
            });
        }

        private bool on_incoming_connection (SocketConnection connection, Object? source_object) {
            print ("Got incoming connection\n");
            process_request.begin (connection);
            return true;
        }

        private async void process_request (SocketConnection connection) {
            try {
                DataInputStream input_stream = new DataInputStream (connection.input_stream);
                DataOutputStream output_stream = new DataOutputStream (connection.output_stream);
                string request = yield input_stream.read_line_async (Priority.HIGH_IDLE);

                output_stream.put_string ("Got: %s\n".printf (request));
            } catch (Error e) {
                printerr ("%s\n", e.message);
            }
        }
    }
}