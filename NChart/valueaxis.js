function ValueAxis(alignment) {
    this.name = alignment
    this.unit = "%"
    this.alignment = alignment
    this.color = "black"
    this.lineWidth = 1
    this.arrow = {
        "visible": true,
        "halfWidth": 5,
        "length": 15
    }
    this.range = [0, 1000]
    this.factor = []
    this.tick = {
        strategy: [0, 100, 10],
        length: 5,
        marks: []
    }
    this.digits = 0
}

ValueAxis.prototype.draw = function (ctx, plotArea){
    if (this.alignment == "top") {
        drawTopAxis(this, ctx, plotArea)
    } else if (this.alignment == "right") {
        drawRightAxis(this, ctx, plotArea)
    } else if (this.alignment == "bottom") {
        drawBottomAxis(this, ctx, plotArea)
    } else if (this.alignment == "left") {
        drawLeftAxis(this, ctx, plotArea)
    }
}

ValueAxis.prototype.format = function(data){
    return data.toFixed(this.digits)
}

ValueAxis.prototype.calFactor = function(min, max, plotArea){
    if (this.alignment == "top" || this.alignment == "bottom") {
        var f = plotArea.width / (max - min)
        this.factor = [f, plotArea.left-f*min]
    } else {
        var f = plotArea.height / (max - min)
        this.factor =  [-f, plotArea.bottom-f*min]
    }
}

ValueAxis.prototype.adjust = function() {
    var minInterval = (this.range[1] - this.range[0]) / this.tick.strategy[2]
    // 计算真正的interval
    var realInterval = this.tick.strategy[1]
    while (minInterval > realInterval) {
        realInterval = realInterval * 2
    }
    while (minInterval < realInterval) {
        realInterval = realInterval / 2
    }
    // 查找第一的anchor
    var firstTick = this.tick.strategy[0]
    if (this.tick.strategy[0] > this.range[0]) {
        firstTick = this.tick.strategy[0] - realInterval * Math.floor((this.tick.strategy[0] - this.range[0]) / realInterval)
    } else {
        firstTick = Math.ceil((this.range[0] - this.tick.strategy[0]) / realInterval) * realInterval + this.tick.strategy[0]
    }
    this.tick.marks = []
    var i = 0
    var pos = firstTick + i * realInterval
    while(pos < this.range[1]) {
        this.tick.marks.push({
            "label": this.format(pos),
            "position": this.mapToPosition(pos)
        })
        i++
        pos = firstTick + i * realInterval
    }
//    console.log(pos, this.tick.marks[i-1].label, this.tick.marks[i-1].position, this.range[1])
}

ValueAxis.prototype.mapToPosition = function(v) {
    return v * this.factor[0] + this.factor[1]
}

ValueAxis.prototype.mapToValue = function(pos) {
    return (pos - this.factor[1]) / this.factor[0]
}

function drawTopAxis(axis, ctx, plotArea) {
    if (axis) {
        // 绘制坐标轴
        ctx.beginPath()
        ctx.lineWidth = axis.lineWidth
        ctx.strokeStyle = axis.color
        ctx.moveTo(plotArea.left, plotArea.top)
        ctx.lineTo(plotArea.right, plotArea.top)
        ctx.stroke()
        if (axis.arrow.visible) {
            var arrow = axis.arrow
            ctx.beginPath()
            ctx.moveTo(plotArea.right, plotArea.top + arrow.halfWidth)
            ctx.lineTo(plotArea.right + arrow.length, plotArea.top)
            ctx.lineTo(plotArea.right, plotArea.top - arrow.halfWidth)
            ctx.fillStyle = axis.color
            ctx.fill()
            ctx.closePath()
        }
        // 绘制刻度线
        ctx.beginPath()
        for (var mk of axis.tick.marks) {
            ctx.moveTo(mk.position, plotArea.top)
            ctx.lineTo(mk.position, plotArea.top + axis.tick.length)
        }
        ctx.stroke()
    }
}

function drawBottomAxis(axis, ctx, plotArea) {
    if (axis) {
        // 绘制坐标轴
        ctx.beginPath()
        ctx.lineWidth = axis.lineWidth
        ctx.strokeStyle = axis.color
        ctx.moveTo(plotArea.left, plotArea.bottom)
        ctx.lineTo(plotArea.right, plotArea.bottom)
        ctx.stroke()
        if (axis.arrow.visible) {
            var arrow = axis.arrow
            ctx.beginPath()
            ctx.moveTo(plotArea.right, plotArea.bottom + arrow.halfWidth)
            ctx.lineTo(plotArea.right + arrow.length, plotArea.bottom)
            ctx.lineTo(plotArea.right, plotArea.bottom - arrow.halfWidth)
            ctx.fillStyle = axis.color
            ctx.fill()
            ctx.closePath()
        }
        // 绘制刻度线
        ctx.beginPath()
        for (var mk of axis.tick.marks) {
            ctx.moveTo(mk.position, plotArea.bottom)
            ctx.lineTo(mk.position, plotArea.bottom - axis.tick.length)
        }
        ctx.stroke()
    }
}

function drawLeftAxis(axis, ctx, plotArea) {
    if (axis) {
        // 绘制坐标轴
        ctx.beginPath()
        ctx.lineWidth = axis.lineWidth
        ctx.strokeStyle = axis.color
        ctx.moveTo(plotArea.left, plotArea.bottom)
        ctx.lineTo(plotArea.left, plotArea.top)
        ctx.stroke()
        if (axis.arrow.visible) {
            var arrow = axis.arrow
            ctx.beginPath()
            ctx.moveTo(plotArea.left + arrow.halfWidth, plotArea.top)
            ctx.lineTo(plotArea.left, plotArea.top - arrow.length)
            ctx.lineTo(plotArea.left - arrow.halfWidth, plotArea.top)
            ctx.fillStyle = axis.color
            ctx.fill()
            ctx.closePath()
        }
        // 绘制刻度线
        ctx.beginPath()
        for (var mk of axis.tick.marks) {
            ctx.moveTo(plotArea.left, mk.position)
            ctx.lineTo(plotArea.left + axis.tick.length, mk.position)
        }
        ctx.stroke()
    }
}

function drawRightAxis(axis, ctx, plotArea) {
    if (axis) {
        // 绘制坐标轴
        ctx.beginPath()
        ctx.lineWidth = axis.lineWidth
        ctx.strokeStyle = axis.color
        ctx.moveTo(plotArea.right, plotArea.bottom)
        ctx.lineTo(plotArea.right, plotArea.top)
        ctx.stroke()
        if (axis.arrow.visible) {
            var arrow = axis.arrow
            ctx.beginPath()
            ctx.moveTo(plotArea.right + arrow.halfWidth, plotArea.top)
            ctx.lineTo(plotArea.right, plotArea.top - arrow.length)
            ctx.lineTo(plotArea.right - arrow.halfWidth, plotArea.top)
            ctx.strokeStyle = axis.color
            ctx.fillStyle = axis.color
            ctx.fill()
            ctx.closePath()
        }
        // 绘制刻度线
        ctx.beginPath()
        for (var mk of axis.tick.marks) {
            ctx.moveTo(plotArea.right, mk.position)
            ctx.lineTo(plotArea.right - axis.tick.length,mk.position)
        }
        ctx.stroke()
    }
}