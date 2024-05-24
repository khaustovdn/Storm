/* player-handler.vala
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
    public class PlayerHandler : Object {
        public string name { get; construct; }
        // public Room room { get; construct; }
        // public Map map { get; construct; }
        public Server server { get; construct; }
        public SocketConnection socket_connection { get; construct; }
        private DataInputStream input_stream { get; set; }
        private DataOutputStream output_stream { get; set; }

        public PlayerHandler (Server server, SocketConnection socket_connection) {
            Object (/*server: server, */ socket_connection: socket_connection);
        }

        construct {
            new Thread<void> ("player_thread", this.run);
        }

        private void run () {
            this.input_stream = new DataInputStream (this.socket_connection.input_stream);
            this.output_stream = new DataOutputStream (this.socket_connection.output_stream);
            // lock (this.room) {
            // this.room.add_player (this);
            // this.send (this.to_element ());
            // }

            while (this.socket_connection.is_connected ()) {
                var msg = this.receive ();
                this.process_message (msg);
            }
            // this.room.remove_player (this);
            this.close_connection ();
        }

        public GXml.Element? to_element () {
            try {
                var element = new GXml.Element ();
                element.set_attribute ("Name", this.name);
                // element.set_attribute ("RoomPort", this.room.port);
                // element.set_attribute ("ServerHost", this.host);
                // element.set_attribute ("ServerPort", this.port.to_string ());
                element.initialize ("Player");
                return element;
            } catch (Error e) {
                warning (@"Failed to create xml element. $(e.message)");
            }
            return null;
        }

        private bool process_message (string? msg) {
            if (msg != null) {
                try {
                    var element = new GXml.Element ();
                    element.read_from_string (msg.strip ().replace ("\n", " "));
                    // do
                    return true;
                } catch (Error e) {
                    warning (@"Can't read the message. $(e.message)");
                }
            } else {
                warning ("An empty message was received.");
                this.close_connection ();
            }
            return false;
        }

        public bool send (GXml.Element element) {
            try {
                if (element != null) {
                    var msg = element.write_string ().strip ().replace ("\n", "");
                    this.output_stream.write (@"$msg\n".data);
                    message ("Message sent.");
                    return true;
                } else {
                    warning (@"Unable to process an empty object.");
                }
            } catch (Error e) {
                warning (@"Failed to send message. $(e.message)");
                this.close_connection ();
            }
            return false;
        }

        private string ? receive () {
            try {
                message ("Message received.");
                var msg = this.input_stream.read_line ();
                message (msg);
                return msg;
            } catch (Error e) {
                warning (@"Failed to receive the message. $(e.message)");
                this.close_connection ();
            }
            return null;
        }

        public void close_connection () {
            try {
                this.socket_connection.close ();
            } catch (IOError e) {
                warning (@"Failed to close the connection to the server. $(e.message)");
            }
        }
    }
}