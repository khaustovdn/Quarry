/* grid.vala
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
    public class Grid : Object {
        public Grid () {
            Object ();
        }

        public void draw (Point center, double scale, Cairo.Context cairo, int width, int height) {
            cairo.set_line_width (1.0);

            this.draw_line (cairo, center.x, 0, center.x, height);
            this.draw_line (cairo, 0, center.y, width, center.y);

            cairo.set_line_width (0.1);
            cairo.set_source_rgb (0.5, 0.5, 0.5);

            double step = this.calculate_grid_step (scale);

            cairo.set_font_size (7);
            char[] buffer = new char[256];

            cairo.move_to (center.x + 8, center.y + 8);
            cairo.show_text ("0");

            if (center.x < width) {
                for (double i = center.x + step; i < width; i += step) {
                    if (i < 0)continue;
                    this.draw_line (cairo, i, 0, i, height);
                    cairo.move_to (i - 8, center.y + 8);
                    cairo.show_text ((Math.round (1000 * (i - center.x) * scale) / 1000).format (buffer, "%g"));
                }
            }
            if (center.x > 0) {
                for (double i = center.x - step; i > 0; i -= step) {
                    if (i > width)continue;
                    this.draw_line (cairo, i, 0, i, height);
                    cairo.move_to (i - 8, center.y + 8);
                    cairo.show_text ((Math.round (1000 * (i - center.x) * scale) / 1000).format (buffer, "%g"));
                }
            }

            if (center.y < height) {
                for (double i = center.y + step; i < height; i += step) {
                    if (i < 0)continue;
                    this.draw_line (cairo, 0, i, width, i);
                    cairo.move_to (center.x + 8, i + 8);
                    cairo.show_text ((Math.round (1000 * (-i + center.y) * scale) / 1000).format (buffer, "%g"));
                }
            }
            if ((center.y > 0)) {
                for (double i = center.y - step; i > 0; i -= step) {
                    if (i > height)continue;
                    this.draw_line (cairo, 0, i, width, i);
                    cairo.move_to (center.x + 8, i + 8);
                    cairo.show_text ((Math.round (1000 * (-i + center.y) * scale) / 1000).format (buffer, "%g"));
                }
            }
        }

        private void draw_line (Cairo.Context cairo, double x1, double y1, double x2, double y2) {
            cairo.move_to (x1, y1);
            cairo.line_to (x2, y2);
            cairo.stroke ();
        }

        private double calculate_grid_step (double scale) {
            double result = 10 / scale;

            while (true) {
                if (result < 10)
                    result *= 10;
                else if (result > 120)
                    result /= 10;
                else break;
            }

            return result;
        }
    }
}