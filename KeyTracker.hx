/*
 * PIETRO - Reddit Game Jam 06 entry
 * Copyright (C) 2011, Patai Gergely
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
 */

package;

import flash.events.KeyboardEvent;

class KeyTracker
{
  private var keys:Array<Bool>;

  public function new(stage)
  {
    keys = new Array();
    for (i in 0...256) keys[i] = false;
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
  }

  public function isDown(code:Int):Bool { return keys[code]; }

  public function onKeyDown(e:KeyboardEvent) { keys[e.keyCode] = true; }

  public function onKeyUp(e:KeyboardEvent) { keys[e.keyCode] = false; }

}
