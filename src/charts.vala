/* charts.vala
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
    public class Charts : Gtk.DrawingArea {
        public Charts () {
            Object ();
        }

        construct {
            width_request = 360;
            height_request = 294;

            margin_bottom = 18;
            margin_top = 18;
            margin_start = 12;
            margin_end = 12;

            set_draw_func (draw);
        }

        private void draw_coordinate_axis (Gtk.DrawingArea drawing_area, Cairo.Context cr, int width, int height) {
            for (int i = 0; i < width; i += 20) {
                cr.set_line_width ((i == 20) ? 0.5 : 0.1);
                cr.move_to (i, 0);
                cr.line_to (i, height);
                cr.stroke ();
            }
            for (int i = 0; i < height; i += 20) {
                cr.set_line_width ((i + 20 > height) ? 0.5 : 0.1);
                cr.move_to (0, i);
                cr.line_to (width, i);
                cr.stroke ();
            }
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cr, int width, int height) {
            draw_coordinate_axis (drawing_area, cr, width, height);
        }
    }
}