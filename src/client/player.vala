/* player.vala
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
    public class Player : Object {
        public string host { private get; construct; }
        public uint16 port { private get; construct; }
        public string name { get; set; }
        public Gee.ArrayList<char> ships { get; set; }
        private SocketClient socket_client { get; set; }
        private SocketConnection socket_connection { get; set; }
        private DataInputStream input_stream { get; set; }
        private DataOutputStream output_stream { get; set; }

        public Player (string host, uint16 port) {
            Object (host: host, port: port);
        }

        construct {
            new Thread<void> ("connection_thread", this.run);
        }

        private void run () {
            try {
                var resolver = Resolver.get_default ();
                var addresses = resolver.lookup_by_name (this.host);
                var address = addresses.nth_data (0);

                this.socket_client = new SocketClient ();
                this.socket_connection = this.socket_client.connect (new InetSocketAddress (address, this.port));
                this.input_stream = new DataInputStream (this.socket_connection.input_stream);
                this.output_stream = new DataOutputStream (this.socket_connection.output_stream);

                new MainLoop ().run ();
            } catch (Error e) {
                warning (@"Connection to server failed. $(e.message)");
            } finally {
                this.close_connection ();
            }
        }

        public bool send (GXml.Document document) {
            try {
                if (document != null) {
                    var msg = document.write_string ().replace ("\n", "");
                    this.output_stream.write (@"$msg\n".data);
                    this.output_stream.flush ();
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

        public string ? receive () {
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

        private void close_connection () {
            try {
                this.socket_connection.close ();
            } catch (IOError e) {
                warning (@"Failed to close the connection to the server. $(e.message)");
            }
        }
    }
}