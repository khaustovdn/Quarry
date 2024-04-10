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
        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            Excavator excavator = new Excavator ();
            DumpTruck dump_truck = new DumpTruck ();
            Crusher crusher = new Crusher ();
            excavator.load_dump_truck (dump_truck);
            dump_truck.run_to_crusher ();
            crusher.unload_dump_truck (dump_truck);
            crusher.unload_dump_truck (dump_truck);
        }
    }
}