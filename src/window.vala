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
    [GtkTemplate(ui = "/io/github/Quarry/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.ListBox simulation_listbox;
        [GtkChild]
        public unowned Adw.SpinRow timer_spin_row;
        [GtkChild]
        public unowned Gtk.Button simulate_button;

        public Chart chart { private get; construct; }
        public Gee.ArrayList<DumpTruck> truck_list { private get; set; }
        public Crusher crusher { private get; set; }
        public Gee.ArrayList<Excavator> excavator_list { private get; set; }

        public Window(Gtk.Application app) {
            Object(application: app);
        }

        construct {
            this.chart = new Chart();
            this.truck_list = new Gee.ArrayList<DumpTruck> ();
            this.crusher = new Crusher(0, new Gee.ArrayList<DumpTruck> ());
            this.excavator_list = new Gee.ArrayList<Excavator> ();

            this.simulate_button.clicked.connect(() => {
                this.chart.series.clear();
                simulate.begin(this.chart, (int) this.timer_spin_row.adjustment.value, (obj, res) => {
                    simulate.end(res);
                    this.chart.queue_draw();
                });
            });

            simulation_listbox.append(this.chart);
        }

        public async void simulate(Chart chart, int timer) {
            initialize();

            Series crusher_queue_series = new Series(new Color(0.4, 0.8, 0.5));
            Series excavators_queue_series = new Series(new Color(0.8, 0.4, 0.5));

            for (int i = 0; i < timer * 60; i++) {
                update();

                int excavators_queue = calculate_excavators_queue();
                excavators_queue_series.add_point(i, excavators_queue);
                crusher_queue_series.add_point(i, this.crusher.truck_list.size);

                Idle.add(simulate.callback);
                yield;
            }

            clear();

            chart.series.add(crusher_queue_series);
            chart.series.add(excavators_queue_series);
        }

        private void initialize() {
            for (int i = 0; i < 3; i++) {
                Excavator excavator = new Excavator(0, new Gee.ArrayList<DumpTruck> ());
                this.excavator_list.add(excavator);

                for (int j = 0; j < 3; j++) {
                    int tonnage = (j == 0) ? 50 : 20;
                    DumpTruck truck = new DumpTruck(Load.UNLOADED, 0, tonnage, excavator, this.crusher);

                    this.truck_list.add(truck);
                    excavator.truck_list.add(truck);
                }
            }
        }

        private void update() {
            this.crusher.update();

            foreach (var excavator in this.excavator_list) {
                excavator.update();

                foreach (var truck in this.truck_list) {
                    if (truck.excavator == excavator) {
                        truck.update();
                    }
                }
            }
        }

        private void clear() {
            this.excavator_list.clear();
            this.truck_list.clear();
            this.crusher = new Crusher(0, new Gee.ArrayList<DumpTruck> ());
        }

        private int calculate_excavators_queue() {
            int excavators_queue = 0;

            foreach (var excavator in this.excavator_list) {
                excavators_queue += excavator.truck_list.size;
            }

            return excavators_queue;
        }
    }
}