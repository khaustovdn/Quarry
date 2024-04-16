/* dump-truck.vala
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
    public class DumpTruck : Machine {
        public Load load { get; set; }
        public int tonnage { get; construct; }
        public Excavator excavator { get; construct; }
        public Crusher crusher { get; construct; }
        private bool in_transit = false;

        public DumpTruck(Load load, int time, int tonnage, Excavator excavator, Crusher crusher) {
            Object(load: load, time: time, tonnage: tonnage, excavator: excavator, crusher: crusher);
        }

        public override void update() {
            if (!is_in_excavator_list() && !is_in_crusher_list()) {
                handle_transit();
            } else {
                handle_time_update();
            }
        }

        private void handle_transit() {
            if (!is_in_transit()) {
                calculate_transit_time();
                this.in_transit = true;
                this.time--;
            }

            if (time > 0) {
                this.time--;
            } else {
                move_truck();
                this.in_transit = false;
                this.time = 0;
            }
        }

        private void calculate_transit_time() {
            if (this.load == Load.LOADED) {
                this.time = (this.tonnage == 50) ? 180 : 150;
            } else if (this.load == Load.UNLOADED) {
                this.time = (this.tonnage == 50) ? 120 : 90;
            }
        }

        private void move_truck() {
            if (load == Load.LOADED) {
                this.crusher.truck_list.add(this);
            } else if (load == Load.UNLOADED) {
                this.excavator.truck_list.add(this);
            }
        }

        private void handle_time_update() {
            if (!is_in_transit()) {
                this.time--;
            }
        }

        private bool is_in_transit() {
            return this.in_transit;
        }

        private bool is_in_excavator_list() {
            return this.excavator.truck_list.contains(this);
        }

        private bool is_in_crusher_list() {
            return this.crusher.truck_list.contains(this);
        }
    }
}