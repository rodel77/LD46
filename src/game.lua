local grid = require("libs.jumper.grid");

Game = {
    flashlight_force = 4,
    entities = {},

    effects = {},

    damage = 1,
    coins = 0,
    coins_target = 0,

    current_beat = 0,

    click_hold = nil,

    limit = 4,

    old_beat = -1,

    round = 0,

    death = false,

    duration = 0,
};

DIRECTIONS = {
    0, math.pi/2, math.pi, math.pi*3/2
}

DISCO_COLORS = {
    0xcb43a7,
    0xa3ce27,
    0xec4700,
    0xbe2633,
    0x342a97,
    0x225af6,
}

ENEMIES = {
    1, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23
}

TRAP_INFO = {
    {5,  "Potion o' health", "health"},
    {3,  "Trap that damage monsters", "damage"},
    {5,  "Trap that poison monsters", "poison"},
    {7,  "Trap that poison/kill or damage enemies", "chaos"},
    {10,  "Trap that freeze enemies for a while", "freeze"},
    {6,  "Spikes that damage monsters (very strong)", "damage"},
    {8,  "Spikes that poison monsters (very strong)", "poison"},
    {10, "Spikers that poison/kill or damage enemies (very strong)", "chaos"},
    {20, "Spikes that kill monsters (very strong)", "kill"},
    {100, "Kill every monster", "butcher"},
}

SPAWN_POSITIONS = {}

function Game:restart()
    self.entities = {};
    self.effects = {};
    self.damage = 1;
    self.coins = 0;
    self.coins_target = 0;
    self.current_beat = 0;
    self.click_hold = nil;
    self.limit = 4;
    self.round = 0;
    self.flashlight_force = 4;

    self.death = false;
    self:init();
end

