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

import box2D.common.math.B2Vec2;
import box2D.dynamics.joints.B2RevoluteJoint;
import box2D.dynamics.joints.B2RevoluteJointDef;
import flash.display.Sprite;
import flash.filters.BevelFilter;
import VisibleObject.ObjectType;

enum Side
{
  LEFT;
  RIGHT;
}

enum LegState
{
  RELAX;
  CONTRACT;
  EXTEND;
  HOLD;
}

class Player extends Sprite
{

  private var torso:VisibleObject;
  private var leftThigh:VisibleObject;
  private var leftLeg:VisibleObject;
  private var leftFoot:VisibleObject;
  private var rightThigh:VisibleObject;
  private var rightLeg:VisibleObject;
  private var rightFoot:VisibleObject;

  private var leftHip:B2RevoluteJoint;
  private var rightHip:B2RevoluteJoint;
  private var leftKnee:B2RevoluteJoint;
  private var rightKnee:B2RevoluteJoint;
  private var leftAnkle:B2RevoluteJoint;
  private var rightAnkle:B2RevoluteJoint;

  public function init(scene:Scene, x = 0.0, y = 0.0)
  {
    var bf = new BevelFilter();
    bf.strength = 0.7;
    filters = [bf];

    var world = scene.world;
    var worldScale = Scene.worldScale;

    torso = scene.addDisc(PLAYER, 14, x, y, 0.1);
    leftThigh = scene.addBox(PLAYER, 3, 10, x - 4, y + 13, 0, 1);
    leftLeg = scene.addBox(PLAYER, 3, 10, x - 4, y + 28, 0, 1);
    leftFoot = scene.addBox(PLAYER, 6, 3, x - 6, y + 36, 0, 1);
    rightThigh = scene.addBox(PLAYER, 3, 10, x + 4, y + 13, 0, 1);
    rightLeg = scene.addBox(PLAYER, 3, 10, x + 4, y + 28, 0, 1);
    rightFoot = scene.addBox(PLAYER, 6, 3, x + 6, y + 36, 0, 1);

    torso.body.AllowSleeping(false);

    var jd = new B2RevoluteJointDef();
    jd.enableLimit = true;
    jd.enableMotor = false;
    jd.maxMotorTorque = 50.0;

    jd.lowerAngle = 0;
    jd.upperAngle = 1.7;
    jd.Initialize(torso.body, leftThigh.body, new B2Vec2((x - 4) * worldScale, (y + 8) * worldScale));
    leftHip = cast(world.CreateJoint(jd), B2RevoluteJoint);
    jd.lowerAngle = -1.7;
    jd.upperAngle = 0;
    jd.Initialize(torso.body, rightThigh.body, new B2Vec2((x + 4) * worldScale, (y + 8) * worldScale));
    rightHip = cast(world.CreateJoint(jd), B2RevoluteJoint);

    jd.lowerAngle = -2.2;
    jd.upperAngle = 0;
    jd.Initialize(leftThigh.body, leftLeg.body, new B2Vec2((x - 4) * worldScale, (y + 20.5) * worldScale));
    leftKnee = cast(world.CreateJoint(jd), B2RevoluteJoint);
    jd.lowerAngle = 0;
    jd.upperAngle = 2.2;
    jd.Initialize(rightThigh.body, rightLeg.body, new B2Vec2((x + 4) * worldScale, (y + 20.5) * worldScale));
    rightKnee = cast(world.CreateJoint(jd), B2RevoluteJoint);

    jd.lowerAngle = -1.4;
    jd.upperAngle = 0.15;
    jd.Initialize(leftLeg.body, leftFoot.body, new B2Vec2((x - 4) * worldScale, (y + 36) * worldScale));
    leftAnkle = cast(world.CreateJoint(jd), B2RevoluteJoint);
    jd.lowerAngle = -0.15;
    jd.upperAngle = 1.4;
    jd.Initialize(rightLeg.body, rightFoot.body, new B2Vec2((x + 4) * worldScale, (y + 36) * worldScale));
    rightAnkle = cast(world.CreateJoint(jd), B2RevoluteJoint);
  }

  public function controlLeg(side:Side, state:LegState)
  {
    var enabled = state != RELAX;
    var speed = switch (state)
      {
      case CONTRACT: 8;
      case EXTEND: -15;
      default: 0;
      }

    switch (side)
      {
      case LEFT:
	leftHip.EnableMotor(enabled);
	leftKnee.EnableMotor(enabled);
	leftHip.SetMotorSpeed(speed);
	leftKnee.SetMotorSpeed(-speed);
      case RIGHT:
	rightHip.EnableMotor(enabled);
	rightKnee.EnableMotor(enabled);
	rightHip.SetMotorSpeed(-speed);
	rightKnee.SetMotorSpeed(speed);
      }
  }

  public function getPosition() { return torso.body.GetPosition(); }

  public function setTarget(x:Float, y:Float)
  {
    var p = getPosition();
    var a = torso.body.GetAngle();
    var r = Math.min(1.3, Math.max(-1.3, Math.atan2(x - p.x, p.y - y) + a));

    leftHip.SetLimits(r, r + 1.7);
    rightHip.SetLimits(r - 1.7, r);
  }

}
