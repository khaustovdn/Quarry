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
            Chart chart = new Chart ();

            this.simulate_button.clicked.connect (() => {
                chart.series.clear ();
                simulate.begin (chart, (obj, res) => {
                    simulate.end (res);
                    chart.queue_draw ();
                });
            });

            simulation_listbox.append (chart);
        }

        public async void simulate (Chart chart) {
            int timer = (int) this.timer_spin_row.adjustment.value;

            var truck_list = new Gee.ArrayList<DumpTruck> ();
            var crusher = new Crusher (0, new Gee.ArrayList<DumpTruck> ());
            var excavator_list = new Gee.ArrayList<Excavator> ();

            for (int i = 0; i < 3; i++) {
                excavator_list.add (new Excavator (0, new Gee.ArrayList<DumpTruck> ()));
            }

            foreach (var excavator in excavator_list) {
                for (int i = 0; i < 3; i++) {
                    var truck = new DumpTruck (Load.UNLOADED, 0, (i == 0) ? 50 : 20, excavator, crusher);
                    truck_list.add (truck);
                    excavator.truck_list.add (truck);
                }
            }

            var crusher_queue_series = new Series (new Color (0.2, 0.8, 0.3));
            var excavators_queue_series = new Series (new Color (0.8, 0.2, 0.3));

            for (int i = 0; i < timer; i++) {
                print ("\n\ntime %d\n", i);

                crusher.update ();

                crusher_queue_series.add_point (i / 10, crusher.truck_list.size * 10);

                var excavators_queue = 0;

                foreach (var excavator in excavator_list) {
                    excavator.update ();

                    foreach (var truck in truck_list) {
                        if (truck.excavator == excavator) {
                            truck.update ();
                        }
                    }

                    excavators_queue += excavator.truck_list.size;
                }

                excavators_queue_series.add_point (i / 10, excavators_queue * 10);

                Idle.add (simulate.callback);
                yield;
            }

            chart.series.add (crusher_queue_series);
            chart.series.add (excavators_queue_series);

            print ("\n\n---%d---\n\n", count);
            count = 0;
        }
    }
}