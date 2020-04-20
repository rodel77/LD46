Trap = {
    is_trap = true,
};

function Trap.new(id, x, y)
    local self = {
        id = id,
        x = x,
        y = y,
    };

    if id==2 or id==3 or id==4 or id==5 then
        self.uses = 2;
    end
    if id==9 then
        self.uses = 1;
    end
    if id==6 or id==7 or id==8 then
        self.uses = 5;
    end

    setmetatable(self, {__index = Trap});
    return self;
end

function Trap:draw()
    local ax, ay = project_absolute(self.x, self.y);
    hex_color(0xFFFFFF);
    love.graphics.draw(images.atlas, traps[self.id], ax, ay, 0, TILE_SCALE*2, TILE_SCALE*2);
end

function Trap:apply(entity)
    if self.id==9 then
        print("DAMAG")
        entity:damage(entity.health+10);
    end
    if self.id==2 or self.id==6 then
        entity:damage(Game.strength);
    end
    if self.id==3 or self.id==7 then
        if entity.effect~="" then
            return;
        end
        entity.effect = "poison";
    end
    if self.id==4 or self.id==8 then
        local r = math.random(4);
        print("R", r)
        if r==1 then
            if entity.effect~="" then
                return;
            end
            entity.effect = "poison";
        elseif r==2 then
            if entity.effect~="" then
                return;
            end
            entity.effect = "regeneration";
        elseif r==3 then
            entity:damage(entity.health+10);
        elseif r==4 then
            if entity.effect~="" then
                return;
            end
            entity.effect = "freeze";
        end
    end
    if self.id==5 then
        if entity.effect~="" then
            return;
        end
        entity.effect = "freeze";
    end
    self.uses = self.uses - 1;
    if self.uses<=0 then
        local cx, cy = project_matrix(self.x, self.y);
        Game.trap_matrix[cy][cx] = 0;
        return;
    end
end

return Trap;