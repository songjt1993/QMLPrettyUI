function LineSeries() {
    this.color = color()
    this.name = "line"
    this.lineWidth = 1
    this.points = []
    this.hAxis = null
    this.vAxis = null
}

LineSeries.prototype.haha = function(){
    console.log("hahaha")
}

LineSeries.prototype.draw = function(ctx){
    if (this.points.length >= 2) {
        ctx.clearRect(0,0,width,height)
        ctx.strokeStyle = this.color
        ctx.lineWidth = this.lineWidth
        ctx.beginPath()
        ctx.moveTo(this.hAxis.mapToPosition(this.points[0].x), this.vAxis.mapToPosition(this.points[0].y))
        for (var i=1; i<this.points.length; i++) {
            ctx.lineTo(this.hAxis.mapToPosition(this.points[i].x), this.vAxis.mapToPosition(this.points[i].y))
        }
        ctx.stroke()
    }
}

function color(){
     var r = Math.floor(Math.random()*255);
     var g = Math.floor(Math.random()*255);
     var b = Math.floor(Math.random()*255);
     return 'rgba('+ r +','+ g +','+ b +',0.8)'
}