function Game:init()
    self.duration = 0;
    self.matrix = {};
    local yy;
    for x=1,11 do
        self.matrix[x] = {};
        for y=1,19 do
            self.matrix[x][#self.matrix[x]+1] = {};
        end
    end

    self.trap_matrix = {};
    local yy;
    for x=1,11 do
        self.trap_matrix[x] = {};
        for y=1,19 do
            self.trap_matrix[x][#self.trap_matrix[x]+1] = {};
        end
    end
    for x=1,19 do
        for y=1,11 do
            self.trap_matrix[y][x] = 0;
        end
    end
    self:update_matrix();

    for sign=-1,1,2 do
        for x=-8,8 do
            SPAWN_POSITIONS[#SPAWN_POSITIONS+1] = {x, 5*sign};
            -- self.entities[#self.entities+1] = Entity.new(1, x, 5*sign);
            -- print(x, -5);
        end
        for y=-5,5 do
            SPAWN_POSITIONS[#SPAWN_POSITIONS+1] = {9*sign, y};
            -- self.entities[#self.entities+1] = Entity.new(1, 9*sign, y);
            -- print(x, -5);
        end
    end

    self.grid = grid(self.matrix);

    self.entities = {};
    self.entities[#self.entities+1] = Entity.new(3);

    self:update_matrix();
end

function Game:update_matrix()
    for x=1,19 do
        for y=1,11 do
            self.matrix[y][x] = 0;
        end
    end

    for _,entity in ipairs(self.entities) do
        self.matrix[math.floor(entity.y+.5)+6][math.floor(entity.x+.5)+10] = entity:is_walkable() and 0 or entity;
    end
end

function Game:effect(eff, x, y)
    local effect = {
        x = x,
        y = y,
    };

    local time_start = love.timer.getTime();
    local time_end = love.timer.getTime() + 1;

    function effect:draw()
        local alpha = math.min(1, map(love.timer.getTime(), time_start, time_end, 0, 1))
        local x, y = project_absolute(self.x, self.y);
        love.graphics.draw(images.atlas, quads.smoke, x + TILE_ABS_SIZE/2, y + TILE_ABS_SIZE/2, DIRECTIONS[math.random(#DIRECTIONS)], TILE_SCALE*2 * math.sin(alpha*math.pi) * 1.3, TILE_SCALE*2 * math.sin(alpha*math.pi) * 1.3, 16/2, 16/2)
    end

    self.effects[#self.effects+1] = effect;
end

function Game:draw()
    self.selected = nil;
    love.graphics.push();

    -- print((self.current_beat-math.floor(self.current_beat)) * 100)
    local alpha = map(self.current_beat-math.floor(self.current_beat), 0, 1, 1, 1.01);

    -- love.graphics.translate(0, 0);
    -- alpha = 0
    -- print(2 * alpha)
    local dx = (WIDTH / 2) - (WIDTH/2) / alpha;
    local dy = (HEIGHT / 2) - (HEIGHT/2) / alpha;
    -- local scale = map(alpha, 0, 1, 1, 2);
    -- local a = map(alpha, 0, 2, 0, alpha/1.5);
    love.graphics.scale(alpha);
    love.graphics.translate(-dx, -dy);
    love.graphics.draw(images.map, WIDTH/2, HEIGHT/2, 0, 4, 4, 384/2, 192/2)

    local floor_alpha = math.sin(((self.current_beat/16) - math.floor(self.current_beat/16)) * math.pi);

    for x=-8,8 do
        for y=-4,4 do
            local ax, ay = project_absolute(x, y);
            -- print(ax)
            hex_color(DISCO_COLORS[(cash(math.floor(self.current_beat), x, y) + math.floor(self.current_beat))%#DISCO_COLORS + 1], 0.5 * (1-floor_alpha));
            -- love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE, TILE_ABS_SIZE);
            love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE, TILE_ABS_SIZE);
            love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE/2, TILE_ABS_SIZE/2);
            love.graphics.rectangle("fill", ax + TILE_ABS_SIZE/2, ay + TILE_ABS_SIZE/2, TILE_ABS_SIZE/2, TILE_ABS_SIZE/2);
        end
    end

    for y=1,19 do
        for x=1,11 do
            if type(self.trap_matrix[x][y])=="table" then
                if self.trap_matrix[x][y] then
                    self.trap_matrix[x][y]:draw();
                end
            end
        end
    end
    for y=1,19 do
        for x=1,11 do
            if type(self.matrix[x][y])=="table" then
                if self.matrix[x][y].is_entity then
                    self.matrix[x][y]:draw();
                end
            end
        end
    end
    -- for _,entity in ipairs(self.entities) do
    --     entity:draw();
    -- end

    hex_color(0xFFFFFF, .5);
    local mouse_x_abs, mouse_y_abs = project_absolute(grid_x, grid_y);
    -- love.graphics.rectangle("fill", mouse_x_abs, mouse_y_abs, TILE_ABS_SIZE, TILE_ABS_SIZE);

    for _,effect in ipairs(self.effects) do
        effect:draw();
    end

    -- self.trap_valid = false;
    if self.trap then
        local mx, my = project_matrix(grid_x, grid_y);
        self.trap_valid = grid_x>=-8 and grid_x<=8 and grid_y>=-4 and grid_y<=4 and self.matrix[my] and self.matrix[my][mx]==0 and self.trap_matrix[my] and self.trap_matrix[my][mx]==0;
        hex_color(self.trap_valid and 0xFFFFFF or 0xFF0000);
        love.graphics.draw(images.atlas, traps[self.trap], mouse_x_abs, mouse_y_abs, 0, TILE_SCALE*2, TILE_SCALE*2);
        -- print(grid_y)
    end
    
    hex_color(0xFFFFFF);
    shaders.flashlight:send("force", self.flashlight_force);
    love.graphics.setShader(shaders.flashlight);
    love.graphics.draw(images.pixel, 0, 0, 0, WIDTH, HEIGHT);
    love.graphics.setShader();

    hex_color(0xFFFFFF);
    love.graphics.print("Coins: "..math.floor(self.coins), 10, 10, 0, 2, 2)
    love.graphics.print("Shop: ", 200, 15, 0, 2, 2)
    self.trap_selected = nil;

    for i=1,#TRAP_INFO do
        if collide(mouse_x, mouse_y, i*TILE_ABS_SIZE/2 + 250, 10, TILE_ABS_SIZE/2, TILE_ABS_SIZE/2) then
            love.graphics.setShader(shaders.outline);
            self.trap_selected = i;
        end
        love.graphics.draw(images.atlas, traps[i], i*TILE_ABS_SIZE/2 + 250, 10, 0, TILE_SCALE, TILE_SCALE);
        if self.trap_selected==i then
            love.graphics.setShader();
        end
        love.graphics.print("$"..TRAP_INFO[i][1], i*TILE_ABS_SIZE/2 + 250, 10);
    end

    if self.trap_selected~=nil then
        love.graphics.print(TRAP_INFO[self.trap_selected][2], 10, HEIGHT - 30, 0, 2, 2);
    elseif self.selected~=nil then
        if self.selected.entity_id==3 then
            love.graphics.print("Villager: Protect it and steal his coins (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==1 then
            love.graphics.print("Ghost: Very spooky, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==5 then
            love.graphics.print("Fireball: Not happy, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==7 then
            love.graphics.print("Eye: Sees you, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==9 then
            love.graphics.print("Heart: It loves you, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==11 then
            love.graphics.print("Fire: It's kinda hot, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==13 then
            love.graphics.print("Strange Bunny: Is he ok? click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==15 then
            love.graphics.print("Bellboy Zombie: Follow me, your room is right there. Click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==17 then
            love.graphics.print("Little eye: Its so small, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==19 then
            love.graphics.print("Penguin: *penguin noise*, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==21 then
            love.graphics.print("Disco Dancer: ya like my style?, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
        if self.selected.entity_id==23 then
            love.graphics.print("Goose: *goose noise*, click to attack (Monster may come)", 10, HEIGHT - 30, 0, 2, 2)
        end
    end
    
    if self.death then
        love.graphics.print("You died! (Last: "..math.floor(self.duration).."s)", WIDTH/2 - love.graphics.getFont():getWidth("You died! (Last: "..math.floor(self.duration).."s)"), HEIGHT/2 - 100, 0, 2, 2)
        love.graphics.print("Press F to pay respect and restart", WIDTH/2 - love.graphics.getFont():getWidth("Press F to pay respect and restart"), HEIGHT/2 + 100, 0, 2, 2)
    end
    love.graphics.pop();
end

function Game:click()
    if self.death then
        return;
    end

    if self.trap then
        if self.trap_valid then
            local mx, my = project_matrix(grid_x, grid_y);
            self.trap_matrix[my][mx] = Trap.new(self.trap, grid_x, grid_y);
            self.trap = nil;
            self:turn();
        end
    elseif self.trap_selected then
        if self.coins_target>=TRAP_INFO[self.trap_selected][1] or love.keyboard.isDown("lshift") then
            sfx.select:play();
            self.coins_target = self.coins_target - TRAP_INFO[self.trap_selected][1];
            if self.trap_selected==10 then
                for i=#self.entities,1,-1 do
                    if self.entities[i].entity_id~=3 then
                        self.entities[i]:damage(self.entities[i].health+10)
                    end
                end
            elseif self.trap_selected==1 then
                self.entities[1]:damage(-10);
            else
                self.trap = self.trap_selected;
            end
        else
            sfx.no:play();
        end
    end

    if not self.click_hold then
        DONT_UPDATE = true;
        self.click_hold = function()
            for _,click in ipairs(self.entities) do
                if grid_x==click.x and grid_y==click.y then
                    click:click();
                    break;
                end
            end
        end
    end
end

function Game:turn()
    if self.death then
        return;
    end

    sfx.jump:play();
    self.round = self.round + 1;
    if self.round%5==0 then
        self.limit = math.min(10, self.limit + 1);
    end

    self:update_matrix();

    local positions = {};

    for _,entity in ipairs(self.entities) do
        local x, y = entity:turn();
        if x~=nil then
            local v = {x, y};
            local used = false;
            for other_entity, other_v in pairs(positions) do
                if other_v[1]==v[1] and other_v[2]==v[2] then
                    used = true;
                    break;
                end
            end

            if not used then
                positions[entity] = v;
            end
        end
    end

    for entity,v in pairs(positions) do
        entity:jump(v[1], v[2]);
    end

    if #self.entities-1 < self.limit then
        for i=1,math.ceil((self.limit-(#self.entities-1))) do
            local position;
            while position == nil do
                position = SPAWN_POSITIONS[math.random(#SPAWN_POSITIONS)];
                local mx, my = project_matrix(position[1], position[2]);
                if self.matrix[my][mx]~=0 then
                    position = nil;
                end
            end

            self.entities[#self.entities+1] = Entity.new(ENEMIES[math.random(#ENEMIES)], position[1], position[2]);
        end
    end

    Game:update_matrix();
end

function Game:update(dt)
    if not self.death then
        self.duration = self.duration + dt;
    end
    local old_beat = self.current_beat;
    self.current_beat = music.theme:tell()/0.5455;
    if self.click_hold then
        if math.floor(old_beat%2)~=math.floor(self.current_beat%2) then
            self.click_hold();
            self.click_hold = nil;
            DONT_UPDATE = false;
        end
    end

    for _,entity in ipairs(self.entities) do
        entity:update(dt);
    end

    self.coins = movetowards(self.coins, self.coins_target, .2)

    self.flashlight_force = lerp(self.flashlight_force, 4 + math.random(5)*math.random(-1, 1), dt)

    if self.death then
        self.flashlight_force = 100;
    else
        local next_beat = math.floor(self.current_beat%2);
        if self.old_beat~=next_beat then
            self.old_beat = next_beat;
            if #self.entities-1 < self.limit then
                self:turn();
            end
        end
    end


end