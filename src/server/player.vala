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
        public string name { get; private set; }
        public Room room { get; private set; }
        public Server server { get; construct; }
        public Gee.ArrayList<FieldFlag> board { get; private set; }
        public SocketConnection socket_connection { get; construct; }
        private DataInputStream input_stream { get; set; }
        private DataOutputStream output_stream { get; set; }

        public Player (Server server, SocketConnection socket_connection) {
            Object (server: server, socket_connection: socket_connection);
        }

        construct {
            new Thread<void> ("player_thread", this.run);
        }

        private void run () {
            this.input_stream = new DataInputStream (this.socket_connection.input_stream);
            this.output_stream = new DataOutputStream (this.socket_connection.output_stream);

            while (this.socket_connection.is_connected ()) {
                var msg = this.receive ();
                if (msg != null) {
                    this.process_message (msg);
                } else {
                    this.close_connection ();
                    break;
                }
            }
        }

        public GXml.Document? to_document () {
            try {
                var document = new GXml.Document ();
                var element = new GXml.Element ();
                element.set_attribute ("player_name", this.name);
                element.set_attribute ("room_port", this.room.port);
                element.initialize ("Player");
                document.read_from_string (element.write_string ());
                return document;
            } catch (Error e) {
                warning (@"Failed to create xml element. $(e.message)");
            }
            return null;
        }

        private bool process_message (string? msg) {
            if (msg != null) {
                try {
                    var document = new GXml.Document.from_string (msg);
                    switch (document.first_element_child.local_name) {
                    case "unique-name" :
                        this.name_uniqueness_check (document);
                        break;
                    case "unique-port":
                        this.port_uniqueness_check (document);
                        break;
                    case "ship-placement":
                        this.ship_placement (document);
                        break;
                    case "board":
                        this.place_ships (document);
                        break;
                    case "battle":
                        this.battle (document);
                        break;
                    case "attack":
                        this.attack (document);
                        break;
                    case "end":
                        this.handle_disconnect (document);
                        break;
                    }
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

        private void name_uniqueness_check (GXml.Document document) {
            var name = document.first_element_child.get_attribute ("name");
            var is_unique = this.server.players.all_match (x => x.name != name).to_string ();
            this.send (this.serialize (document.first_element_child.local_name, "is-unique", is_unique));
        }

        private void port_uniqueness_check (GXml.Document document) {
            string? port = document.first_element_child.get_attribute ("port");
            string? type = document.first_element_child.get_attribute ("type");

            bool is_unique = ((this.server.rooms.all_match (room => room.port != port) &&
                               type == ConnectionFlag.CREATE.to_string ())) ||
                (this.server.rooms.any_match (room => room.port == port) &&
                 this.server.rooms.first_match (room => room.port == port).players.size < 2 &&
                 type == ConnectionFlag.JOIN.to_string ());

            this.send (this.serialize (document.first_element_child.local_name, "is-unique", is_unique.to_string ()));
        }

        private void ship_placement (GXml.Document document) {
            var port = document.first_element_child.get_attribute ("port");
            this.name = document.first_element_child.get_attribute ("name");

            if (this.server.rooms.any_match (x => x.port == port)) {
                room = this.server.rooms.first_match (x => x.port == port);
            } else {
                room = new Room (port);
                this.server.rooms.add (room);
            }

            if (room.players.size == 2) {
                room.switcher = false;
            }

            this.server.players.add (this);
            room.add_player (this);
        }

        private void place_ships (GXml.Document document) {
            this.board = new Gee.ArrayList<FieldFlag> ();
            var ships_str = document.first_element_child.get_attribute ("list");
            for (int i = 0; i < ships_str.length; i++) {
                this.board.add ((FieldFlag) int.parse (ships_str.get (i).to_string ()));
            }
        }

        private void battle (GXml.Document document) {
            if (room.players.size == 2 && room.players.all_match (x => x.board != null && x.board.size > 0 && x.board.contains (FieldFlag.SHIP))) {
                this.send (this.serialize ("battle", "name", room.players.first_match (x => x != this).name));
            }
        }

        private void attack (GXml.Document document) {
            var element = document.first_element_child;
            var position_x = int.parse (element.get_attribute ("column"));
            var position_y = int.parse (element.get_attribute ("row"));
            if (((room.switcher == false && this == room.players.first ()) || (room.switcher == true && this == room.players.last ()))) {
                var is_attacked = false;
                if (this.room.players.first_match (x => x != this).board.get (position_y * 10 + position_x) == FieldFlag.SHIP) {
                    is_attacked = true;
                    this.room.players.first_match (x => x != this).board.set (position_y * 10 + position_x, FieldFlag.BUMP);
                    if (this.room.players.first_match (x => x != this).board.all_match (x => x != FieldFlag.SHIP)) {
                        this.send (this.serialize ("win-attack", "value", is_attacked.to_string ()));
                    }
                } else if (this.room.players.first_match (x => x != this).board.get (position_y * 10 + position_x) == FieldFlag.WATER) {
                    this.room.players.first_match (x => x != this).board.set (position_y * 10 + position_x, FieldFlag.BUI);
                    is_attacked = false;
                    room.switcher = !room.switcher;
                }
                this.send (this.serialize ("attack", "value", is_attacked.to_string ()));
            } else {
                this.send (this.serialize ("attack"));
            }
        }

        private void handle_disconnect (GXml.Document document) {
            this.server.players.remove (this);
            this.room.players.remove (this);
            if (this.room.players.size == 0) {
                this.server.rooms.remove (this.room);
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