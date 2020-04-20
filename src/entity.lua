local pathfinder = require("libs.jumper.pathfinder");

local Entity = {
    x = 0,
    y = 0,
    tween = nil,

    y_delta = 0,
    init_x = 0,

    target_x = 0,
    target_y = 0,

    state = "idle",

    entity_id = 1,
    health = 3,
    visual_health = 0,
    max_health = 3,

    strength = 10,

    is_entity = true,

    villager_count = 0,

    effect = "",
    particle_time = 0,
    particles = {},
};

function Entity.new(entity_id, x, y)
    local self = {
        entity_id = entity_id,
        x = x,
        y = y,
        particles = {},
        pathfinder = pathfinder(Game.grid, "ASTAR", 0);
    };
    self.pathfinder:setHeuristic("DIAGONAL");

    if entity_id==19 then
        self.health, self.max_health = 5, 5;
    end

    if entity_id==21 then
        self.health, self.max_health = 5, 5;
    end

    if entity_id==23 then
        self.health, self.max_health = 1, 1;
    end

    if entity_id==3 then
        self.health, self.max_health = 100, 100;
    end

    setmetatable(self, {__index = Entity});
    return self;
end

function Entity:jump(x, y)
    self.state = "jumping";
    self.init_x, self.init_y = self.x, self.y;
    self.target_x, self.target_y = x, y;
    if self.target_x==self.x then
        self.tween2 = tween.new(.5, self, {y = y});
    else
        self.tween2 = tween.new(.5, self, {x = x});
    end
end

function Entity:draw()
    local x, y = project_absolute(self.x, self.y);
    local target_x, target_y = project_absolute(self.target_x, self.target_y);
    hex_color(0x000000, .5);
    local y_offset = 0;

    if self.entity_id==1 then
        y_offset = -5 + math.sin(love.timer.getTime()*5);
    end

    if self.state=="jumping" then
        local alpha = self.tween2.clock/self.tween2.duration;
        local ix, iy = project_absolute(self.init_x, self.init_y);
        love.graphics.ellipse("fill",
        lerp(ix, target_x, alpha) + TILE_ABS_SIZE/2,
        lerp(iy, target_y, alpha) + TILE_ABS_SIZE - 15, 20 + y_offset, 10 + y_offset);
    else
        love.graphics.ellipse("fill", x + TILE_ABS_SIZE/2, y + TILE_ABS_SIZE - 15, 20 + y_offset, 10 + y_offset);
    end
    love.graphics.setColor(1, 1, 1);
    if self.effect=="poison" then
        hex_color(0x44891a);
    end
    if self.effect=="regeneration" then
        hex_color(0xcb43a7);
    end
    if self.effect=="freeze" then
        hex_color(0x31a2f2);
    end
    if self.x==grid_x and self.y==grid_y then
        Game.selected = self;
        -- if self.entity_id==1 then
            -- love.graphics.setColor(0, 0, 0);
        -- end
        love.graphics.setShader(shaders.outline);
    end

    if math.floor(Game.current_beat/2)%2==0 and self.entity_id==23 then
        love.graphics.draw(images.atlas, monster_quads[self.entity_id+math.floor(Game.current_beat%2)], x + TILE_ABS_SIZE, y - 10 + y_offset, 0, -TILE_SCALE*2, TILE_SCALE*2);
    else
        love.graphics.draw(images.atlas, monster_quads[self.entity_id+math.floor(Game.current_beat%2)], x, y - 10 + y_offset, 0, TILE_SCALE*2, TILE_SCALE*2);
    end
    if self.x==grid_x and self.y==grid_y then
        love.graphics.setShader();
    end

    for i=#self.particles,1,-1 do
        if self.effect=="" then
            table.remove(self.particles, i);
        else
            local v = self.particles[i];
            if love.timer.getTime()>v.time2 then
                table.remove(self.particles, i);
            else
                local alpha = map(love.timer.getTime(), v.time1, v.time2, 0, 1);
                love.graphics.setShader();
                -- if self.effect=="poison" then
                --     hex_color(0x44891a);
                --     love.graphics.rectangle("fill", v.x, v.y + alpha * 10, 10, 10);
                -- end
                -- if self.effect=="regeneration" then
                --     hex_color(0xcb43a7);
                --     love.graphics.rectangle("fill", v.x, v.y + alpha * 10, 10, 10);
                -- end
                -- if self.effect=="freeze" then
                --     hex_color(0x31a2f2);
                    -- love.graphics.rectangle("fill", v.x, v.y + alpha * 10, 10, 10);
                    love.graphics.draw(images.atlas, particle, v.x, v.y - alpha * 10, alpha, 4 * math.sin(alpha*math.pi), 4 * math.sin(alpha*math.pi));
                -- end
            end
        end
    end

    hex_color(0x524f40);
    love.graphics.rectangle("fill", x + 2, y + y_offset - 20, TILE_ABS_SIZE - 4, 10);
    hex_color(0xbe2633);
    -- love.graphics.setShader(shaders.barrier);
    love.graphics.draw(images.pixel, x + 2, y + y_offset - 20, 0, lerp(0, TILE_ABS_SIZE - 4, self.visual_health/self.max_health), 10);
    -- love.graphics.rectangle("fill", x + 2, y + y_offset - 20, lerp(0, TILE_ABS_SIZE - 4, self.health/self.max_health), 10);
    -- love.graphics.setShader();
