/**
 * Created with IntelliJ IDEA.
 * User: awake
 * Date: 2/13/14
 * Time: 11:11 PM
 * To change this template use File | Settings | File Templates.
 */
package net.naemnik.transformable {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class Transformable {

    protected var _mMaxValue:int = 1000000000;
    protected var _mVerts:Vector.<Point>;
    protected var _mCenter:Point;
    protected var _mMinX:int = _mMaxValue;
    protected var _mMinY:int = _mMaxValue;
    protected var _mMaxX:int = -_mMaxValue;
    protected var _mMaxY:int = -_mMaxValue;
    protected var _mTransformable:DisplayObject;
    protected var _mMask:Sprite;

    public function Transformable() {
    }

    public function setVertices(verts:Vector.<Point>, center:Point):void {
        if (_mVerts) {
            throw new Error('SetVertices() already happen!');
        }
        _mVerts = new Vector.<Point>();
        var vert:Point;
        for each(vert in verts) {
            _mVerts.push(vert.clone());
            _mMinX = Math.min(_mMinX, vert.x);
            _mMinY = Math.min(_mMinY, vert.y);
            _mMaxX = Math.max(_mMaxX, vert.x);
            _mMaxY = Math.max(_mMaxY, vert.y);
        }
        _mCenter = center;
    }

    public function setTransformable(obj:DisplayObject):void {
        _mTransformable = obj;
    }

    public function hit(x:Number, y:Number, strength:int = 10):void {
        // Object should not increase bounds.
        x = Math.max(_mMinX, x);
        x = Math.min(_mMaxX, x);
        y = Math.max(_mMinY, y);
        y = Math.min(_mMaxY, y);
        var p1:Point = new Point(x,  y);
        // Moving hit point closer to the center, more strength, more closer to center.
        var cx:int = x - _mCenter.x;
        var cy:int = y - _mCenter.y;
        var aTan:Number = Math.atan2(cx, cy);
        var changeY:int = strength * Math.cos(aTan);
        var changeX:int = strength * Math.sin(aTan);
        var mx:int = x - changeX;
        var my:int = y - changeY;
        var pNew:Point = new Point(mx,  my);
        log('minx:'+_mMinX+'miny:'+_mMinY+'maxx:'+_mMaxX+'maxy:'+_mMaxY+' Hit p1:'+p1+' pNew:'+pNew+' center:'+_mCenter+' aTan:'+aTan*57+' changeX:'+changeX+' changeY:'+changeY);
        var i:int;
        var fromVert:Point;
        var toVert:Point;
        var to:int;
        var intersection:Point;

        // Ignore hit if close to existing point.
        for (i = 0; i<_mVerts.length; i++) {
            if (Point.distance(_mVerts[i], pNew) < 10) {
                return;
            }
        }

        // Founding closest ribbon.
        var pointFromIndexOfClosestVector:int;
        var minDist:Number = _mMaxValue;
        var distance:Number;
        for (i = 0; i<_mVerts.length; i++) {
            fromVert = _mVerts[i];
            to = i < _mVerts.length-1 ? i+1 : 0;
            toVert = _mVerts[to];
            intersection = getClosestPointToLine(fromVert, toVert, p1);
            log('intersection:'+intersection);
            if (intersection) {
                distance = Point.distance(p1, intersection);
                log('distance:'+distance);
                if (distance < minDist) {
                    minDist = distance;
                    pointFromIndexOfClosestVector = i + 1 - 1;
                }
            }
        }
        if (!intersection) {
            return;
        }

        fromVert = _mVerts[pointFromIndexOfClosestVector];
        var newVerts:Vector.<Point> = new Vector.<Point>();

        // Making dint.
        var intersFrom:Point = fromVert.clone();
        // Deviding found vector.
        for (i = 0; i<_mVerts.length; i++) {
            fromVert = _mVerts[i];
            newVerts.push(fromVert);
            if (intersFrom.equals(fromVert)) {
                newVerts.push(pNew);
            }
        }
        _mVerts = newVerts;
        log(_mVerts);
        update();
    }

    //-------------------

    protected static function getClosestPointToLine(segA:Point, segB:Point, p:Point):Point {
        var p2:Point = new Point(segB.x - segA.x, segB.y - segA.y);
        var lenSquared:Number = p2.x*p2.x + p2.y*p2.y;
        var u:Number = ((p.x - segA.x) * p2.x + (p.y - segA.y) * p2.y) / lenSquared;
        if (u > 1) {
            u = 1;
        } else if (u < 0) {
            u = 0;
        }
        var x:Number = segA.x + u * p2.x;
        if (isNaN(x)) {
            return null;
        }
        var y:Number = segA.y + u * p2.y;
        if (isNaN(y)) {
            return null;
        }
        return new Point(x, y);
    }

    protected function update():void {
        if (!_mMask) {
            _mMask = new Sprite();
        }
        _mMask.graphics.clear();
        _mMask.graphics.beginFill(0);
        _mMask.graphics.moveTo(_mVerts[0].x, _mVerts[0].y);
        var i:int;
        var vert:Point;
        for (i = 0; i< _mVerts.length; i++) {
            vert = _mVerts[i];
            if (!i) {
                _mMask.graphics.moveTo(vert.x, vert.y);
            } else {
                _mMask.graphics.lineTo(vert.x, vert.y);
            }
        }
        _mMask.graphics.lineTo(_mVerts[0].x, _mVerts[0].y);
        _mMask.graphics.endFill();
        _mTransformable.mask = _mMask;
    }

    protected function log(obj:Object):void {
        // Implement your way.
        // Example: trace(CTracer.obj(obj));
    }
}
}
