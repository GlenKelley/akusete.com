
define ()->
   
    eqif = (test, a, b) -> return (test && a) || (test && b)
    CubeLength = 3
    FaceSize = CubeLength * CubeLength
    RingLength = 4
    RingSize = CubeLength * RingLength
    Faces = 6
    CubeSize = Faces * FaceSize
    Axes = 3
    X = 0
    Y = 1
    Z = 2
    LOW = 0
    HIGH = 1

    NextAxis = (axis) ->(axis+1)%Axes 
    shiftUp = (a) -> a.unshift(a.pop())
    shiftDown = (a) -> a.push(a.shift())
    IsRowMajor = (axis, faceAxis) -> ((faceAxis - axis + Axes) % Axes) != 1
    class Cube
        constructor:()->
            @Squares = []
            for i in [0..Faces-1]
                for j in [0..FaceSize-1]
                    @Squares.push(i)
        Clone:()->
            c = new Cube()
            for i in [0..CubeSize-1]
                c.Squares[i] = @Squares[i]
            return c
        SetRow:(axis, face, row, invert, r)->
            offset = (axis * 2 + face) * FaceSize + row * CubeLength
            m  = eqif(invert, 1, -1)
            x0 = eqif(invert, 0, CubeLength-1)
            for i in [0..CubeLength-1]
              @Squares[offset+i] = r[x0+m*i]
        SetColumn:(axis, face, row, invert, r)->
            offset = (axis * 2 + face) * FaceSize + row
            m = eqif(invert, 1, -1)
            x0 = eqif(invert, CubeLength-1)
            for i in [0..CubeLength-1]
              @Squares[offset + i*CubeLength] = r[x0+m*i]
        Row:(axis, face, row, invert)->
            r = []
            offset = (axis * 2 + face) * FaceSize + row * CubeLength
            m  = eqif(invert, 1, -1)
            x0 = eqif(invert, 0, CubeLength-1)
            for i in [0..CubeLength-1]
              r.push(@Squares[offset+x0+m*i])
            return r
        Column:(axis, face, row, invert)->
            r = []
            offset = (axis * 2 + face) * FaceSize + row
            m  = eqif(invert, 1, -1)
            x0 = eqif(invert, 0, CubeLength-1)
            for i in [0..CubeLength-1]
              r.push(@Squares[offset+(x0+m*i)*CubeLength])
            return r
        Ring:(axis, row)->
            a2 = NextAxis(axis)
            a3 = NextAxis(a2)
            rs = [
                @Column(a2, LOW, row, false)
                @Row(a3, LOW, row, true)
                @Column(a2, HIGH, row, true)
                @Row(a3, HIGH, row, false)
            ]
            return rs
        SetRing:(axis, row, ring)->
            a2 = NextAxis(axis)
            a3 = NextAxis(a2)
            @SetColumn(a2, LOW, row, false, ring[0])
            @SetRow(a3, LOW, row, true, ring[1])
            @SetColumn(a2, HIGH, row, true, ring[2])
            @SetRow(a3, HIGH, row, false, ring[3])
        RotateFace:(axis, face)->
            i = (axis * 2 + face) * FaceSize
            s = @Squares
            t = s[i]
            s[i] = s[i+6]
            s[i+6] = s[i+8]
            s[i+8] = s[i+2]
            s[i+2] = t
            t = s[i+3]
            s[i+3] = s[i+7]
            s[i+7] = s[i+5]
            s[i+5] = s[i+1]
            s[i+1] = t
        RotateFaceCCW:(axis, face)->
            i = (axis * 2 + face) * FaceSize
            s = @Squares
            t = s[i]
            s[i] = s[i+2]
            s[i+2] = s[i+8]
            s[i+8] = s[i+6]
            s[i+6] = t
            t = s[i+1]
            s[i+1] = s[i+5]
            s[i+5] = s[i+7]
            s[i+7] = s[i+3]
            s[i+3] = t
        Rotate:(axis, row)->
            ring = @Ring(axis, row)
            shiftDown(ring)
            @SetRing(axis, row, ring)
            if row == 0 
                @RotateFace(axis, 0)
            else if row == 2 
                @RotateFace(axis, 1)
        RotateCCW:(axis, row)->
            ring = @Ring(axis, row)
            shiftUp(ring)
            @SetRing(axis, row, ring)
            if row == 0
                @RotateFaceCCW(axis, 0)
            else if row == 2
                @RotateFaceCCW(axis, 1)
        Square:(axis, face, row, column)->
            offset = (axis * 2 + face) * FaceSize + row * CubeLength + column
            return @Squares[offset]
    
    return {
        Cube,
        CubeLength:CubeLength,
        FaceSize:FaceSize,
        RingLength:RingLength,
        RingSize:RingSize,
        Faces:Faces,
        CubeSize:CubeSize,
        Axes:Axes,
        X:X,
        Y:Y,
        Z:Z,
        LOW:LOW,
        HIGH:HIGH,
        IsRowMajor:IsRowMajor,
        NextAxis:NextAxis
    }
