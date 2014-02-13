/**
 * Created with IntelliJ IDEA.
 * User: awake
 * Date: 2/13/14
 * Time: 11:59 PM
 * To change this template use File | Settings | File Templates.
 */
package net.naemnik.transformable {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

public class Example extends Sprite {

    private var _mTransformable:Transformable;

    public function Example() {

        var verts:Vector.<Point> = new Vector.<Point>;
        verts.push(new Point(100 ,140));
        verts.push(new Point(200, 140));
        verts.push(new Point(200, 200));
        verts.push(new Point(100, 200));

        var center:Point = new Point(150, 170);

        var body:Sprite = new Sprite();
        body.graphics.beginFill(0x0000FF);
        body.graphics.moveTo(verts[0].x, verts[0].y);
        var i:int;
        var vert:Point;
        for (i = 0; i< verts.length; i++) {
            vert = verts[i];
            if (!i) {
                body.graphics.moveTo(vert.x, vert.y);
            } else {
                body.graphics.lineTo(vert.x, vert.y);
            }
        }
        body.graphics.lineTo(verts[0].x, verts[0].y);
        body.graphics.endFill();

        addChild(body);

        _mTransformable = new Transformable();
        _mTransformable.setVertices(verts, center);
        _mTransformable.setTransformable(body);

        stage.addEventListener(MouseEvent.CLICK, onClickHandler);
    }

    private function onClickHandler(e:MouseEvent):void {
        _mTransformable.hit(e.localX, e.localY, 0);
    }
}
}
