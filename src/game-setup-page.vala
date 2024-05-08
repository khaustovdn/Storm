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
    public unowned Adw.NavigationView navigation_view;
    [GtkChild]
    public unowned Gtk.Button random_button;
    [GtkChild]
    public unowned Gtk.Button apply_button;

    public Player player { get; default = new Player (); }
    public GamePage game_page { get; construct; }
    public Adw.Breakpoint breakpoint { get; construct; }

    public GameSetupPage () {
      Object ();
    }

    construct {
      this.game_page = new GamePage (player);
      this.navigation_view.add (this.game_page);
      this.breakpoint = new Adw.Breakpoint ((Adw.BreakpointCondition.parse ("min-width: 860px")));
      this.breakpoint.add_setter (this.game_page.field, "orientation", Gtk.Orientation.HORIZONTAL);

      this.random_button.clicked.connect (() => {
        this.player.random_set ();
        this.show_ships ();
      });

      this.apply_button.clicked.connect (() => {

        this.game_page.show_ships ();
      });
    }

    public void show_ships () {
      foreach (var item in player.ships) {
        this.board.get_child_at (item.x, item.y).add_css_class ("ship");
      }
    }
  }
}