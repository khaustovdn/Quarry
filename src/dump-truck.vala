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
    public class DumpTruck : Object {
        public Load load { get; set; }
        public int time { get; set; }
        public int tonnage { get; construct; }
        public Excavator excavator { get; construct; }
        public Crusher crusher { get; construct; }

        private bool in_transit = false;

        public DumpTruck (Load load, int time, int tonnage, Excavator excavator, Crusher crusher) {
            Object (load: load, time: time, tonnage: tonnage, excavator: excavator, crusher: crusher);
        }

        public void update () {
            if (!this.excavator.truck_list.contains (this) && !this.crusher.truck_list.contains (this)) {
                if (!this.in_transit) {
                    // print ("truck in transit %d\n", this.tonnage);
                    if (this.load == Load.LOADED) {
                        this.time = (this.tonnage == 50) ? 180 : 150;
                    } else if (this.load == Load.UNLOADED) {
                        this.time = (this.tonnage == 50) ? 120 : 90;
                    }
                    this.in_transit = true;
                    this.time--;
                }

                if (this.time > 0) {
                    // print ("transit time  %d\n", this.time);
                    this.time--;
                } else {
                    if (this.load == Load.LOADED) {
                        this.crusher.truck_list.add (this);
                    } else if (this.load == Load.UNLOADED) {
                        this.excavator.truck_list.add (this);
                    }
                    this.in_transit = false;
                    this.time = 0;
                }
            }
        }
    }
}