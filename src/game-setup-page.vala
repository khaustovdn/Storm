/* game-setup-page.vala
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
  [GtkTemplate (ui = "/io/github/Storm/ui/game-setup-page.ui")]
  public class GameSetupPage : Adw.NavigationPage {
    [GtkChild]
    public unowned GameBoard board;
    [GtkChild]
    public unowned GamePage game_page;
    [GtkChild]
    public unowned Gtk.Button random_button;
    [GtkChild]
    public unowned Gtk.Button apply_button;

    public Adw.Breakpoint breakpoint { get; construct; }
    Player player = new Player ();

    public GameSetupPage () {
      Object ();
    }

    construct {
      this.random_button.clicked.connect (() => {
        foreach (var item in player.ships) {
          board.get_element (item.x, item.y).add_css_class ("ship");
        }
      });
      apply_button.clicked.connect (() => {
        game_page.player = player;
        foreach (var item in game_page.player.ships) {
          game_page.player_board.get_element (item.x, item.y).add_css_class ("ship");
        }
      });
      this.breakpoint = new Adw.Breakpoint ((Adw.BreakpointCondition.parse ("min-width: 860px")));
      this.breakpoint.add_setter (game_page.field, "orientation", Gtk.Orientation.HORIZONTAL);
    }
  }
}