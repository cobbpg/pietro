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

import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleDef;
import box2D.collision.shapes.B2PolygonDef;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2World;
import box2D.dynamics.joints.B2RevoluteJoint;
import box2D.dynamics.joints.B2RevoluteJointDef;
import flash.Lib;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import VisibleObject.ObjectType;

class Scene extends Sprite
{

  public static inline var worldScale = 0.04;

  public var world:B2World;
  public var player:Player;

  private var energyUsed:Int;
  private var cumulativeEnergy:Int;
  private var level:Int;
  private var levelComplete:Bool;

  private var staticObjects:List<VisibleObject>;
  private var dynamicObjects:List<VisibleObject>;
  private var hudLabel:TextField;
  private var successLabel:TextField;

  private var startPosition:Float;
  private var maxPosition:Float;

  private var prevTime:Int;

  public function new()
  {
    super();
    mouseChildren = false;

    var aabb = new B2AABB();
    aabb.lowerBound.Set(0, -500);
    aabb.upperBound.Set(4000, 500);
    world = new B2World(aabb, new B2Vec2(0, 2), true);
    staticObjects = new List<VisibleObject>();
    dynamicObjects = new List<VisibleObject>();

    var tf = new TextFormat("Arial", 16, 0x000000, false, false, false);
    tf.align = TextFormatAlign.LEFT;

    hudLabel = new TextField();
    hudLabel.defaultTextFormat = tf;
    hudLabel.x = 20;
    hudLabel.y = 10;
    hudLabel.width = 600;
    hudLabel.height = 60;
    addChild(hudLabel);

    tf = new TextFormat("Arial", 40, 0x000000, false, false, false);
    tf.align = TextFormatAlign.CENTER;
    successLabel = new TextField();
    successLabel.defaultTextFormat = tf;
    successLabel.x = 0;
    successLabel.y = 100;
    successLabel.width = 640;
    successLabel.height = 200;
    successLabel.text = "Pietro Is Eager To Run Off!\n\nPress space to start";
    addChild(successLabel);

    level = -1;
    levelComplete = true;

    prevTime = Lib.getTimer();

    var m = new Matrix();
    m.createGradientBox(width, height, Math.PI * 0.5);
    graphics.beginGradientFill(GradientType.LINEAR, [0xddddff, 0x4444dd, 0x332211], [1, 1, 1], [20, 230, 255], m);
    graphics.drawRect(0, 0, 1200, 400);
    graphics.endFill();
  }

  public function startLevel()
  {
    if (levelComplete) return;

    generateGround(level);
    addPlayer(45, 220);
    energyUsed = 0;
    successLabel.visible = false;
  }

  public function advanceLevel()
  {
    if (levelComplete)
      {
	levelComplete = false;
	level++;
	startLevel();
      }
  }

  public function generateGround(seed:Int)
  {
    removeObjects(GROUND);

    var r = new Random(seed);

    var f1 = 0.3 + r.next() * 0.2;
    var f2 = 0.5 + r.next() * 0.2;
    var f3 = 0.8 + r.next() * 0.2;

    addBox(GROUND, 20, 300, -5, 0, -0.05);
    addBox(GROUND, 20, 300, 1195, 0, 0.05);
    for (i in 0...60)
      {
	var mul = Math.min(i * 0.04, 1);
	var w = 5 + r.next() * 25;
	var h = 60;
	var x = i * 20 + r.next() * 10;
	var y = 300 + r.next() * 10 * mul
	  + 30 * Math.sin(i * f1) * mul
	  + 25 * Math.sin(i * f2) * mul
	  + 20 * Math.sin(i * f3) * mul;
	var a = mul * (r.next() - 0.5) * Math.PI * 0.3;
	var vo = addBox(GROUND, w, h, x - Math.sin(a) * 30, y + Math.cos(a) * 30, a);
      }

    setChildIndex(hudLabel, numChildren - 1);
  }

  private function objectsOfType(type)
  {
    return switch (type)
      {
      case GROUND: { list: staticObjects, parent: cast(this, DisplayObjectContainer) };
      case PLAYER: { list: dynamicObjects, parent: cast(player, DisplayObjectContainer) };
      }
  }

  public function removeObjects(type)
  {
    var vos = objectsOfType(type);
    if (vos.parent == null) return;

    for (vo in vos.list)
      {
	world.DestroyBody(vo.body);
	vos.parent.removeChild(vo);
	vos.list.remove(vo);
      }
  }

