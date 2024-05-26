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
        public Gee.ArrayList<char> ships { get; private set; }
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
                    var document = new GXml.Document ();
                    document.read_from_string (msg);
                    var element = document.first_element_child;
                    switch (element.local_name) {
                    case "connection_validation" :
                        this.handle_connection_validation (document);
                        break;
                    case "room_connection":
                        this.handle_room_connection (document);
                        break;
                    case "construct_board":
                        this.handle_construct_map (document);
                        break;
                    case "attack":
                        this.handle_attack (document);
                        break;
                    case "exit":
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

        private void handle_connection_validation (GXml.Document document) {
            try {
                var element = document.first_element_child;
                string player_name = element.get_attribute ("player_name");
                string room_port = element.get_attribute ("room_port");
                string connection_type = element.get_attribute ("connection_type");

                if (this.server.players.all_match (p => p.name != player_name)) {
                    if (connection_type == PlayerRole.CREATOR.to_string () &&
                        this.server.rooms.all_match (x => x.port != room_port)) {
                        element.set_attribute ("value", "true");
                    } else if (connection_type == PlayerRole.PLAYER.to_string () &&
                               this.server.rooms.any_match (x => x.port == room_port)) {
                        element.set_attribute ("value", "true");
                    } else {
                        element.set_attribute ("value", "false");
                    }
                } else {
                    element.set_attribute ("value", "false");
                }

                var result = new GXml.Document ();
                result.read_from_string (element.write_string ());
                send (result);
            } catch (Error e) {
                warning (@"Connection failed to be validated. $(e.message)");
            }
        }

        private void handle_room_connection (GXml.Document document) {
            var element = document.first_element_child;
            string room_port = element.get_attribute ("room_port");
            this.name = element.get_attribute ("player_name");

            if (this.server.rooms.any_match (x => x.port == room_port)) {
                room = this.server.rooms.first_match (x => x.port == room_port);
            } else {
                room = new Room (room_port);
                this.server.rooms.add (room);
            }

            if (room.players.size == 2) {
                room.switcher = false;
            }

            this.server.players.add (this);
            room.add_player (this);
        }

        private void handle_construct_map (GXml.Document document) {
            var element = document.first_element_child;
            this.ships = new Gee.ArrayList<char> ();
            var ships_str = element.get_attribute ("ships");
            for (int i = 0; i < ships_str.length; i++) {
                this.ships.add (ships_str.get (i));
            }

            if (room.players.size == 2 && room.players.all_match (x => x.ships != null && x.ships.size > 0 && x.ships.contains ('#'))) {
                this.send (this.room.players.first_match (x => x != this).to_document ());
                this.room.players.first_match (x => x != this).send (this.room.players.first_match (x => x == this).to_document ());
            }
        }

        private void handle_attack (GXml.Document document) {
            try {
                var element = document.first_element_child;
                var position_x = int.parse (element.get_attribute ("position_x"));
                var position_y = int.parse (element.get_attribute ("position_y"));
                var attack_document = new GXml.Document ();
                var attack_element = new GXml.Element ();
                if (((room.switcher == false && this == room.players.first ()) || (room.switcher == true && this == room.players.last ()))) {
                    if (this.room.players.first_match (x => x != this).ships.get (position_y * 10 + position_x) == '#') {
                        attack_element.set_attribute ("value", "true");
                        this.room.players.first_match (x => x != this).ships.set (position_y * 10 + position_x, '1');
                    } else if (this.room.players.first_match (x => x != this).ships.get (position_y * 10 + position_x) == '0') {
                        attack_element.set_attribute ("value", "false");
                        this.room.players.first_match (x => x != this).ships.set (position_y * 10 + position_x, '2');
                        room.switcher = !room.switcher;
                    }
                } else {
                    attack_element.set_attribute ("value", "skip");
                }
                for (int i = 0; i < 10 * 10; i += 10) {
                    message ((string) this.room.players.first_match (x => x != this).ships[i: i + 10].to_array ());
                }
                attack_element.initialize ("attack");
                attack_document.read_from_string (attack_element.write_string ());
                this.send (attack_document);
            } catch (Error e) {
                warning (@"Failed to establish a connection for the attack. $(e.message)");
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