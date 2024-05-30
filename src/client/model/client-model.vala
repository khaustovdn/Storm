/* client-model.vala
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
    public class Client : Object {
        public string host { private get; construct; }
        public uint16 port { private get; construct; }

        public SocketClient socket_client { private get; construct; }
        public SocketConnection socket_connection { get; construct; }
        public DataInputStream input_stream { private get; construct; }
        public DataOutputStream output_stream { private get; construct; }

        public Client (string host, uint16 port) {
            Object (host: host, port: port);
        }

        construct {
            new Thread<void> ("client_thread", () => {
                try {
                    var resolver = Resolver.get_default ();
                    var addresses = resolver.lookup_by_name (this.host);
                    var address = addresses.nth_data (0);

                    this.socket_client = new SocketClient ();
                    this.socket_connection = this.socket_client.connect (new InetSocketAddress (address, this.port));
                    this.input_stream = new DataInputStream (this.socket_connection.input_stream);
                    this.output_stream = new DataOutputStream (this.socket_connection.output_stream);

                    Storm.game.state = Game.State.CONNECTED;
                    new MainLoop ().run ();
                } catch (Error e) {
                    warning (@"Connection to server failed. $(e.message)");
                }
            });
        }

        public GXml.Document? serialize (string localname, ...) {
            try {
                var list = va_list ();
                var doc = new GXml.Document ();
                var root = doc.create_element (localname);
                doc.append_child (root);
                while (true) {
                    var key = list.arg<string> ();
                    if (key == null) {
                        break;
                    }
                    var value = list.arg<string> ();
                    root.set_attribute (key, value);
                }
                return doc;
            } catch (Error e) {
                warning (@"Failed to serialize the object. $(e.message)");
                return null;
            }
        }

        public bool send (GXml.Document document) {
            try {
                if (document != null) {
                    var msg = document.write_string ().replace ("\n", "");
                    this.output_stream.write (@"$msg\n".data);
                    this.output_stream.flush ();
                    message ("Message sent.");
                    return false;
                } else {
                    warning (@"Unable to process an empty object.");
                }
            } catch (Error e) {
                warning (@"Failed to send message. $(e.message)");
                this.close_connection ();
            }
            return true;
        }

        public string ? receive () {
            try {
                message ("Message received.");
                var msg = this.input_stream.read_line ();
                return msg;
            } catch (Error e) {
                warning (@"Failed to receive the message. $(e.message)");
                this.close_connection ();
            }
            return null;
        }

        public bool close_connection () {
            try {
                if (this.socket_connection != null) {
                    if (this.socket_connection.is_connected ()) {
                        // notify the server when the connection to the client is closed
                        this.socket_connection.close ();
                        message ("Connection successfully closed ");
                    } else {
                        warning ("The connection has already been closed");
                    }
                } else {
                    warning ("There's no connection to close it");
                }
            } catch (IOError e) {
                warning (@"Сonnection closure error. $(e.message)");
                return true;
            }
            return false;
        }
    }
}