requirejs.config(
    paths: 
       jquery:'http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min'
       gl:'lib/gl-matrix'
       jdrag:'lib/jquery.event.drag-2.2'
    shim:
        'gl/vec3': 
           deps: ['gl/common']
           exports: 'vec3'
        'gl/vec4': 
           deps: ['gl/common']
           exports: 'vec4'
        'gl/mat4': 
           deps: ['gl/common']
           exports: 'mat4'
        'gl/mat3': 
           deps: ['gl/common']
           exports: 'mat3'
        'gl/quat': 
           deps: ['gl/common', 'gl/vec3', 'gl/mat3']
           exports: 'quat'
        'jdrag': deps: ['jquery']
)

require ['jquery', 'gl/mat4', 'gl/vec4', 'gl/vec3', 'gl/quat', 'rcube', 'jdrag'], ($, mat4, vec4, vec3, quat, rcube)->
     
    class CubeRotation
        constructor:()->
            @active = false
        
        begin:(@axis, @row, @inverse)->
            @progress = 0
            @active = true
        
        increment:(f)->
            @progress += f
        
        isFinished:()->
            return @progress >= 1.0
    
        applyMove:(cube)->
            if @inverse 
                cube.Rotate(@axis, @row)
            else 
                cube.RotateCCW(@axis, @row)
            
    class UI
        constructor:(render, cube)->
            # @view_rotx = 0* Math.PI / 180
            # @view_roty = 110* Math.PI / 180
            # @view_rotz = -10* Math.PI / 180
        
            @quat = quat.create()
        
            @rotation = new CubeRotation()
        
            px = 0
            py = 0
            $(document).drag("init", (e)=>
                px = e.pageX
                py = e.pageY
                return undefined
            ).drag((e)=>
                dx = e.pageX - px
                dy = e.pageY - py
                px = e.pageX
                py = e.pageY
                dx = dx 
                q2 = quat.create()
                q3 = quat.create()
                quat.rotateY(q3,q2, dx*Math.PI / 180)
                quat.rotateX(q2,q3, -dy*Math.PI / 180)
                quat.multiply(q3, q2, @quat)
                quat.copy(@quat, q3)
                
                render.redraw(cube, @)
            ).drag("end", (e)=>
            )
            dt = 10
            timer = null
            f = ()=>
                if @rotation.active
                    i = @rotation.progress
                    di = (-i*(i-1)*(i+1)+0.1)*0.1
                    @rotation.increment(di)
                    if @rotation.isFinished()
                        @rotation.applyMove(cube)
                        @rotation.active = false
                    render.redraw(cube, @)
                else
                    clearInterval(timer)
                    timer = null

            $(document).keypress (e)=>
                if @rotation.active
                    @rotation.applyMove(cube)
                    @rotation.active = false
                inverse = e.shiftKey
                key = e.which
                if inverse
                    key += 'a'.charCodeAt(0) - 'A'.charCodeAt(0)
                
                maxi = (a,b,c)->
                    if a >= b && a >= c
                        return rcube.X
                    else if b >= a && b >= c
                        return rcube.Y
                    else 
                        return rcube.Z
                qrotate = (axis, row, inverse)=>
                    v = vec3.create()
                    qi = quat.create()
                    quat.invert(qi,@quat)
                    vec3.transformQuat(v, axis, qi)
                    a = maxi(Math.abs(v[0]), Math.abs(v[1]), Math.abs(v[2]))
                    s = v[a]
                    rr = (x)->Math.round(x*100) / 100
                    if s < 0
                        row = rcube.CubeLength - 1 - row
                        inverse = !inverse
                    @rotation.begin(a, row, inverse)

                w = @w
                switch key
                    when 'q'.charCodeAt(0)
                        qrotate(vec3.fromValues(1,0,0),2,inverse)
                    when 'w'.charCodeAt(0)
                        qrotate(vec3.fromValues(1,0,0),1,inverse)
                    when 'e'.charCodeAt(0)
                        qrotate(vec3.fromValues(1,0,0),0,inverse)
                    when 'a'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,1,0),0,inverse)
                    when 's'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,1,0),1,inverse)
                    when 'd'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,1,0),2,inverse)
                    when 'z'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,0,1),2,inverse)
                    when 'x'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,0,1),1,inverse)
                    when 'c'.charCodeAt(0)
                        qrotate(vec3.fromValues(0,0,1),0,inverse)
                    # when 'f'.charCodeAt(0)
                    #     w.Reset(0)
                    #     w.SetCross(0, 1)
                    #     w.SetCenter(2, 2)
                    #     w.SetCenter(3, 2)
                    #     w.SetCenter(4, 2)
                    #     w.SetCenter(5, 2)
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when 'g'.charCodeAt(0)
                    #     w.Reset(0)
                    #     w.SetFace(0, 1)
                    #     w.SetCenter(2, 3)
                    #     w.SetCenter(3, 3)
                    #     w.SetCenter(4, 3)
                    #     w.SetCenter(5, 3)
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when 'h'.charCodeAt(0)
                    #     w.Reset(0)
                    #     w.SetWeightRing(rcube.X, 1)
                    #     w.SetCenter(2,3)
                    #     w.SetCenter(3,3)
                    #     w.SetCenter(4,3)
                    #     w.SetCenter(5,3)
                    #     w.SetFace(4)
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when 'j'.charCodeAt(0)
                    #     w.Reset(0)
                    #     w.SetWeightRing(rcube.X, 1, 1)
                    #     w.SetWeightRing(rcube.X, 0, 2)
                    #     w.SetCenter(2,3)
                    #     w.SetCenter(3,3)
                    #     w.SetCenter(4,3)
                    #     w.SetCenter(5,3)
                    #     w.SetFace(4)
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when 'k'.charCodeAt(0)
                    #     w.Reset(0)
                    #     w.SetCross(1,1)
                    #     w.SetWeightRing(rcube.X, 1, 2)
                    #     w.SetWeightRing(rcube.X, 0, 3)
                    #     w.SetCenter(2,4)
                    #     w.SetCenter(3,4)
                    #     w.SetCenter(4,4)
                    #     w.SetCenter(5,4)
                    #     w.SetFace(5)
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when 'l'.charCodeAt(0)
                        # w.Reset(0)
                        # w.SetFace(1)
                        # w.SetWeightRing(rcube.X, 2, 2)
                        # w.SetWeightRing(rcube.X, 1, 3)
                        # w.SetWeightRing(rcube.X, 0, 4)
                        # w.SetCenter(2,5)
                        # w.SetCenter(3,5)
                        # w.SetCenter(4,5)
                        # w.SetCenter(5,5)
                        # w.SetFace(6)
                        # console.log(w.evaluate(cube))
                        # console.log(w.evaluate(cube))
                        # cube = w.Clone()
                        # render.redraw(cube, @)
                    # when ' '.charCodeAt(0)
                        # console.log(w.Evaluate(cube))
                        # cube = rsolve.Search(cube, w, 5)
                        # console.log(w.Evaluate(cube))
                        # render.redraw(cube, @)
                # console.log(w)
                if !timer
                    timer = window.setInterval f, dt
    
    class ModelView 
        constructor:(@gl, @modelViewPointer, init) ->
            # @m = mat4.create()
            @stack = [mat4.clone(init)]
    
        top:()-> return @stack[@stack.length-1]
        # setTop:(m)-> @stack[@stack.length-1] = m
    
        push:()-> @stack.push(mat4.clone(@top()))
    
        pop:()-> @stack.pop()
    
        applyInline:(f)->
            m = mat4.create()
            f(m, @top())
        
        apply:(f)->
            m = mat4.create()
            f(m, @top())
            mat4.copy(@top(), m)
        
        attach:()->
            @gl.uniformMatrix4fv(@modelViewPointer, false, @top())
    
    class Draw
        constructor:(@gl)->
        
        drawCube:(cube, rotation, modelview, colorBuffer, modelBuffer)->
            gl = @gl
            colors = [
                [1,0,0]
                [1, 0.5, 0]
                [0,1,0]
                [0,0,1]
                [1,1,1]
                [1,1,0]
            ]
            # colors = [
            #     [0.0,0,0]
            #     [0.2,0,0]
            #     [0.4,0,0]
            #     [0.6,0,0]
            #     [0.8,0,0]
            #     [1.0,0,0]
            #     [1.0,1.0,0.2]
            #     [1.0,1.0,0.4]
            #     [1.0,1.0,0.6]
            #     [1.0,1.0,0.8]
            #     [1.0,1.0,1.0]
            #     [1.0,1.0,0.2]
            #     [1.0,1.0,0.4]
            #     [1.0,1.0,0.6]
            #     [1.0,1.0,0.8]
            #     [1.0,1.0,1.0]
            # ]
            gl.lineWidth(5)
            for a in [0..rcube.Axes-1]
                modelview.push()
                modelview.applyInline (m1,m2)->
                    switch a
                        when rcube.Y
                            mat4.rotateX(m1, m2, Math.PI / 2)
                            mat4.rotateY(m2, m1, Math.PI / 2)
                        when rcube.Z
                            mat4.rotateY(m1, m2, -Math.PI / 2)
                            mat4.rotateX(m2, m1, -Math.PI / 2)
            
                for d in [0..1]
                    modelview.push()                
                    disp = d * rcube.CubeLength
                    v = vec3.fromValues(disp,0,0)
                    modelview.apply (m1,m2) ->
                        mat4.translate(m1, m2, v)
                    
                    if rotation.active 
                        if rotation.axis == a
                            face = (rotation.row == 0 && d == 0) || (rotation.row == 2 && d == 1)
                            middle = rotation.row == 1
                            if middle
                                modelview.push()

                            modelview.attach()                     
                            w = 1
                            w2 = 2*w
                            ds = -(d-0.5)*2*w
                            cw = rcube.CubeLength*w
                            data = [
                                ds,0,0
                                ds,cw,0
                                ds,cw,cw
                                ds,0,0
                                ds,cw,cw
                                ds,0,cw
                            ]
                            @bindConstant(colorBuffer, 0, 18)
                            @bind(data, modelBuffer)
                            gl.drawArrays(gl.TRIANGLES, 0, 6)
                    
                            data = [
                                ds,0,w
                                ds,cw,w
                                ds,0,w2
                                ds,cw,w2
                                ds,w,0
                                ds,w,cw
                                ds,w2,0
                                ds,w2,cw
                            ]
                            @bind(data, modelBuffer)
                            @bindConstant(colorBuffer, 1, 24)
                            gl.drawArrays(gl.LINES, 0, 8)
                            
                            if middle || face
                                modelview.apply (m1,m2)->
                                    v = vec3.fromValues(0,rcube.CubeLength*0.5,rcube.CubeLength*0.5)
                                    mat4.translate(m1,m2,v)
                                    p = rotation.inverse && -1 || 1
                                    mat4.rotateX(m2,m1, p * rotation.progress * Math.PI / 2)
                                    v = vec3.fromValues(0, -rcube.CubeLength*0.5, -rcube.CubeLength*0.5)
                                    mat4.translate(m1,m2,v)

                            modelview.attach()
                        
                            data = [
                                ds,0,0
                                ds,cw,0
                                ds,cw,cw
                                ds,0,0
                                ds,cw,cw
                                ds,0,cw
                            ]
                            @bind(data, modelBuffer)
                            @bindConstant(colorBuffer, 0, 18)
                            gl.drawArrays(gl.TRIANGLES, 0, 6)
                    
                            data = [
                                ds,0,w
                                ds,cw,w
                                ds,0,w2
                                ds,cw,w2
                                ds,w,0
                                ds,w,cw
                                ds,w2,0
                                ds,w2,cw
                            ]
                            @bind(data, modelBuffer)
                            @bindConstant(colorBuffer, 1, 24)
                            gl.drawArrays(gl.LINES, 0, 8)
                                
                            if middle
                                modelview.pop()

                    modelview.push()
                    modelview.applyInline (m1,m2)->
                        mat4.translate(m1,m2, vec3.fromValues(-0.1,0.5,0.5))
                        mat4.scale(m2,m1, vec3.fromValues(0.2,0.2,0.2))
                    # @drawAxis(modelview, colorBuffer, modelBuffer)
                    modelview.pop()
                    for s in [0..rcube.FaceSize-1]
                        row = s % rcube.CubeLength
                        column = Math.floor(s / rcube.CubeLength)
                    
                        v = cube.Square(a, d, row, column)
                        x = row
                        y = column
                        c = colors[v]
                        w = 1
                    
                        modelview.push()
                        if rotation.active && rotation.axis != a
                            modelview.apply (m1,m2)->
                                sx = d*2.0 - 1.0
                                sy = -1.0 
                                isRowMajor = rcube.IsRowMajor(a, rotation.axis)
                                if isRowMajor  && rotation.row == column
                                    v = vec3.fromValues(-sx*rcube.CubeLength*0.5,-sy*rcube.CubeLength*0.5,0)
                                    mat4.translate(m1,m2,v)
                                    p = rotation.inverse && -1 || 1
                                    mat4.rotateZ(m2,m1, p * rotation.progress * Math.PI / 2)
                                    v = vec3.fromValues(sx*rcube.CubeLength*0.5,sy*rcube.CubeLength*0.5,0)
                                    mat4.translate(m1,m2,v)
                                else if !isRowMajor  && rotation.row == row
                                    v = vec3.fromValues(-sx*rcube.CubeLength*0.5,0,-sy*rcube.CubeLength*0.5)
                                    mat4.translate(m1,m2,v)
                                    p = rotation.inverse && -1 || 1
                                    mat4.rotateY(m2,m1, p * rotation.progress * Math.PI / 2)
                                    v = vec3.fromValues(sx*rcube.CubeLength*0.5,0,sy*rcube.CubeLength*0.5)
                                    mat4.translate(m1,m2,v)
                                else
                                    mat4.copy(m1,m2)
                        modelview.attach()
                        
                        color = [
                            c[0],c[1],c[2]
                            c[0],c[1],c[2]
                            c[0],c[1],c[2]
                            c[0],c[1],c[2]
                            c[0],c[1],c[2]
                            c[0],c[1],c[2]
                        ]
                        @bind(color, colorBuffer)
                        data = [
                            0,x,y
                            0,x+w,y
                            0,x+w,y+w
                            0,x,y
                            0,x+w,y+w
                            0,x,y+w
                        ]
                        @bind(data, modelBuffer)
                        gl.drawArrays(gl.TRIANGLES, 0, 6)
                        data = [
                            0,x,y
                            0,x+w,y
                            0,x+w,y
                            0,x+w,y+w
                            0,x+w,y+w
                            0,x,y+w
                            0,x,y+w
                            0,x,y
                        ]
                        @bind(data, modelBuffer)
                        @bindConstant(colorBuffer, 0, 24)
                        gl.drawArrays(gl.LINES, 0, 8)
                    
                        modelview.pop()
                    modelview.pop()
                modelview.pop()
            
        bind:(data, buffer)->
            gl = @gl
            gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW)
        
        bindConstant:(buffer, value, n)->
            data = []
            for i in [0..n-1]
                data.push(value)
            @bind(data, buffer)
            
        drawAxis:(modelview, colorBuffer, modelBuffer)->
            gl = @gl
            modelview.attach()
            gl.lineWidth(5)
            w = 10.0
            color = [
                1,0,0
                1,0,0
                0,1,0
                0,1,0
                0,0,1
                0,0,1
            ]
            @bind(color, colorBuffer)
            data = [
                0,0,0
                w,0,0
                0,0,0
                0,w,0
                0,0,0
                0,0,w
            ]
            @bind(data, modelBuffer)
            gl.drawArrays(gl.LINES, 0, 6)
    
    class Render
        constructor:(canvas)->
            @setCanvasResolution canvas, 512, 512
            @gl = gl = canvas.getContext("experimental-webgl")
            vertexShader = @createShaderFromScriptElement(gl, "2d-vertex-shader")
            fragmentShader = @createShaderFromScriptElement(gl, "2d-fragment-shader")
            @program = @createProgram(gl, [vertexShader, fragmentShader])
    
            gl.useProgram(@program)
            gl.enable(gl.DEPTH_TEST)
            gl.clearColor(1,1,1,1) #0.7, 0.7, 0.7, 1)

            m = mat4.create()
            @modelViewMatrix = gl.getUniformLocation(@program, "uMVMatrix")
            eye = vec3.fromValues(0,0,-20)
            center = vec3.fromValues(0,0,0)
            up = vec3.fromValues(0,1,0)
            mat4.lookAt(m, eye, center, up)
            @modelview = new ModelView(gl, @modelViewMatrix, m)
        
            @projectionViewMatrix = gl.getUniformLocation(@program, "uPMatrix")
            h = 1
            znear = 5.0
            zfar = 30.0
            xmax = znear * 0.5
            mat4.frustum(m, -xmax, xmax, -xmax*h, xmax*h, znear, zfar)
            gl.uniformMatrix4fv(@projectionViewMatrix, false, m)

            @colorBuffer = gl.createBuffer()
            @colorAtribute = gl.getAttribLocation(@program, "aVertexColor")
            gl.bindBuffer(gl.ARRAY_BUFFER, @colorBuffer)
            gl.enableVertexAttribArray(@colorAtribute)
            gl.vertexAttribPointer(@colorAtribute, 3, gl.FLOAT, false, 0, 0)

            @modelBuffer = gl.createBuffer()
            @modelAttribute = gl.getAttribLocation(@program, "aVertexPosition")
            gl.bindBuffer(gl.ARRAY_BUFFER, @modelBuffer);
            gl.enableVertexAttribArray(@modelAttribute)
            gl.vertexAttribPointer(@modelAttribute, 3, gl.FLOAT, false, 0, 0)
        
            @draw = new Draw(@gl)
        
        shaderType:(gl, type) ->
            if (type == "x-shader/x-vertex")
                return gl.VERTEX_SHADER
            else if (type == "x-shader/x-fragment")
                return gl.FRAGMENT_SHADER
            else
                return null

        createShaderFromScriptElement:(gl, shaderName) ->
            script = $(document.getElementById(shaderName))
            type = @shaderType(gl, script.attr('type'))
            shader = gl.createShader(type)
            gl.shaderSource(shader, script.text())
            gl.compileShader(shader)
            if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
                console.log("Could not compile " + type + " shader:\n\n" + gl.getShaderInfoLog(shader))
            return shader

        createProgram:(gl, shaders) ->
            program = gl.createProgram()
            for shader in shaders
                gl.attachShader(program, shader)
            gl.linkProgram(program)
            return program

        setCanvasResolution:(canvas, width, height) ->
            ratio = window.devicePixelRatio || 1;
            canvas.width = ratio * width;
            canvas.height = ratio * height;
            $(canvas).css {width: width, height: height}
        
        redraw:(cube, ui)->
            @clearScreen(@)
            @drawScene(@, ui, cube)
                
        clearScreen:()->
            gl = @gl
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        drawScene:(render, ui, cube) ->
            @modelview.push()
            @modelview.apply (m1,m2)->
                m3 = mat4.create()
                mat4.fromQuat(m3, ui.quat)
                mat4.mul(m1,m2,m3)
                # mat4.rotateX(m1, m2, ui.view_rotx)
                # mat4.rotateY(m2, m1, ui.view_roty)
                # mat4.rotateZ(m1, m2, ui.view_rotz)
                # 
                mat4.translate(m2,m1, vec3.fromValues(-1.5,-1.5,-1.5))
                # mat4.copy(m2,m1)
                mat4.copy(m1,m2)
            # @draw.drawAxis(@modelview, @colorBuffer, @modelBuffer)
            @draw.drawCube(cube, ui.rotation, @modelview, @colorBuffer, @modelBuffer)
            @modelview.pop()

    
    $ ->
        canvas = document.getElementById("cubeview")
        render = new Render(canvas)
        cube = new rcube.Cube()
        ui = new UI(render, cube)
        render.redraw(cube, ui)
