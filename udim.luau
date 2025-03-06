--!optimize 2
--!native
--!strict
type Vector2 = {X: number, Y: number}
type UDim = {Scale: number, Offset: number}
type UDim2 = {X: UDim, Y: UDim}

local udim = {}

function udim.scale(scale_x: number, scale_y: number): UDim2
    return UDim2.fromScale(scale_x, scale_y)
end

function udim.offset(offset_x: number, offset_y: number): UDim2
    return UDim2.fromOffset(offset_x, offset_y)
end

function udim.lerp(start: UDim2, goal: UDim2, alpha: number): UDim2
    alpha = math.clamp(alpha, 0, 1)
    
    return UDim2.new(
        start.X.Scale + (goal.X.Scale - start.X.Scale) * alpha,
        start.X.Offset + (goal.X.Offset - start.X.Offset) * alpha,
        start.Y.Scale + (goal.Y.Scale - start.Y.Scale) * alpha,
        start.Y.Offset + (goal.Y.Offset - start.Y.Offset) * alpha
    )
end

function udim.round(value: UDim2): UDim2
    return UDim2.new(
        value.X.Scale,
        math.round(value.X.Offset),
        value.Y.Scale,
        math.round(value.Y.Offset)
    )
end

function udim.clamp(value: UDim2, min_udim: UDim2, max_udim: UDim2): UDim2
    return UDim2.new(
        math.clamp(value.X.Scale, min_udim.X.Scale, max_udim.X.Scale),
        math.clamp(value.X.Offset, min_udim.X.Offset, max_udim.X.Offset),
        math.clamp(value.Y.Scale, min_udim.Y.Scale, max_udim.Y.Scale),
        math.clamp(value.Y.Offset, min_udim.Y.Offset, max_udim.Y.Offset)
    )
end

function udim.add(a: UDim2, b: UDim2): UDim2
    return UDim2.new(
        a.X.Scale + b.X.Scale,
        a.X.Offset + b.X.Offset,
        a.Y.Scale + b.Y.Scale,
        a.Y.Offset + b.Y.Offset
    )
end

function udim.sub(a: UDim2, b: UDim2): UDim2
    return UDim2.new(
        a.X.Scale - b.X.Scale,
        a.X.Offset - b.X.Offset,
        a.Y.Scale - b.Y.Scale,
        a.Y.Offset - b.Y.Offset
    )
end

function udim.mul(value: UDim2, scalar: number): UDim2
    return UDim2.new(
        value.X.Scale * scalar,
        value.X.Offset * scalar,
        value.Y.Scale * scalar,
        value.Y.Offset * scalar
    )
end

function udim.div(value: UDim2, scalar: number): UDim2
    assert(scalar ~= 0, "Division by zero")
    local inv_scalar = 1 / scalar
    return UDim2.new(
        value.X.Scale * inv_scalar,
        value.X.Offset * inv_scalar,
        value.Y.Scale * inv_scalar,
        value.Y.Offset * inv_scalar
    )
end

function udim.to_vector2(value: UDim2, container_size: Vector2): Vector2
    return Vector2.new(
        value.X.Scale * container_size.X + value.X.Offset,
        value.Y.Scale * container_size.Y + value.Y.Offset
    )
end

function udim.from_vector2(vector: Vector2): UDim2
    return UDim2.fromOffset(vector.X, vector.Y)
end

type Keypoint = {position: UDim2, time: number}
function udim.sequence(keypoints: {Keypoint}, alpha: number): UDim2
    local count = #keypoints
    if count < 2 then
        return keypoints[1].position
    end
    
    for i = 1, count - 1 do
        local current = keypoints[i]
        local next_point = keypoints[i + 1]
        
        if alpha >= current.time and alpha <= next_point.time then
            local time_range = next_point.time - current.time
            if time_range == 0 then
                return current.position
            end
            local t = (alpha - current.time) / time_range
            return udim.lerp(current.position, next_point.position, t)
        end
    end
    
    return keypoints[count].position
end

function udim.get_scale_ratio(value: UDim2): number
    if value.Y.Scale == 0 then
        return 0
    end
    return value.X.Scale / value.Y.Scale
end

function udim.get_offset_ratio(value: UDim2): number
    if value.Y.Offset == 0 then
        return 0
    end
    return value.X.Offset / value.Y.Offset
end

return udim
