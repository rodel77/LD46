Menu = {
    clicked = false,
    slider = 0,

    sound_time = 0,
    click_time = 0,
};

function Menu:init()
    music.menu:play();
end

function Menu:draw()
    local beat = math.floor(music.menu:tell()/0.5455);

    for x=-10,10 do
        for y=-6,6 do
            local ax, ay = project_absolute(x, y);
            -- print(ax)
            hex_color(DISCO_COLORS[(cash(math.floor(beat), x, y) + math.floor(beat))%#DISCO_COLORS + 1], .5);
            love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE, TILE_ABS_SIZE);
            love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE, 8);
            love.graphics.rectangle("fill", ax, ay, 8, TILE_ABS_SIZE);
            -- love.graphics.rectangle("fill", ax, ay, TILE_ABS_SIZE/2, TILE_ABS_SIZE/2);
            -- love.graphics.rectangle("fill", ax + TILE_ABS_SIZE/2, ay + TILE_ABS_SIZE/2, TILE_ABS_SIZE/2, TILE_ABS_SIZE/2);
        end
    end

    hex_color(0x000000, .3);
    love.graphics.rectangle("fill", 0, 0, 1280, 720);


    local beat = music.menu:tell()/0.5455;

    if self.clicked and self.click_time~=math.floor(beat) then
        self.click_time = math.floor(beat);
        sfx.coin:play();
    end

    local alpha = beat - math.floor(beat);
    for i=5,10 do
        hex_color(0xFFFFFF, i/50);
        love.graphics.draw(images.atlas, title, WIDTH/2, 100, 0, 6+(1-alpha*(i/10)), 6+(1-alpha*(i/10)), 86/2);
    end
    hex_color(0xFFFFFF, 1);
    love.graphics.draw(images.atlas, title, WIDTH/2, 100, 0, 6+(1-alpha), 6+(1-alpha), 86/2);


    if self.play_focus then
        for i=5,10 do
            hex_color(0xFFFFFF, i/50);
            love.graphics.draw(images.atlas, play2, WIDTH/2, 300 - 7, 0, 6+(1-alpha*(i/10)), 6+(1-alpha*(i/10)), 34/2);
        end
        hex_color(0xFFFFFF, 1);
        love.graphics.draw(images.atlas, play2, WIDTH/2, 300 - 7, 0, 6+(1-alpha), 6+(1-alpha), 34/2);
    else
        for i=5,10 do
            hex_color(0xFFFFFF, i/50);
            love.graphics.draw(images.atlas, play1, WIDTH/2, 300, 0, 6+(1-alpha*(i/10)), 6+(1-alpha*(i/10)), 32/2);
        end
        hex_color(0xFFFFFF, 1);
        love.graphics.draw(images.atlas, play1, WIDTH/2, 300, 0, 6+(1-alpha), 6+(1-alpha), 32/2);
    end

    if not love.mouse.isDown(1) then
        self.slider = 0;
    end

    self:draw_slider(1, 500)
    self:draw_slider(2, 600)
end

function Menu:draw_slider(type, y)

    hex_color(0xFFFFFF);
    love.graphics.rectangle("fill", WIDTH/2 - 300/2, y, 300, 8);
    hex_color(0xEEEEEE);
    love.graphics.rectangle("fill", WIDTH/2 - 300/2, y + 8, 300, 8);

    local x;
    if type==1 then
        x = map(music.theme:getVolume(), 0, 1, -300/2, 300/2);
        love.graphics.setColor(music.theme:getVolume(), 1-music.theme:getVolume(), 0);
        love.graphics.draw(images.atlas,music_icon, WIDTH/2 + 200, y+8, 0, 4, 4, 9/2, 8/2);
    end
    if type==2 then
        x = map(sfx.coin:getVolume(), 0, 1, -300/2, 300/2);
        love.graphics.setColor(sfx.coin:getVolume(), 1-sfx.coin:getVolume(), 0);
        love.graphics.draw(images.atlas, sound_icon, WIDTH/2 + 200, y+8, 0, 4, 4, 9/2, 8/2);
    end
    local inside = collide(mouse_x, mouse_y, WIDTH/2 + x - 20, y + 8 - 20, 40, 40);
    hex_color(0xFFFFFF);
    if inside then
        love.graphics.rectangle("fill", WIDTH/2 + x - 25, y + 8 - 25, 50, 50, 2);

        if self.slider==0 and love.mouse.isDown(1) then
            self.slider = type;
        end
    end
    hex_color(0xec4700);
    love.graphics.rectangle("fill", WIDTH/2 + x - 20, y + 8 - 20, 40, 40, 2);
    -- love.graphics.circle("fill", WIDTH/2 + x, y + 8, 20);
    hex_color(0xFFFFFF);

    love.graphics.print("Made for Ludum Dare 46\nBy @therodel77\n\n+ Click the villager to get coins\n(enemies may come)\n+ Kill ugly monsters\n+ Build a fortress?", 10, HEIGHT/2, 0, 2, 2);

    -- hex_color(0xec47006);
    -- hex_color(DISCO_COLORS[(y + beat)%#DISCO_COLORS + 1])
    
end

function Menu:update(dt)
    if self.slider~=0 then
        local alpha = map(math.min(WIDTH/2 + 300/2, math.max(WIDTH/2 - 300/2, mouse_x)), WIDTH/2 + 300/2, WIDTH/2 - 300/2, 1, 0);

        if self.slider==1 then
            for _,track in pairs(music) do
                track:setVolume(alpha);
            end
        else
            for _,track in pairs(sfx) do
                track:setVolume(alpha);
            end
            local new_time = math.floor(love.timer.getTime()/.2);
            if self.sound_time~=new_time then
                self.sound_time = new_time;
                sfx.select:play();
            end
        end
    end

    self.play_focus = false;
    if self.clicked and math.floor((music.menu:tell()/0.5455)%4)==0 then
        music.menu:stop();
        music.theme:play();
        math.randomseed(love.timer.getTime());
        Game:init();
        state = Game;
    end

    if collide(mouse_x, mouse_y, WIDTH/2 - 33*7/2, 300 - 10, 7*33, 7*16) then
        self.play_focus = true;
    end
end

function Menu:click()
    if self.play_focus then
        self.clicked = true;
    end
end