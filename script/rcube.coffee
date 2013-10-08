
define ()->
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

    NextAxis = (axis)->(axis+1)%Axes 
    shiftUp = (a)->
        x = a.pop()
        a.unshift(x)
    shiftDown = (a)->
        x = a.shift()
        a.push(x)
    IsRowMajor = (axis, faceAxis) -> ((faceAxis - axis + Axes) % Axes) != 1

    # //    Y2         5
    # // X1|Z2|X2  0 | 2 | 1
    # //    Y1         4
    # //    Z1         3
    #     1:21
    #     3:37
    #     5:46
    #     7:30
    #     10:23
    #     12:43
    #     14:52
    #     16:32
    #     19:39
    #     23:10
    #     25:48
    #     28:41
    #     30:7
    #     32:16
    #     34:50
    #     37:3
    #     39:19
    #     41:28
    #     43:12
    #     46:5
    #     48:25
    #     50:34
    #     52:14
    # corners =
    #     0:[18,36]
    #     2:[24,45]
    #     6:[27,38]
    #     8:[33,47]
    #     9:[26,51]
    #     11:[20,42]
    #     15:[29,44]
    #     17:[35,53]
    #     18:[0,36]
    #     20:[11,42]
    #     24:[2,45]
    #     26:[0,51]
    #     27:[6,38]
    #     29:[15,44]
    #     33:[8,47]
    #     35:[17,53]
    #     36:[0,18]
    #     38:[6,27]
    #     42:[11,20]
    #     44:[15,29]
    #     45:[2,24]
    #     47:[8,33]
    #     51:[9,26]
    #     53:[17,35]
    # center = 
    #     4:true
    #     13:true
    #     22:true
    #     31:true
    #     40:true
    #     49:true
    class Cube
        constructor:()->
            @Squares = []
            for i in [0..Faces-1]
                for j in [0..FaceSize-1]
                    # n = (x[i*FaceSize+j] && 1) || 0
                    @Squares.push(i)
        Clone:()->
            c = new Cube()
            for i in [0..CubeSize-1]
                c.Squares[i] = @Squares[i]
            return c
        SetRow:(axis, face, row, invert, r)->
            offset = (axis * 2 + face) * FaceSize + row * CubeLength
            if invert 
                for i in [0..CubeLength-1]
                    @Squares[offset+i] = r[i]
            else 
                for i in [0..CubeLength-1]
                    @Squares[offset+i] = r[CubeLength-1-i]
        SetColumn:(axis, face, row, invert, r)->
            offset = (axis * 2 + face) * FaceSize + row
            if invert 
                for i in [0..CubeLength-1]
                    @Squares[offset + i*CubeLength] = r[i]
            else 
                for i in [0..CubeLength-1]
                    @Squares[offset + i*CubeLength] = r[CubeLength-1-i]
        Row:(axis, face, row, invert)->
            r = []
            offset = (axis * 2 + face) * FaceSize + row * CubeLength
            if invert
                for i in [0..CubeLength-1]
                    r.push(@Squares[offset+i])
            else
                for i in [0..CubeLength-1]
                    r.push(@Squares[offset+CubeLength-1-i])
            return r
        Column:(axis, face, row, invert)->
            r = []
            offset = (axis * 2 + face) * FaceSize + row
            if invert
                for i in [0..CubeLength-1]
                    r.push(@Squares[offset+i*CubeLength])
            else
                for i in [0..CubeLength-1]
                    r.push(@Squares[offset+(CubeLength-1-i)*CubeLength])
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
