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
        public bool is_loaded { get; set; }

        public DumpTruck () {
            Object (is_loaded: false);
        }

        public void run_to_crusher () {
            if (!is_loaded) {
                print ("Dump truck is not loaded.\n");
                return;
            }

            Thread.usleep (1 * (ulong) Math.pow (10, 6));
        }

        public void run_to_excavator () {
            if (is_loaded) {
                print ("Dump truck is not unloaded.\n");
                return;
            }

            Thread.usleep (1 * (ulong) Math.pow (10, 6));
        }
    }
}