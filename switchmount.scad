 $fn = $preview ? $fn : 128;
 $fs = $preview ? $fs : 0.01;
 delta = $preview ? 0.01: 0.001;
 in2mm = 25.4;
 
 // measurements based upon outer size
 width =            4.43  * in2mm;
 depth =            2.275 * in2mm;
 flangeZ =          0.157 * in2mm;
 flangeRadius =     0.1   * in2mm;
 flangeD = flangeRadius*2;
 flangeWidth=       0.157 * in2mm;
 innerBoxWidth=     width - 2*flangeWidth; 
 innerBoxDepth=     depth - 2* flangeWidth; 
 innerBoxHeight =   0.4   * in2mm;
 innerBoxWall =     0.076 * in2mm;
 switchWidth = 23;
 switchDepth = 40;
 rounding = .04*in2mm;
 switchHeight = innerBoxHeight+flangeZ+(0.5*in2mm);
 flangeRounding = 0.1 * in2mm;
//========================================================================
module flangeRound(x=10,y=10,r=5){
    translate([0,0,-delta])
    {
        union()
        {
            roundRemove(x,r);
            translate([0,y,0])
                mirror([0,1,0])
                    roundRemove(x,r);
            mirror([1,0,0])
                rotate([0,0,90])
                    roundRemove(y,r);
            translate([x,0,0])
                rotate([0,0,90])
                    roundRemove(y,r);
        }
    }
}
//========================================================================
module top() {
     circleX = width - flangeD;
     circleY = depth - flangeD;
     translate([flangeRadius,flangeRadius,0])
     {
        linear_extrude(height = flangeZ)
        {
            hull()
            {
                for (x=[0:1]) for(y=[0:1])
                    translate([x*circleX,y*circleY,0])
                        circle(flangeRadius);
            }
        }
     }
 }
//========================================================================
module roundRemove(d=100,r=5){
    translate([d,r,0])
        rotate([0,90,-180])
            translate([-r,0,0])
                difference()
                {
                    linear_extrude(d)
                        square(r);
                    linear_extrude(d)
                        circle(r);
                }
}
//========================================================================
module innerBoxRemove(){
    difference()
    {
        cube([innerBoxWidth-2*innerBoxWall,innerBoxDepth-2*innerBoxWall,innerBoxHeight+delta]);
            roundRemove(d= innerBoxWidth-2*innerBoxWall,r=rounding);
        translate([0,innerBoxDepth-2*innerBoxWall,0])
        rotate([90,0,0])
            roundRemove(d= innerBoxWidth-2*innerBoxWall,r=rounding);
    }    
}
//========================================================================
module innerBoxOutsideRound(r=10){
    translate([-delta,-delta,0])
    mirror([1,0,0])
        rotate([0,-90,0])
            roundRemove(d=innerBoxHeight,r=r);
    
    translate([innerBoxWidth+delta,-delta,0])
        rotate([0,-90,0])
            roundRemove(d=innerBoxHeight,r=r);
    translate([0,innerBoxDepth+delta,0])
    mirror([0,1,0])
    {
        translate([-delta,0,0])
        mirror([1,0,0])
            rotate([0,-90,0])
                roundRemove(d=innerBoxHeight,r=r);
        translate([0,delta,0])
        translate([innerBoxWidth,0,0])
            rotate([0,-90,0])
                roundRemove(d=innerBoxHeight,r=r);
    }
}
//========================================================================
module innerBoxOutside(){
    difference()
    {
        cube([innerBoxWidth,innerBoxDepth,innerBoxHeight]);
        innerBoxOutsideRound(innerBoxWall);
    }
}
//========================================================================
module innerbox(){
    translate([(width-innerBoxWidth)/2,
               (depth-innerBoxDepth)/2,
               flangeZ])
    difference()
    {
        innerBoxOutside();
       translate([innerBoxWall,innerBoxWall,0])
       {
           innerBoxRemove();
       }
    }
}
//========================================================================
module switch()
{
    cube([switchWidth,switchDepth,switchHeight+2*delta]);
}
//========================================================================
module switchHole(n=4){
    d= (width-2*(flangeWidth+innerBoxWall));
    b = (d-(4*switchWidth))/(n-1);
    translate([flangeWidth+innerBoxWall,(depth-switchDepth)/2,-delta])
    {
        for (index = [0:n-1])
        {
            offset = (switchWidth+b)*index;
            translate([offset,0,0])
                switch();
        }
    }
}
//========================================================================
module switchHolder(){
    difference ()
    {
        union()
        {
            top();
            innerbox();
        }
        switchHole();
        flangeRound(width,depth,flangeRounding);        
    }    
}

//========================================================================
// Main Code
//========================================================================

switchHolder();