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

import box2D.dynamics.B2Body;
import flash.display.Sprite;

enum ObjectType
{
  PLAYER;
  GROUND;
}

class VisibleObject extends Sprite
{

  public var body:B2Body;

  public function new(body)
  {
    super();
    this.body = body;
  }

  public function synchronise()
  {
    var pos = body.GetPosition();
    var ang = body.GetAngle();
    x = pos.x / Scene.worldScale;
    y = pos.y / Scene.worldScale;
    rotation = ang * 180 / Math.PI;
  }

}
