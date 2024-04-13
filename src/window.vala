/* window.vala
 *
 * Copyright 2024 khaustov
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Quarry {
    [GtkTemplate (ui = "/io/github/Quarry/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.Box simulation_box;
        [GtkChild]
        public unowned Adw.SpinRow timer_spin_row;
        [GtkChild]
        public unowned Gtk.Button simulate_button;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            simulate_button.clicked.connect (() => {
                simulate.begin ();
            });
        }

        public async void simulate () {
            int timer = (int) timer_spin_row.adjustment.value;

            Excavator excavator = new Excavator (0, new Gee.ArrayList<DumpTruck> ());
            Crusher crusher = new Crusher (0, new Gee.ArrayList<DumpTruck> ());

            Gee.ArrayList<DumpTruck> truck_list = new Gee.ArrayList<DumpTruck>.wrap ({
                new DumpTruck (Load.UNLOADED, 0, excavator, crusher),
            });

            foreach (var truck in truck_list) {
                if (excavator == truck.excavator) {
                    excavator.truck_list.add (truck);
                }
            }

            while (timer > 0) {
                print ("\n\ntime %d\n", timer);

                excavator.update ();
                crusher.update ();

                foreach (var truck in truck_list) {
                    truck.update ();
                }

                timer--;

                Idle.add (simulate.callback);
                yield;
            }

            print ("\n\n---%d---\n\n", count);
            count = 0;
        }
    }
}