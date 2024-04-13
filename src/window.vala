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
        public unowned Gtk.ListBox simulation_listbox;
        [GtkChild]
        public unowned Adw.SpinRow timer_spin_row;
        [GtkChild]
        public unowned Gtk.Button simulate_button;



        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            Charts charts = new Charts ();

            this.simulate_button.clicked.connect (() => {
                charts.clear ();
                simulate.begin (charts, (obj, res) => {
                    simulate.end (res);
                    charts.update ();
                });
            });

            simulation_listbox.append (charts);
        }

        public async void simulate (Charts charts) {
            int timer = (int) this.timer_spin_row.adjustment.value;

            var truck_list = new Gee.ArrayList<DumpTruck> ();
            var crusher = new Crusher (0, new Gee.ArrayList<DumpTruck> ());
            var excavator_list = new Gee.ArrayList<Excavator>.wrap ({
                new Excavator (0, new Gee.ArrayList<DumpTruck> ()),
                new Excavator (0, new Gee.ArrayList<DumpTruck> ()),
                new Excavator (0, new Gee.ArrayList<DumpTruck> ())
            });

            foreach (var excavator in excavator_list) {
                for (int i = 0; i < 3; i++) {
                    var truck = new DumpTruck (Load.UNLOADED, 0, excavator, crusher);
                    truck_list.add (truck);
                    excavator.truck_list.add (truck);
                }
            }

            for (int i = 0; i < timer; i++) {
                print ("\n\ntime %d\n", timer);

                crusher.update ();

                charts.series.add_point (i * 10, crusher.truck_list.size * 10);

                foreach (var excavator in excavator_list) {
                    excavator.update ();

                    foreach (var truck in truck_list) {
                        if (truck.excavator == excavator) {
                            truck.update ();
                        }
                    }
                }

                Idle.add (simulate.callback);
                yield;
            }

            print ("\n\n---%d---\n\n", count);
            count = 0;
        }
    }
}