end

function Entity:click()
    if self.entity_id==3 then
        Game.coins_target = Game.coins_target + 4+math.random(2)
        self.villager_count = self.villager_count + 1;

        sfx.coin:play();
        
        if self.villager_count%2==0 then
            Game:turn();
        end
    else
        self:damage();
        if math.random(50)<10 then
            Game:turn();
        end
    end
end

function Entity:damage(damage)
    self.health = math.min(math.max(self.health - (damage or Game.damage), 0), self.max_health);
    sfx.hit:play();
    if self.health==0 then
        sfx.die:play();
        if self.entity_id==3 then
            Game.death = true;
            return true;
        end

        Game:effect("die", self.x, self.y);
        for i,v in ipairs(Game.entities) do
            if v==self then
                table.remove(Game.entities, i);
                break;
            end
        end
        Game:update_matrix();
    end
end

function Entity:find_nearest_adjacent(x, y)
    local posibilities = {
        {x-1, y},
        {x+1, y},
        {x, y-1},
        {x, y+1},
    };

    local nearest_index, nearest_distance;
    local cx, cy, dist;
    for i,v in ipairs(posibilities) do
        cx = v[1];
        cy = v[2];
        dist = math.sqrt(math.pow(cx-self.x, 2) + math.pow(cy-self.y, 2));
        if nearest_index==nil or dist<nearest_distance then
            nearest_index = i;
            nearest_distance = dist;
        end
    end

    return posibilities[nearest_index];
end

function Entity:turn()
    if self.effect=="freeze" then
        self.effect = "";
        return;
    end

    if self.effect=="regeneration" then
        self:damage(-Game.damage);
        -- return;
    end

    if self.effect=="poison" then
        if self:damage(Game.strength) then
            return;
        end
    end

    local cx, cy = project_matrix(self.x, self.y);
    -- if Game.trap_matrix[cy][cx]~=0 and Game.trap_matrix[cy][cx].id~=5 then
    --     Game.trap_matrix[cy][cx]:apply(self);
    -- end

    if self.entity_id~=3 then
        local posibilities = {
            {-1, 0},
            {1, 0},
            {0, -1},
            {0, 1},
        };

        for i,v in ipairs(posibilities) do
            if v[1]==self.x and v[2]==self.y then
                Game.entities[1]:damage(self.strength);
                self:damage();
                return;
            end
        end

        local near = self:find_nearest_adjacent(0, 0);
        local tx, ty = project_matrix(near[1], near[2]);

        local path = self.pathfinder:getPath(math.floor(cx+.5), math.floor(cy+.5), tx, ty);
        if path then
            local x, y;
            for node, count in path:nodes() do
                x, y = node:getX(), node:getY();
                if count==2 then
                    break;
                end
            end
            return x-10, y-6;
        end
    end
end

function Entity:is_walkable()
    return false;
end

function Entity:update(dt)
    self.visual_health = movetowards(self.visual_health, self.health, .5)

    self.particle_time = self.particle_time + dt;

    if self.particle_time>.3 then
        self.particle_time = 0;

        local x, y = project_absolute(self.x, self.y);
        if self.effect~="" then
            self.particles[#self.particles+1] = {
                x = x + math.random(TILE_ABS_SIZE),
                y = y + math.random(TILE_ABS_SIZE),
                time1 = love.timer.getTime(),
                time2 = love.timer.getTime()+3,
            }
        end
    end

    if self.tween2 then
        if self.tween2:update(dt) then
            self.tween2 = nil;
            self.state = "idle"
            Game:update_matrix();

            local cx, cy = project_matrix(math.floor(self.x + .5), math.floor(self.y + .5));
            if Game.trap_matrix[cy][cx]~=0 then
                Game.trap_matrix[cy][cx]:apply(self);
            end
        end

        if self.target_x~=self.init_x then
            local alpha = map(self.x, self.init_x, self.target_x, 0, 1);
            self.y = lerp(self.init_y, self.target_y, alpha) - math.sin(alpha*math.pi) * math.max((self.target_y-self.init_y)/2, 1);
        end

        if self.tween2==nil then
            self.x = math.floor(self.x + .5);
            self.y = math.floor(self.y + .5);
        end
    end
end

return Entity;