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
        public double zoom { get; set; }
        public Gtk.GestureDrag move_gesture;
        public Gtk.GestureZoom zoom_gesture;

        public Chart () {
            Object ();
        }

        construct {
            this.series = new Gee.ArrayList<Series> ();

            Point current_position = new Point (0, 0);
            double current_scale = 1;

            this.content_width = 360;
            this.content_height = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.center = current_position;
            this.zoom = current_scale;

            this.set_draw_func (draw);

            this.move_gesture = new Gtk.GestureDrag ();
            this.zoom_gesture = new Gtk.GestureZoom ();

            this.move_gesture.drag_update.connect ((offset_x, offset_y) => {
                var move_x = this.center.x + ((offset_x - current_position.x > 0) ? 1 : -1) * (int) (offset_x - current_position.x).abs ();
                var move_y = this.center.y + ((offset_y - current_position.y > 0) ? 1 : -1) * (int) (offset_y - current_position.y).abs ();
                this.center = new Point ((int) move_x, (int) move_y);
                current_position = new Point ((int) offset_x, (int) offset_y);
                this.queue_draw ();
            });

            this.move_gesture.drag_end.connect (() => {
                current_position = new Point (0, 0);
            });

            this.zoom_gesture.scale_changed.connect ((scale) => {
                var zoom_scale = zoom + (Math.round (current_scale * 1000) / 1000 - scale) * (zoom.abs () * 2);
                if (zoom_scale > 0) {
                    this.zoom = zoom_scale;
                    current_scale = scale;
                    this.queue_draw ();
                }
            });

            this.zoom_gesture.end.connect (() => {
                current_scale = 1;
            });

            this.add_controller (this.move_gesture);
            this.add_controller (this.zoom_gesture);
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            draw_grid (drawing_area, cairo, width, height);

            cairo.set_line_width (1.0);

            foreach (var series_item in this.series) {
                draw_series (cairo, series_item, width);
            }
        }

        private void draw_grid (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            cairo.set_line_width (0.5);

            draw_line (cairo, this.center.x, 0, this.center.x, height);
            draw_line (cairo, 0, this.center.y, width, this.center.y);

            cairo.set_line_width (0.1);
            cairo.set_source_rgb (0.5, 0.5, 0.5);

            int step = calculate_grid_step ();

            if (this.center.x < width) {
                for (int i = this.center.x; i < width; i += (int) step) {
                    if (i < 0)continue;
                    draw_line (cairo, i, 0, i, height);
                }
            }
            if ((this.center.x > 0)) {
                for (int i = this.center.x; i > 0; i -= (int) step) {
                    if (i > width)continue;
                    draw_line (cairo, i, 0, i, height);
                }
            }

            if (this.center.y < height) {
                for (int i = this.center.y; i < height; i += (int) step) {
                    if (i < 0)continue;
                    draw_line (cairo, 0, i, width, i);
                }
            }
            if ((this.center.y > 0)) {
                for (int i = this.center.y; i > 0; i -= (int) step) {
                    if (i > height)continue;
                    draw_line (cairo, 0, i, width, i);
                }
            }
        }

        private void draw_series (Cairo.Context cairo, Series series_item, int width) {
            cairo.set_source_rgb (series_item.color.red, series_item.color.green, series_item.color.blue);
            cairo.move_to (center.x + series_item.points.first ().x, center.y - series_item.points.first ().y);

            foreach (var point in series_item.points) {
                cairo.line_to (center.x + point.x, center.y - point.y);
            }

            cairo.stroke ();
        }

        private void draw_line (Cairo.Context cairo, double x1, double y1, double x2, double y2) {
            cairo.move_to (x1, y1);
            cairo.line_to (x2, y2);
            cairo.stroke ();
        }

        private int calculate_grid_step () {
            double result = 10 / zoom;

            while (result < 10 || result > 120) {
                if (result < 10) {
                    result *= 10;
                } else if (result > 120) {
                    result /= 10;
                }
            }

            return (int) result;
        }
    }
}