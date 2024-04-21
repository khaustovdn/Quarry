/* chart.vala
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
    public class Chart : Gtk.DrawingArea {
        public Gee.ArrayList<Series> series { get; construct; }
        public Point center { get; set; }
        public double scale { get; set; }
        public Gtk.GestureDrag move_gesture;
        public Gtk.GestureZoom scale_gesture;

        public Chart () {
            Object ();
        }

        construct {
            this.series = new Gee.ArrayList<Series> ();

            this.content_width = 360;
            this.content_height = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.center = new Point (0, 0);
            this.scale = 1.0;

            this.set_draw_func (this.draw);

            Point current_position = this.center;
            double current_scale = this.scale;

            this.move_gesture = new Gtk.GestureDrag ();
            this.scale_gesture = new Gtk.GestureZoom ();

            this.move_gesture.drag_update.connect ((offset_x, offset_y) => {
                var result_x = this.center.x + ((offset_x - current_position.x > 0) ? 1 : -1) * (offset_x - current_position.x).abs ();
                var result_y = this.center.y + ((offset_y - current_position.y > 0) ? 1 : -1) * (offset_y - current_position.y).abs ();
                this.center = new Point (result_x, result_y);
                current_position = new Point (offset_x, offset_y);
                this.queue_draw ();
            });

            this.move_gesture.drag_end.connect (() => {
                current_position = new Point (0, 0);
            });

            this.scale_gesture.scale_changed.connect ((scale) => {
                var result = this.scale + ((float) current_scale - scale) * (this.scale.abs () * 2);
                if (result > 0) {
                    double widget_horizontal_center = this.get_content_width () / 2;
                    double widget_vertical_center = this.get_content_height () / 2;
                    double center_x = widget_horizontal_center - (widget_horizontal_center - this.center.x) * (this.scale / result);
                    double center_y = widget_vertical_center - (widget_vertical_center - this.center.y) * (this.scale / result);
                    this.center = new Point (center_x, center_y);
                    this.scale = result;
                    current_scale = scale;
                    this.queue_draw ();
                }
            });

            this.scale_gesture.end.connect (() => {
                current_scale = 1.0;
            });

            this.add_controller (this.move_gesture);
            this.add_controller (this.scale_gesture);
        }

        private void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            this.draw_grid (drawing_area, cairo, width, height);

            foreach (var series_item in this.series) {
                series_item.draw_series (cairo, this.center, this.scale, width, height);
            }
        }

        private void draw_grid (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            cairo.set_line_width (1.0);

            this.draw_line (cairo, this.center.x, 0, this.center.x, height);
            this.draw_line (cairo, 0, this.center.y, width, this.center.y);

            cairo.set_line_width (0.1);
            cairo.set_source_rgb (0.5, 0.5, 0.5);

            double step = this.calculate_grid_step ();

            if (this.center.x < width) {
                for (double i = this.center.x; i < width; i += step) {
                    if (i < 0)continue;
                    this.draw_line (cairo, i, 0, i, height);
                }
            }
            if ((this.center.x > 0)) {
                for (double i = this.center.x; i > 0; i -= step) {
                    if (i > width)continue;
                    this.draw_line (cairo, i, 0, i, height);
                }
            }

            if (this.center.y < height) {
                for (double i = this.center.y; i < height; i += step) {
                    if (i < 0)continue;
                    this.draw_line (cairo, 0, i, width, i);
                }
            }
            if ((this.center.y > 0)) {
                for (double i = this.center.y; i > 0; i -= step) {
                    if (i > height)continue;
                    this.draw_line (cairo, 0, i, width, i);
                }
            }
        }

        private void draw_line (Cairo.Context cairo, double x1, double y1, double x2, double y2) {
            cairo.move_to (x1, y1);
            cairo.line_to (x2, y2);
            cairo.stroke ();
        }

        private double calculate_grid_step () {
            double result = 10 / this.scale;

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