  public function addPlayer(x = 0.0, y = 0.0)
  {
    if (player != null)
      {
	removeObjects(PLAYER);
	removeChild(player);
      }

    player = new Player();
    addChild(player);
    player.init(this, x, y);
    startPosition = x * 100;
    maxPosition = x * 100;

    setChildIndex(hudLabel, numChildren - 1);
  }

  public function addBox(type:ObjectType, width = 1.0, height = 1.0, x = 0.0, y = 0.0, angle = 0.0, density = 0.0):VisibleObject
  {
    var box = new B2PolygonDef();
    box.SetAsBox(width * worldScale, height * worldScale);
    box.density = density;
    box.friction = 0.4;
    box.restitution = 0.3;

    var bd = new B2BodyDef();
    bd.position.Set(x * worldScale, y * worldScale);
    bd.angle = angle;

    var body = world.CreateBody(bd);
    body.CreateShape(box);
    body.SetMassFromShapes();

    var vo = new VisibleObject(body);
    objectsOfType(type).parent.addChild(vo);
    objectsOfType(type).list.add(vo);
    vo.synchronise();

    switch (type)
      {
      case GROUND:
	var m = new Matrix();
	m.createGradientBox(width, height, Math.PI * 0.5, -width, -height);
	vo.graphics.beginGradientFill(GradientType.LINEAR, [0x996633, 0x332211], [1, 1], [32, 255], m);
	vo.graphics.lineStyle(4);
	vo.graphics.lineGradientStyle(GradientType.LINEAR, [0xcc8844, 0x332211, 0x996633], [1, 1, 0], [0, 32, 255], m);
	vo.graphics.drawRoundRect(-width, -height, width * 2, height * 2, 5);
	vo.graphics.endFill();
      case PLAYER:
	vo.graphics.beginFill(0x66cc33);
	vo.graphics.drawRoundRect(-width, -height, width * 2, height * 2, Math.min(width, height) * 2);
	vo.graphics.endFill();
      }

    return vo;
  }

  public function addDisc(type:ObjectType, radius = 1.0, x = 0.0, y = 0.0, density = 0.0):VisibleObject
  {
    var disc = new B2CircleDef();
    disc.radius = radius * worldScale;
    disc.density = density;
    disc.friction = 0.4;
    disc.restitution = 0.3;

    var bd = new B2BodyDef();
    bd.position.Set(x * worldScale, y * worldScale);

    var body = world.CreateBody(bd);
    body.CreateShape(disc);
    body.SetMassFromShapes();

    var vo = new VisibleObject(body);
    objectsOfType(type).parent.addChild(vo);
    objectsOfType(type).list.add(vo);
    vo.synchronise();

    vo.graphics.beginFill(type == GROUND ? 0x996633 : 0x66cc33);
    vo.graphics.drawEllipse(-radius, -radius, radius * 2, radius * 2);
    vo.graphics.endFill();

    return vo;
  }

  public function update(energyWasUsed)
  {
    var curTime = Lib.getTimer();
    var dt = curTime - prevTime;
    prevTime = curTime;

    if (levelComplete) return;

    if (energyWasUsed) energyUsed++;

    player.setTarget(mouseX * worldScale, mouseY * worldScale);
    world.Step(Math.min(1 / 30, dt / 1000), 10);

    x = Math.min(0, -player.getPosition().x / worldScale + 120);
    //trace(stage.stageWidth + "; " + width + "; " + transform.pixelBounds);

    maxPosition = Math.max(maxPosition, Math.round(player.getPosition().x / worldScale * 100));

    hudLabel.x = 20 - x;
    hudLabel.text = "Level: " + level + "  Energy used: " + cumulativeEnergy + "+" + energyUsed
      + "  Maximum distance: " + ((maxPosition - startPosition) / 100)
      + "\nS - bend knees  F - straighten legs  mouse - control hip joints (slightly)"
      + "\nEsc - restart level";

    if (maxPosition - startPosition > 100000)
      {
	levelComplete = true;
	cumulativeEnergy += energyUsed;
	successLabel.text = "Level complete with " + energyUsed + " energy!"
	  + "\nTotal energy used so far: " + cumulativeEnergy
	  + "\nPress space to continue";
	successLabel.x = -x;
	successLabel.visible = true;
	setChildIndex(successLabel, numChildren - 1);
      }

    for (vo in dynamicObjects) vo.synchronise();
  }

}

private class Random
{

  public var seed:Int;

  public function new(seed)
  {
    this.seed = seed;
  }

  public function next()
  {
    seed = seed * 1664525 + 1013904223;
    return ((seed >> 8) & 0xffff) / 65535.0;
  }

}
