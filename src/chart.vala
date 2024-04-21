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
        private Grid grid { get; set; }
        private Point center { get; set; }
        private double scale { get; set; }
        private Gtk.GestureDrag move_gesture;
        private Gtk.GestureZoom scale_gesture;

        public Chart () {
            Object ();
        }

        construct {
            this.series = new Gee.ArrayList<Series> ();
            this.grid = new Grid ();

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
            this.grid.draw (this.center, this.scale, cairo, width, height);

            foreach (var series_item in this.series) {
                series_item.draw (cairo, this.center, this.scale, width, height);
            }
        }
    }
}