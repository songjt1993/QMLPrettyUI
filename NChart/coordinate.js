var padding = {"top":15, "left":5, "bottom": 5, "right": 15}

function drawTopAxis(ctx, axis) {
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
        for (var tk of axis.ticks) {
            ctx.moveTo(tk, plotArea.top)
            ctx.lineTo(tk, plotArea.top + axis.tickLength)
        }
        ctx.stroke()
    }
}

function drawBottomAxis(ctx, axis) {
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
        for (var tk of axis.ticks) {
            ctx.moveTo(tk, plotArea.bottom)
            ctx.lineTo(tk, plotArea.bottom - axis.tickLength)
        }
        ctx.stroke()
    }
}

function drawLeftAxis(ctx, axis) {
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
        for (var tk of axis.ticks) {
            ctx.moveTo(plotArea.left, plotArea.bottom - tk)
            ctx.lineTo(plotArea.left + axis.tickLength, plotArea.bottom - tk)
        }
        ctx.stroke()
    }
}

function drawRightAxis(ctx, axis) {
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
        for (var tk of axis.ticks) {
            ctx.moveTo(plotArea.right, plotArea.bottom - tk)
            ctx.lineTo(plotArea.right - axis.tickLength, plotArea.bottom - tk)
        }
        ctx.stroke()
    }
}