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

import flash.Lib;
import flash.display.MovieClip;
import flash.events.Event;
import Player.Side;
import Player.LegState;

class Main extends MovieClip
{

  private var scene:Scene;
  private var keys:KeyTracker;

  public function new()
  {
    super();
    Lib.current.addChild(this);
    scene = new Scene();
    addChild(scene);
    scene.startLevel();
    keys = new KeyTracker(stage);
    addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
  }

  public function onEnterFrame(e:Event)
  {
    var energyUsed = false;

    if (keys.isDown(27)) scene.startLevel();
    if (keys.isDown(32)) scene.advanceLevel();

    scene.player.controlLeg(LEFT, RELAX);
    scene.player.controlLeg(RIGHT, RELAX);

    if (keys.isDown(83)) // S
      {
	scene.player.controlLeg(LEFT, CONTRACT);
	scene.player.controlLeg(RIGHT, CONTRACT);
	energyUsed = true;
      }

    if (keys.isDown(70)) // F
      {
	scene.player.controlLeg(LEFT, EXTEND);
	scene.player.controlLeg(RIGHT, EXTEND);
	energyUsed = true;
      }

    scene.update(energyUsed);
  }

  public static function main()
  {
    new Main();
  }

}
