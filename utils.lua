function hex_color(r, g, b, a)
    if not b then
        -- a = bit.rshift(bit.band(r, 0xFF000000), 24)/255;
        a = g or 1;
        g = bit.rshift(bit.band(r, 0xFF00), 8)/255;
        b = bit.band(r, 0xFF)/255;
        r = bit.rshift(bit.band(r, 0xFF0000), 16)/255;
    end

    love.graphics.setColor(r, g, b, a);
end

function hex_color_bg(r, g, b, a)
    if not b then
        -- a = bit.rshift(bit.band(r, 0xFF000000), 24)/255;
        a = g or 1;
        g = bit.rshift(bit.band(r, 0xFF00), 8)/255;
        b = bit.band(r, 0xFF)/255;
        r = bit.rshift(bit.band(r, 0xFF0000), 16)/255;
    end

    love.graphics.clear(r, g, b, a);
end

function map(n, start1, stop1, start2, stop2)
    return (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
end

function sign(val)
    if val==0 then return 0 end
    return val>0 and 1 or -1;
end

function cash(seed, x, y)  
    local h = seed + x*374761393 + y*668265263;
    h = bit.bxor(h, bit.rshift(h, 13))*1274126177;
    return bit.bxor(h, bit.rshift(h, 16));
end

function movetowards(current, target, max_delta)
    if math.abs(target - current) <= max_delta then
        return target;
    end

    return current + sign(target - current) * max_delta;
end

function collide(x, y, x1, y1, w, h)
    return x>x1 and y>y1 and x<x1+w and y<y1+h;
end

function lerp(a, b, t)
    return (1 - t) * a + t * b;
end